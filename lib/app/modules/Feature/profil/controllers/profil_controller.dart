import 'dart:convert';
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

  @override
  void onInit() {
    super.onInit();
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
        }
      }
    } catch (e) {
      print("Error getProfile: $e");
      ConnectivityService.handleNetworkError(e);
    } finally {
      isLoading.value = false;
    }
  }
}
