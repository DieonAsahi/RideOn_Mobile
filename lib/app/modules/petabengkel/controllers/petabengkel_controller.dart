import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../services/location_service.dart';

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
  final double distanceKm;
  final String openingHours;

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
    required this.distanceKm,
    required this.openingHours,
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
      imageUrl: json['image_url'] ?? '',
      googleMapsUrl: json['google_maps_url'] ?? '',
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
      openingHours: json['opening_hours'] ?? '-',
    );
  }
}

class PetabengkelController extends GetxController with WidgetsBindingObserver {
  final Dio dio = Dio();
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  final workshops = <WorkshopModel>[].obs;
  final selectedWorkshop = Rxn<WorkshopModel>();

  final markers = <Marker>[].obs;
  final userLocation = Rxn<LatLng>();

  final showBottomSheet = false.obs;
  final searchController = TextEditingController();
  final filteredWorkshops = <WorkshopModel>[].obs;
  final isLoading = false.obs;

  // Status Lokasi & Izin
  var isPermissionGranted = true.obs;
  var isGpsEnabled = true.obs;

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

    // Stream GPS on/off realtime
    _serviceStatusSubscription = LocationService.getServiceStatusStream().listen((status) {
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
    searchController.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkAndReload();
    }
  }

  Future<void> checkAndReload() async {
    final prevPermission = isPermissionGranted.value;
    final prevGps = isGpsEnabled.value;

    final permissionGranted = await LocationService.isLocationPermissionGranted();
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
      // 1. Cek perizinan lokasi
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

      // 2. Cek apakah GPS perangkat aktif
      bool serviceEnabled = await LocationService.isLocationServiceEnabled();
      isGpsEnabled.value = serviceEnabled;
      if (!serviceEnabled) {
        return;
      }

      isLoading.value = true;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      userLocation.value = LatLng(position.latitude, position.longitude);

      await getWorkshops();
    } catch (e) {
      print("Error loadMapData: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void selectWorkshop(WorkshopModel workshop) {
    selectedWorkshop.value = workshop;
    showBottomSheet.value = true;
  }

  void searchWorkshop(String keyword) {
    if (keyword.isEmpty) {
      filteredWorkshops.assignAll(workshops);
    } else {
      filteredWorkshops.assignAll(
        workshops.where(
          (w) => w.title.toLowerCase().contains(keyword.toLowerCase()),
        ),
      );
    }

    markers.assignAll(
      filteredWorkshops.map(
        (w) => Marker(
          point: LatLng(w.latitude, w.longitude),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              getWorkshopDetail(w.id!);
            },
            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        ),
      ),
    );
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

      final data = (response.data["data"] as List)
          .map((e) => WorkshopModel.fromJson(e))
          .toList();

      workshops.assignAll(data);
      filteredWorkshops.assignAll(data);

      markers.assignAll(
        data.map(
          (w) => Marker(
            point: LatLng(w.latitude, w.longitude),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () {
                getWorkshopDetail(w.id!);
              },
              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
          ),
        ),
      );
    } catch (e) {
      print("Error getWorkshops: $e");
    }
  }

  Future<void> getWorkshopDetail(int id) async {
    try {
      final response = await dio.get(
        "$baseUrl/api/workshop/petaDetail/$id",
      );

      final oldWorkshop = workshops.firstWhere((e) => e.id == id);

      selectedWorkshop.value = WorkshopModel(
        id: response.data['id'],
        title: response.data['title'] ?? '',
        category: response.data['category'] ?? '',
        address: response.data['address'] ?? '',
        phone: (response.data['phone'] ?? '').toString().trim(),
        rating: (response.data['total_score'] ?? 0).toDouble(),
        reviewCount: response.data['review_count'] ?? 0,
        latitude: (response.data['latitude'] ?? 0).toDouble(),
        longitude: (response.data['longitude'] ?? 0).toDouble(),
        imageUrl: response.data['image_url'] ?? '',
        googleMapsUrl: response.data['google_maps_url'] ?? '',
        openingHours: response.data['opening_hours'] ?? '-',
        distanceKm: oldWorkshop.distanceKm,
      );

      showBottomSheet.value = true;
    } catch (e) {
      print("Error getWorkshopDetail: $e");
    }
  }
}
