import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../services/location_service.dart';
import '../../../services/connectivity_service.dart';

class WorkshopModel {
  final int? id;
  final String title;
  final String category;
  final String address;
  final String phone;
  final double rating;
  final int reviewCount;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final String googleMapsUrl;
  final String openingHours;

  double distanceKm; // Hapus kata 'final' agar bisa dikalkulasi ulang

  WorkshopModel({
    this.id,
    required this.title,
    required this.category,
    required this.address,
    required this.phone,
    required this.rating,
    required this.reviewCount,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.googleMapsUrl,
    required this.openingHours,
    this.distanceKm = 0.0,
  });

  factory WorkshopModel.fromJson(Map<String, dynamic> json) {
    return WorkshopModel(
      id: json['id'],
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      address: json['address'] ?? '',
      phone: (json['phone'] ?? '').toString().trim(),
      rating: (json['total_score'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      openingHours: json['opening_hours'] ?? '-',
      googleMapsUrl: json['google_maps_url'] ?? '',
      imageUrl: json['image_url'] ?? '',
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
    );
  }
}

class PetabengkelController extends GetxController
    with WidgetsBindingObserver, GetTickerProviderStateMixin {
  final Dio dio = Dio();
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  final MapController mapController = MapController();
  AnimationController? _animController;

  final workshops = <WorkshopModel>[].obs;
  final selectedWorkshop = Rxn<WorkshopModel>();

  final markers = <Marker>[].obs;
  final userLocation = Rxn<LatLng>();

  // State Baru untuk UI
  final showBottomSheet = false.obs;
  final sheetExtent = 0.2.obs;
  final isSearchActive = false.obs;
  final isLoadingSheet = false.obs;

  final searchController = TextEditingController();
  final filteredWorkshops = <WorkshopModel>[].obs;
  final isLoading = false.obs;
  Timer? _searchDebounce;
  int _searchRequestVersion = 0;
  String? _lastNotFoundQuery;
  List<WorkshopModel>? _allWorkshopsSearchCache;
  bool _searchEndpointUnavailable = false;
  bool _isMapReady = false;
  bool _hasCenteredOnUser = false;

  final searchSuggestions = <WorkshopModel>[].obs;
  final showSuggestions = false.obs;

  final currentZoom = 13.0.obs;

  // Status Lokasi & Izin
  var isPermissionGranted = true.obs;
  var isGpsEnabled = true.obs;
  var isGpsDismissed = false.obs;

  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;

  List<WorkshopModel> get otherWorkshops {
    if (selectedWorkshop.value == null) return [];
    return workshops
        .where((e) => e.id != selectedWorkshop.value!.id)
        .take(10)
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    _serviceStatusSubscription = LocationService.getServiceStatusStream()
        .listen((status) {
          if (status == ServiceStatus.enabled) {
            isGpsEnabled.value = true;
            loadMapData();
          } else {
            isGpsEnabled.value = false;
          }
        });

    loadMapData();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceStatusSubscription?.cancel();
    _searchDebounce?.cancel();
    _animController?.dispose();
    searchController.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkAndReload();
    }
  }

  void dismissGpsDialog() {
    isGpsDismissed.value = true;
  }

  void animatedMapMove(LatLng destLocation, double destZoom) {
    if (!_isMapReady) return;
    _animController?.dispose();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    final latTween = Tween<double>(
      begin: mapController.camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: mapController.camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: mapController.camera.zoom,
      end: destZoom,
    );

    final animation = CurvedAnimation(
      parent: _animController!,
      curve: Curves.fastOutSlowIn,
    );

    _animController!.addListener(() {
      mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    _animController!.forward();
  }

  void onMapReady() {
    _isMapReady = true;
    _centerMapOnUserIfNeeded();
  }

  void _centerMapOnUserIfNeeded() {
    final location = userLocation.value;
    if (!_isMapReady || _hasCenteredOnUser || location == null) return;
    mapController.move(location, 14.0);
    _hasCenteredOnUser = true;
  }

  void updateMapState(MapCamera camera) {
    currentZoom.value = camera.zoom;
  }

  Future<void> checkAndReload() async {
    final prevPermission = isPermissionGranted.value;
    final prevGps = isGpsEnabled.value;

    final permissionGranted =
        await LocationService.isLocationPermissionGranted();
    isPermissionGranted.value = permissionGranted;

    final serviceEnabled = await LocationService.isLocationServiceEnabled();
    isGpsEnabled.value = serviceEnabled;

    final wasRestricted = !prevPermission || !prevGps;
    final isNowReady = permissionGranted && serviceEnabled;

    if (isNowReady && (wasRestricted || workshops.isEmpty)) {
      if (!isLoading.value) {
        await loadMapData();
      }
    }
  }

  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      isPermissionGranted.value = true;
      final serviceEnabled = await LocationService.isLocationServiceEnabled();
      isGpsEnabled.value = serviceEnabled;
      if (serviceEnabled) {
        await loadMapData();
      }
    } else if (permission == LocationPermission.deniedForever) {
      await LocationService.openAppSettings();
    }
  }

  Future<void> openGpsSettings() async {
    await LocationService.openLocationSettings();
  }

  Future<void> loadMapData() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        isPermissionGranted.value = false;
        return;
      } else {
        isPermissionGranted.value = true;
      }

      bool serviceEnabled = await LocationService.isLocationServiceEnabled();
      isGpsEnabled.value = serviceEnabled;
      if (!serviceEnabled) return;

      isLoading.value = true;
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userLocation.value = LatLng(position.latitude, position.longitude);
      _centerMapOnUserIfNeeded();

      await getWorkshops();
    } catch (e) {
      ConnectivityService.handleNetworkError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String keyword) {
    final query = keyword.trim();
    _searchDebounce?.cancel();

    if (query.isEmpty) {
      _searchRequestVersion++;
      _lastNotFoundQuery = null;
      showSuggestions.value = false;
      searchSuggestions.clear();
      filteredWorkshops.clear();
      selectedWorkshop.value = null;
      showBottomSheet.value = false;
      _updateMarkers();
      return;
    }

    showSuggestions.value = true;
    final requestVersion = ++_searchRequestVersion;
    _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final results = await _searchWorkshops(query);
        if (requestVersion != _searchRequestVersion ||
            searchController.text.trim() != query) {
          return;
        }
        searchSuggestions.assignAll(results);
      } catch (_) {
        if (requestVersion == _searchRequestVersion) {
          searchSuggestions.clear();
        }
      }
    });
  }

  Future<void> onSubmitSearch(String keyword) async {
    final query = keyword.trim();
    _searchDebounce?.cancel();
    final requestVersion = ++_searchRequestVersion;

    // Tutup keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    if (query.isEmpty) {
      _lastNotFoundQuery = null;
      isSearchActive.value = false;
      filteredWorkshops.clear();
      selectedWorkshop.value = null;
      showBottomSheet.value = false;
      _updateMarkers();
      return;
    }

    try {
      final results = await _searchWorkshops(query);
      if (requestVersion != _searchRequestVersion) return;

      _applySearchResults(query, results);

      if (results.isEmpty) {
        showSuggestions.value = false;
        return; // UI akan menampilkan empty state
      }

      // Hasil ditemukan, tutup layar pencarian penuh
      isSearchActive.value = false;
      showSuggestions.value = false;

      // Zoom logic
      if (results.length == 1) {
        animatedMapMove(
          LatLng(results.first.latitude, results.first.longitude),
          16.0,
        );
      } else {
        // flutter_map v6: CameraFit bounds
        final points = results
            .map((e) => LatLng(e.latitude, e.longitude))
            .toList();
        final bounds = LatLngBounds.fromPoints(points);
        mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
        );
      }
    } catch (e) {
      if (requestVersion == _searchRequestVersion) {
        if (!ConnectivityService.handleNetworkError(e)) {
          _showSearchError();
        }
      }
    }
  }

  void _applySearchResults(String query, List<WorkshopModel> results) {
    filteredWorkshops.assignAll(results);
    selectedWorkshop.value = null;
    showBottomSheet.value = false;
    _updateMarkers();

    if (results.isNotEmpty) {
      _lastNotFoundQuery = null;
    } else {
      _lastNotFoundQuery = query; // Simpan untuk mendeteksi empty state
    }
  }

  Future<List<WorkshopModel>> _searchWorkshops(String keyword) async {
    if (_searchEndpointUnavailable) {
      return _searchFromPetaFallback(keyword);
    }

    final queryParameters = <String, dynamic>{'keyword': keyword};
    if (userLocation.value != null) {
      queryParameters.addAll({
        'lat': userLocation.value!.latitude,
        'lng': userLocation.value!.longitude,
      });
    }

    try {
      final response = await dio.get(
        "$baseUrl/api/workshop/search",
        queryParameters: queryParameters,
      );
      return _workshopsFromResponse(response.data);
    } on DioException catch (error) {
      if (error.response?.statusCode != 404) rethrow;
      _searchEndpointUnavailable = true;
      return _searchFromPetaFallback(keyword);
    }
  }

  Future<List<WorkshopModel>> _searchFromPetaFallback(String keyword) async {
    _allWorkshopsSearchCache ??= await _loadAllWorkshopsForSearch();
    final normalizedKeyword = keyword.toLowerCase();
    final results = _allWorkshopsSearchCache!
        .where(
          (workshop) => [
            workshop.title,
            workshop.category,
            workshop.address,
          ].any((value) => value.toLowerCase().contains(normalizedKeyword)),
        )
        .toList();

    results.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return results;
  }

  Future<List<WorkshopModel>> _loadAllWorkshopsForSearch() async {
    final response = await dio.get("$baseUrl/api/workshop/peta");
    return _workshopsFromResponse(response.data);
  }

  List<WorkshopModel> _workshopsFromResponse(dynamic responseData) {
    final rawData = responseData is List
        ? responseData
        : responseData is Map
        ? responseData['data']
        : null;
    if (rawData is! List) return [];

    return rawData.map((item) {
      final workshop = WorkshopModel.fromJson(
        Map<String, dynamic>.from(item as Map),
      );
      return _calculateDistanceIfNeeded(workshop);
    }).toList();
  }

  void _showSearchError() {
    Get.snackbar(
      "Pencarian Belum Tersedia",
      "Data bengkel belum dapat dimuat. Silakan coba lagi.",
      backgroundColor: Colors.orangeAccent,
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    );
  }

  WorkshopModel _calculateDistanceIfNeeded(WorkshopModel workshop) {
    if (userLocation.value != null && workshop.distanceKm == 0) {
      final distanceMeter = const Distance().as(
        LengthUnit.Meter,
        userLocation.value!,
        LatLng(workshop.latitude, workshop.longitude),
      );
      workshop.distanceKm = distanceMeter / 1000.0;
    }
    return workshop;
  }

  void onSelectSuggestion(WorkshopModel workshop) {
    showSuggestions.value = false;
    isSearchActive.value = false;
    FocusManager.instance.primaryFocus?.unfocus();
    searchController.text = workshop.title;

    filteredWorkshops.assignAll([workshop]);
    _updateMarkers();
    animatedMapMove(LatLng(workshop.latitude, workshop.longitude), 17.0);
    getWorkshopDetail(workshop.id!);
  }

  Future<void> getWorkshops() async {
    if (userLocation.value == null) return;
    try {
      final response = await dio.get(
        "$baseUrl/api/workshop/nearest",
        queryParameters: {
          "lat": userLocation.value!.latitude,
          "lng": userLocation.value!.longitude,
          "limit": 100,
        },
      );

      final data = (response.data["data"] as List).map((e) {
        var workshop = WorkshopModel.fromJson(e);
        if (workshop.distanceKm == 0 && userLocation.value != null) {
          final distanceMeter = const Distance().as(
            LengthUnit.Meter,
            userLocation.value!,
            LatLng(workshop.latitude, workshop.longitude),
          );
          workshop.distanceKm = distanceMeter / 1000.0;
        }
        return workshop;
      }).toList();

      data.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      workshops.assignAll(data);
      filteredWorkshops.clear(); // Bersihkan filter saat reset data awal
      _updateMarkers();

      animatedMapMove(userLocation.value!, 14.0);
    } catch (e) {
      ConnectivityService.handleNetworkError(e);
    }
  }

  Future<void> getWorkshopDetail(int id) async {
    isLoadingSheet.value = true;
    showBottomSheet.value = true;
    try {
      final response = await dio.get("$baseUrl/api/workshop/petaDetail/$id");
      final body = response.data is Map ? response.data : <String, dynamic>{};
      final rawWorkshop = body['data'] is Map ? body['data'] : response.data;
      var detailWorkshop = WorkshopModel.fromJson(
        Map<String, dynamic>.from(rawWorkshop as Map),
      );

      WorkshopModel? existingWorkshop;
      for (final workshop in [...filteredWorkshops, ...workshops]) {
        if (workshop.id == id) {
          existingWorkshop = workshop;
          break;
        }
      }
      detailWorkshop.distanceKm =
          existingWorkshop?.distanceKm ??
          _calculateDistanceIfNeeded(detailWorkshop).distanceKm;

      selectedWorkshop.value = detailWorkshop;
      sheetExtent.value = 0.2;
    } catch (e) {
      ConnectivityService.handleNetworkError(e);
    } finally {
      isLoadingSheet.value = false;
    }
  }

  void _updateMarkers() {
    final allWorkshops = <int, WorkshopModel>{};

    // Base 100 rekomendasi
    for (var w in workshops) {
      allWorkshops[w.id!] = w;
    }

    // Jika ada pencarian, tambahkan hasil search agar selalu terender
    final hasActiveSearch = filteredWorkshops.isNotEmpty;
    if (hasActiveSearch) {
      for (var w in filteredWorkshops) {
        allWorkshops[w.id!] = w;
      }
    }

    markers.assignAll(
      allWorkshops.values.map((w) {
        // Tampilkan label nama JIKA map sedang dalam mode search (dan marker adalah hasil search)
        // ATAU map di-zoom sangat dalam (>=16)
        bool isSearchResult =
            hasActiveSearch && filteredWorkshops.any((fw) => fw.id == w.id);
        bool showLabel =
            isSearchResult || (!hasActiveSearch && currentZoom.value >= 16.0);

        return Marker(
          point: LatLng(w.latitude, w.longitude),
          width: 150,
          height: 85,
          alignment: Alignment.center,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              animatedMapMove(LatLng(w.latitude, w.longitude), 16.5);
              getWorkshopDetail(w.id!);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showLabel)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    margin: const EdgeInsets.only(bottom: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      w.title,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const Icon(Icons.location_on, color: Colors.red, size: 40),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
