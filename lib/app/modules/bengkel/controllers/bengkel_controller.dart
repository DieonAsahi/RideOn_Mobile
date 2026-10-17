import 'dart:async';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../services/location_service.dart';
import '../../../services/connectivity_service.dart';

class BengkelController extends GetxController with WidgetsBindingObserver {
  final Dio dio = Dio();
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  final bengkelList = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final searchController = TextEditingController();
  final filteredBengkelList = <Map<String, dynamic>>[].obs;
  Position? _userPosition;
  Timer? _searchDebounce;
  int _searchRequestVersion = 0;

  // Status Lokasi & Izin
  var isPermissionGranted = true.obs;
  var isGpsEnabled = true.obs;

  var isGpsDismissed = false.obs;

  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    // Dengarkan perubahan status GPS secara realtime (misal user mematikan/menyalakan GPS dari status bar)
    _serviceStatusSubscription = LocationService.getServiceStatusStream()
        .listen((status) {
          if (status == ServiceStatus.enabled) {
            isGpsEnabled.value = true;
            loadNearestWorkshop();
          } else {
            isGpsEnabled.value = false;
          }
        });

    loadNearestWorkshop();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceStatusSubscription?.cancel();
    _searchDebounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Saat user kembali dari Pengaturan Izin / Pengaturan GPS
      checkAndReload();
    }
  }

  Future<void> checkAndReload() async {
    final prevPermission = isPermissionGranted.value;
    final prevGps = isGpsEnabled.value;

    final permissionGranted =
        await LocationService.isLocationPermissionGranted();
    isPermissionGranted.value = permissionGranted;

    final serviceEnabled = await LocationService.isLocationServiceEnabled();
    isGpsEnabled.value = serviceEnabled;

    // Hanya reload jika sebelumnya mati/ditolak lalu sekarang aktif/diizinkan,
    // atau jika data bengkel memang belum ada (kosong) dan belum dalam kondisi loading
    final wasRestricted = !prevPermission || !prevGps;
    final isNowReady = permissionGranted && serviceEnabled;

    if (isNowReady && (wasRestricted || bengkelList.isEmpty)) {
      if (!isLoading.value) {
        loadNearestWorkshop();
      }
    }
  }

  void searchBengkel(String keyword) {
    final query = keyword.trim();
    _searchDebounce?.cancel();

    if (query.isEmpty) {
      _searchRequestVersion++;
      filteredBengkelList.assignAll(bengkelList);
      return;
    }

    final requestVersion = ++_searchRequestVersion;
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final results = await _searchWorkshops(query);

        // Ignore an older response after the user changes the keyword.
        if (requestVersion != _searchRequestVersion ||
            searchController.text.trim() != query) {
          return;
        }

        filteredBengkelList.assignAll(results);
      } catch (e) {
        if (requestVersion == _searchRequestVersion) {
          ConnectivityService.handleNetworkError(e);
        }
      }
    });
  }

  Future<List<Map<String, dynamic>>> _searchWorkshops(String keyword) async {
    final queryParameters = <String, dynamic>{'keyword': keyword};
    if (_userPosition != null) {
      queryParameters.addAll({
        'lat': _userPosition!.latitude,
        'lng': _userPosition!.longitude,
      });
    }

    final response = await dio.get(
      "$baseUrl/api/workshop/search",
      queryParameters: queryParameters,
    );
    final rawData = response.data is Map ? response.data['data'] : null;
    if (rawData is! List) return [];

    return rawData
        .map((item) => _toBengkelItem(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Map<String, dynamic> _toBengkelItem(Map<String, dynamic> item) {
    return {
      'id': item['id'],
      'nama': item['title'] ?? '',
      'jenis': item['category'] ?? '',
      'jarak': item['distance_km'] == null ? '-' : "${item['distance_km']} km",
      'rating': (item['total_score'] ?? 0).toString(),
      'ulasan': "(${item['review_count'] ?? 0} Ulasan)",
      'image': item['image_url'] ?? '',
      'address': item['address'] ?? '',
      'phone': item['phone'] ?? '',
      'latitude': item['latitude'],
      'longitude': item['longitude'],
      'google_maps_url': item['google_maps_url'] ?? '',
    };
  }

  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      isPermissionGranted.value = true;
      final serviceEnabled = await LocationService.isLocationServiceEnabled();
      isGpsEnabled.value = serviceEnabled;
      if (serviceEnabled) {
        await loadNearestWorkshop();
      }
    } else if (permission == LocationPermission.deniedForever) {
      await LocationService.openAppSettings();
    }
  }

  Future<void> openGpsSettings() async {
    await LocationService.openLocationSettings();
  }

  void dismissGpsDialog() {
    isGpsDismissed.value = true;
  }

  Future<void> loadNearestWorkshop() async {
    try {
      // 1. Cek Izin Lokasi
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

      // 2. Cek apakah GPS aktif
      bool serviceEnabled = await LocationService.isLocationServiceEnabled();
      isGpsEnabled.value = serviceEnabled;
      if (!serviceEnabled) {
        return;
      }
      isGpsDismissed.value = false;

      isLoading.value = true;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _userPosition = position;

      final response = await dio.get(
        "$baseUrl/api/workshop/nearest",
        queryParameters: {
          "lat": position.latitude,
          "lng": position.longitude,
          "limit": 100,
        },
      );

      final List data = response.data["data"];

      bengkelList.assignAll(
        data
            .map(
              (item) => _toBengkelItem(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(),
      );

      filteredBengkelList.assignAll(bengkelList);
    } catch (e) {
      print("Error loadNearestWorkshop: $e");
      ConnectivityService.handleNetworkError(e);
    } finally {
      isLoading.value = false;
    }
  }
}
