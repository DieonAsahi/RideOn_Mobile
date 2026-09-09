import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailverController extends GetxController {
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

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
      // ================= CHECK EMAIL =================
      final checkUrl = Uri.parse("$baseUrl/api/auth/check-email");

      final checkResponse = await http.post(
        checkUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final checkData = jsonDecode(checkResponse.body);

      // EMAIL TIDAK ADA
      if (checkResponse.statusCode != 200) {
        Get.snackbar("Error", checkData['error']);
        return;
      }

      // ================= KIRIM OTP =================
      final resendUrl = Uri.parse("$baseUrl/api/auth/resend-otp");

      final response = await http.post(
        resendUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "type": "email"}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar("Success", data['message']);

        Get.toNamed('/otpemail', arguments: {"email": email, "from": fromPage});
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
