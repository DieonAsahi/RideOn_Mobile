import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:capbatu/app/services/connectivity_service.dart';
import 'package:capbatu/app/widgets/app_snackbar.dart';

class OtpemailController extends GetxController {
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  final otp = List.generate(6, (_) => ''.obs);
  final focusNodes = List.generate(6, (_) => FocusNode());
  final controllers = List.generate(6, (_) => TextEditingController());
  var otpExpiredSeconds = 180.obs;
  var isOtpExpired = false.obs;
  var isCooldown = false.obs;
  var secondsRemaining = 0.obs;

  String fromPage = 'register';
  String email = '';
  String get fullOtp => otp.map((e) => e.value).join();

  @override
  void onInit() {
    super.onInit();
    startCooldown(180);
    startOtpExpiredTimer();
    clearOtp();

    if (Get.arguments != null) {
      email = Get.arguments['email'] ?? '';
      fromPage = Get.arguments['from'] ?? 'register';
    }
  }

  void startOtpExpiredTimer([int seconds = 180]) {
    otpExpiredSeconds.value = seconds;
    isOtpExpired.value = false;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));

      otpExpiredSeconds.value--;

      return otpExpiredSeconds.value > 0;
    }).then((_) {
      isOtpExpired.value = true;
    });
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

    if (isOtpExpired.value) {
      Get.snackbar("Error", "OTP sudah kadaluarsa");
      return;
    }

    String type = 'signup';

    if (fromPage == 'forgot' || fromPage == 'profile') {
      type = "recovery";
    }

    try {
      final url = Uri.parse("$baseUrl/api/auth/verify-otp");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": fullOtp, "type": type}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        AppSnackbar.success(data['message'] ?? "Verifikasi OTP berhasil.");

        if (fromPage == 'register') {
          Get.offAllNamed('/login');
        } else if (fromPage == 'forgot' || fromPage == 'profile') {
          Get.offNamed(
            '/changepass',
            arguments: {
              "access_token": data['session']['access_token'],
              "refresh_token": data['session']['refresh_token'],

              "from_profile": fromPage == 'profile',
            },
          );
        }
      } else {
        Get.snackbar("Error", data['error']);
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        Get.snackbar("Error", "Tidak bisa konek ke server");
      }
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
      final url = Uri.parse("$baseUrl/api/auth/resend-otp");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "type": type}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        AppSnackbar.success(data['message'] ?? "OTP berhasil dikirim.");
        clearOtp();

        startCooldown(180);
        startOtpExpiredTimer();
      } else {
        Get.snackbar("Error", data['error']);
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        Get.snackbar("Error", "Gagal kirim ulang OTP");
      }
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
