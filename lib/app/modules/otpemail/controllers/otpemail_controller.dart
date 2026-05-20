import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OtpemailController extends GetxController {
  final otp = List.generate(6, (_) => ''.obs);
  final focusNodes = List.generate(6, (_) => FocusNode());
  final controllers = List.generate(6, (_) => TextEditingController());

  var isCooldown = false.obs;
  var secondsRemaining = 0.obs;

  String fromPage = 'register';
  String email = '';
  String get fullOtp => otp.map((e) => e.value).join();

  @override
  void onInit() {
    super.onInit();
    startCooldown(180);
    clearOtp();

    if (Get.arguments != null) {
      email = Get.arguments['email'] ?? '';
      fromPage = Get.arguments['from'] ?? 'register';
    }
  }

  void startCooldown([int seconds = 180]) {
    isCooldown.value = true;
    secondsRemaining.value = seconds;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      secondsRemaining.value--;

      return secondsRemaining.value > 0;
    }).then((_) {
      isCooldown.value = false;
    });
  }

  void onChanged(int index, String value) {
    if (value.isNotEmpty) {
      otp[index].value = value;
      if (index < 5) {
        focusNodes[index + 1].requestFocus();
      }
    } else {
      if (index > 0) {
        focusNodes[index - 1].requestFocus();
      }
    }
  }

  void verifyOtp() async {
    if (fullOtp.length < 6) {
      Get.snackbar("Error", "OTP belum lengkap");
      return;
    }

    String type = 'signup';

    if (fromPage == 'forgot' || fromPage == 'profile') {
      type = "email";
    }

    try {
      final url = Uri.parse(
        "https://hireable-unelegant-linwood.ngrok-free.dev/verify-otp",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": fullOtp, "type": type}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar("Success", data['message']);

        if (fromPage == 'register') {
          Get.offAllNamed('/login');
        } else if (fromPage == 'forgot' || fromPage == 'profile') {
          Get.toNamed(
            '/changepass',
            arguments: {
              "access_token": data['session']['access_token'],

              "from_profile": fromPage == 'profile',
            },
          );
        }
      } else {
        Get.snackbar("Error", data['error']);
      }
    } catch (e) {
      Get.snackbar("Error", "Tidak bisa konek ke server");
    }
  }

  void resendOtp() async {
    if (isCooldown.value) return; // 🔥 cegah spam

    if (email.isEmpty) {
      Get.snackbar("Error", "Email kosong");
      return;
    }

    String type = 'signup';
    if (fromPage == 'forgot' || fromPage == 'profile') {
      type = "email";
    }

    try {
      final url = Uri.parse(
        "https://hireable-unelegant-linwood.ngrok-free.dev/resend-otp",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "type": type}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar("Success", data['message']);
        clearOtp();

        startCooldown(180); // 🔥 mulai cooldown
      } else {
        Get.snackbar("Error", data['error']);
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal kirim ulang OTP");
    }
  }

  void clearOtp() {
    for (var c in controllers) {
      c.clear();
    }

    for (var o in otp) {
      o.value = '';
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      focusNodes[0].requestFocus();
    });
  }

  @override
  void onClose() {
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}
