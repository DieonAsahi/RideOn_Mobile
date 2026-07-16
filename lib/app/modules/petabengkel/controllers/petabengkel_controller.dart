import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

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

class PetabengkelController extends GetxController {
  final Dio dio = Dio();

  final workshops = <WorkshopModel>[].obs;
  final selectedWorkshop = Rxn<WorkshopModel>();

  final markers = <Marker>[].obs;
  final userLocation = Rxn<LatLng>();

  final showBottomSheet = false.obs;

  final searchController = TextEditingController();

  final filteredWorkshops = <WorkshopModel>[].obs;

  final isLoading = false.obs;

  List<WorkshopModel> get otherWorkshops {
    if (selectedWorkshop.value == null) return [];

    return workshops
        .where((e) => e.id != selectedWorkshop.value!.id)
        .take(10)
        .toList();
  }

  @override
  void onInit() async {
    super.onInit();

    await getCurrentLocation();
    await getWorkshops();
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

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      Get.snackbar("Lokasi", "Aktifkan GPS terlebih dahulu");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition();

    userLocation.value = LatLng(position.latitude, position.longitude);
  }

  Future<void> getWorkshops() async {
    try {
      isLoading.value = true;

      final response = await dio.get(
        "https://backend-capstone-snowy.vercel.app/api/workshop/nearest",
        queryParameters: {
          "lat": userLocation.value!.latitude,
          "lng": userLocation.value!.longitude,
          "limit": 100,
        },
      );

      print(response.data);

      final data = (response.data["data"] as List)
          .map((e) => WorkshopModel.fromJson(e))
          .toList();

      workshops.assignAll(data);

      filteredWorkshops.assignAll(data);

      for (var w in data.take(5)) {
        print("${w.title} -> ${w.latitude}, ${w.longitude}");
      }

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

      print("Marker count: ${markers.length}");
      print(data.length);
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getWorkshopDetail(int id) async {
    try {
      final response = await dio.get(
        "https://backend-capstone-snowy.vercel.app/api/workshop/petaDetail/$id",
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
      print(e);
    }
  }
}
