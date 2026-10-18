import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:capbatu/app/services/auth_service.dart';
import 'package:capbatu/app/services/connectivity_service.dart';

class ProfilController extends GetxController {
  final box = GetStorage();
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  var isLoading = false.obs;

  var name = ''.obs;
  var bio = ''.obs;
  var imageUrl = ''.obs;
  var isReminderEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    final cachedReminder = box.read("service_reminder_enabled");
    if (cachedReminder != null) {
      isReminderEnabled.value = cachedReminder is bool ? cachedReminder : true;
    }
    getProfile();
  }

  Future<void> getProfile({bool force = false}) async {
    if (!force && name.value.isNotEmpty) return;
    try {
      isLoading.value = true;

      final token = box.read("token");
      if (token == null) {
        await AuthService.logout();
        return;
      }

      final response = await http.get(
        Uri.parse("$baseUrl/api/auth/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 401) {
        await AuthService.logout();
        return;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          name.value = data["full_name"] ?? "";
          bio.value = data["bio"] ?? "";
          imageUrl.value = data["image_url"] ?? "";

          if (data["service_reminder_enabled"] != null) {
            final enabled = data["service_reminder_enabled"] == true;
            isReminderEnabled.value = enabled;
            box.write("service_reminder_enabled", enabled);
          }
        }
      }
    } catch (e) {
      debugPrint("Error getProfile: $e");
      ConnectivityService.handleNetworkError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleReminder(bool value) async {
    isReminderEnabled.value = value;
    box.write("service_reminder_enabled", value);

    try {
      final token = box.read("token");
      if (token == null) return;

      final response = await http
          .put(
            Uri.parse("$baseUrl/api/auth/reminder-toggle"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode({"enabled": value}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        debugPrint("Gagal sync status pengingat: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error toggleReminder: $e");
    }
  }
}
