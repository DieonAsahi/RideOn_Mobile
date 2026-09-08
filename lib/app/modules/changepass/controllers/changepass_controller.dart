import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangepassController extends GetxController {
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

  void changePassword() async {
    if (newPassController.text.isEmpty || confirmPassController.text.isEmpty) {
      Get.snackbar("Error", "All fields are required");

      return;
    }

    if (newPassController.text.length < 8) {
      Get.snackbar("Error", "Password minimal 8 karakter");
      return;
    }

    if (newPassController.text != confirmPassController.text) {
      Get.snackbar("Error", "Password tidak sama");
      return;
    }
    try {
      final url = Uri.parse(
        "https://hireable-unelegant-linwood.ngrok-free.dev/api/auth/update-password",
      );

      final response = await http.post(
        url,

        headers: {"Content-Type": "application/json"},

        body: jsonEncode({
          "access_token": accessToken,
          "refresh_token": refreshToken,
          "new_password": newPassController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar("Success", data['message']);

        if (Get.arguments?['from_profile'] == true) {
          Get.offNamed('/profil');
        } else {
          Get.offNamed('/login');
        }
      } else {
        Get.snackbar("Error", data['error']);
      }
    } catch (e) {
      Get.snackbar("Error", "Tidak bisa konek ke server");
    }
  }

  @override
  void onClose() {
    newPassController.dispose();
    confirmPassController.dispose();

    super.onClose();
  }
}
