import 'dart:async';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../services/location_service.dart';

class BengkelController extends GetxController with WidgetsBindingObserver {
  final Dio dio = Dio();
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  final bengkelList = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final searchController = TextEditingController();
  final filteredBengkelList = <Map<String, dynamic>>[].obs;

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
    if (keyword.isEmpty) {
      filteredBengkelList.assignAll(bengkelList);
      return;
    }

    filteredBengkelList.assignAll(
      bengkelList.where(
        (item) => item['nama'].toString().toLowerCase().contains(
          keyword.toLowerCase(),
        ),
      ),
    );
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
      if (serviceEnabled) {
        isGpsDismissed.value = false;
        return;
      }

      if (!serviceEnabled) {
        return;
      }

      isLoading.value = true;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final response = await dio.get(
        "$baseUrl/api/workshop/nearest",
        queryParameters: {
          "lat": position.latitude,
          "lng": position.longitude,
          "limit": 20,
        },
      );

      final List data = response.data["data"];

      bengkelList.assignAll(
        data
            .map(
              (item) => {
                "id": item["id"],
                "nama": item["title"] ?? "",
                "jenis": item["category"] ?? "",
                "jarak": "${item["distance_km"]} km",
                "rating": item["rating"].toString(),
                "ulasan": "(${item["review_count"] ?? 0} Ulasan)",
                "image": item["image_url"] ?? "https://via.placeholder.com/300",
                "address": item["address"] ?? "",
                "phone": item["phone"] ?? "",
                "latitude": item["latitude"],
                "longitude": item["longitude"],
                "google_maps_url": item["google_maps_url"] ?? "",
              },
            )
            .toList(),
      );

      filteredBengkelList.assignAll(bengkelList);
    } catch (e) {
      print("Error loadNearestWorkshop: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
