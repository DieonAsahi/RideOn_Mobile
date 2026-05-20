import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class EmailverController extends GetxController {
  final emailController = TextEditingController();
  bool fromProfile = false;
  String fromPage = 'forgot';

  Future<void> sendOtp() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar("Error", "Email wajib diisi");
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar("Error", "Format email tidak valid");
      return;
    }

    try {
      final url = Uri.parse(
        "https://hireable-unelegant-linwood.ngrok-free.dev/resend-otp",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "type": "email",
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar("Success", data['message']);

        // pindah ke halaman OTP
        Get.toNamed(
          '/otpemail',
          arguments: {"email": emailController.text.trim(), "from": fromPage},
        );
      } else {
        Get.snackbar("Error", data['error']);
      }
    } catch (e) {
      Get.snackbar("Error", "Tidak bisa konek ke server");
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      fromPage = Get.arguments['from'] ?? 'forgot';
    }
  }
}
