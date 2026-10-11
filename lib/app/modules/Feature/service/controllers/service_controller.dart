import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:capbatu/app/services/auth_service.dart';
import 'package:capbatu/app/services/connectivity_service.dart';

class ServiceItem {
  final int id;
  final String name;
  final String icon;
  final bool isScheduled;
  final String status;
  final String? severity;
  final String message;

  ServiceItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.isScheduled,
    required this.status,
    this.severity,
    required this.message,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json["id"],
      name: json["name"],
      icon: json["icon"],
      isScheduled: json["isScheduled"] ?? false,
      status: json["status"],
      severity: json["severity"],
      message: json["message"],
    );
  }
}

class ServiceController extends GetxController {
  final box = GetStorage();
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  var isLoading = false.obs;
  var services = <ServiceItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    getServices();
  }

  Future<void> getServices({bool force = false}) async {
    if (!force && services.isNotEmpty) return;
    try {
      isLoading.value = true;

      final token = box.read("token");
      final vehicleId = box.read("vehicle_id");

      if (token == null) {
        await AuthService.logout();
        return;
      }

      if (vehicleId == null || vehicleId.toString().isEmpty) {
        return;
      }

      final response = await http.get(
        Uri.parse("$baseUrl/api/vehicle/service/$vehicleId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 401) {
        await AuthService.logout();
        return;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          services.value = data.map((e) => ServiceItem.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print("Error getServices: $e");
      ConnectivityService.handleNetworkError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void goToWorkshop() {
    Get.toNamed('/bengkel');
  }

  void goToHistory() {
    Get.toNamed('/rwtservis');
  }

  void goToEstimate() {
    Get.toNamed('/estimasi');
  }

  void checkDamage() {
    Get.toNamed('/kerusakan');
  }

  void goToAddHistory(ServiceItem item) {
    Get.toNamed(
      '/rwttambah',
      arguments: {'jadwalkan': true, 'component': item},
    );
  }
}
