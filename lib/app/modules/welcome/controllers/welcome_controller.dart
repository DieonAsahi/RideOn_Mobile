import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:capbatu/app/services/auth_service.dart';

class WelcomeController extends GetxController {
  final box = GetStorage();

  @override
  void onReady() {
    super.onReady();

    final isFirstInstall = box.read("first_install") ?? true;
    final token = box.read("token");
    final lastClosedStr = box.read("last_closed");

    // Jika lebih dari 8 jam sejak aplikasi ditutup/ditinggalkan, langsung logout & buka login
    if (lastClosedStr != null) {
      final lastClosed = DateTime.tryParse(lastClosedStr);
      if (lastClosed != null) {
        final diff = DateTime.now().difference(lastClosed);
        if (diff >= const Duration(hours: 8)) {
          AuthService.logout();
          return;
        }
      }
    }

    if (!isFirstInstall) {
      if (token != null && token.toString().isNotEmpty) {
        box.write("last_closed", DateTime.now().toIso8601String());
        _checkVehicleAndRoute(token.toString());
      } else {
        Get.offAllNamed("/login");
      }
    }
  }

  Future<void> _checkVehicleAndRoute(String token) async {
    try {
      final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];
      final response = await http
          .get(
            Uri.parse("$baseUrl/api/vehicle/my-vehicle"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 7));

      if (response.statusCode == 401) {
        await AuthService.logout();
        return;
      }

      if (response.statusCode == 200) {
        final vehicle = jsonDecode(response.body);
        if (vehicle != null && vehicle["id"] != null) {
          box.write("vehicle_id", vehicle["id"]);
          Get.offAllNamed("/mainscreen");
          return;
        }
      }

      // Jika user tidak memiliki kendaraan (misal sudah dihapus semua lalu buka app lagi)
      // Langsung diarahkan ke halaman login
      await AuthService.logout();
    } catch (e) {
      print("Error checking vehicle on app launch: $e");
      // Fallback jika timeout / network offline: jika vehicle_id ada di storage, coba mainscreen, jika tidak ada logout ke login
      final storedVehicleId = box.read("vehicle_id");
      if (storedVehicleId != null && storedVehicleId.toString().isNotEmpty) {
        Get.offAllNamed("/mainscreen");
      } else {
        await AuthService.logout();
      }
    }
  }

  void getStarted() {
    box.write("first_install", false);
    Get.offAllNamed("/login");
  }
}