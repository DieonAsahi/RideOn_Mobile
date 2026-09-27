import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChangepassController extends GetxController {
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];
  
  final newPassController = TextEditingController();

  final confirmPassController = TextEditingController();

  String accessToken = '';
  String refreshToken = '';

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      accessToken = Get.arguments['access_token'] ?? '';
      refreshToken = Get.arguments['refresh_token'] ?? '';
    }
  }

  final isLoading = false.obs;

  void changePassword() async {
    if (isLoading.value) return;

    if (newPassController.text.isEmpty || confirmPassController.text.isEmpty) {
      Get.snackbar("Error", "Semua kolom wajib diisi");
      return;
    }

    if (newPassController.text.length < 8) {
      Get.snackbar("Error", "Password minimal 8 karakter");
      return;
    }

    if (newPassController.text != confirmPassController.text) {
      Get.snackbar("Error", "Konfirmasi password tidak cocok");
      return;
    }

    try {
      isLoading.value = true;
      final url = Uri.parse("$baseUrl/api/auth/update-password");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "access_token": accessToken,
          "refresh_token": refreshToken,
          "new_password": newPassController.text,
        }),
      ).timeout(const Duration(seconds: 15));

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(response.body);
      } catch (_) {}

      if (response.statusCode == 200) {
        Get.snackbar("Success", data['message'] ?? "Password berhasil diubah");

        if (Get.arguments?['from_profile'] == true) {
          Get.offNamed('/profil');
        } else {
          Get.offNamed('/login');
        }
      } else {
        Get.snackbar("Error", data['error'] ?? "Gagal mengubah password");
      }
    } catch (e) {
      print("Error update password: $e");
      Get.snackbar("Error", "Tidak bisa konek ke server. Silakan coba lagi.");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    newPassController.dispose();
    confirmPassController.dispose();

    super.onClose();
  }
}
