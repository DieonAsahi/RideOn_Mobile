import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class BengkelController extends GetxController {
  final Dio dio = Dio();

  final bengkelList = <Map<String, dynamic>>[].obs;

  final isLoading = false.obs;
  final searchController = TextEditingController();

  final filteredBengkelList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadNearestWorkshop();
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

  Future<void> loadNearestWorkshop() async {
    try {
      isLoading.value = true;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();

        Get.snackbar("Lokasi", "Silakan aktifkan GPS terlebih dahulu");

        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Get.snackbar("Lokasi", "Izin lokasi diperlukan");
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final response = await dio.get(
        "https://hireable-unelegant-linwood.ngrok-free.dev/api/workshop/nearest",
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
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
