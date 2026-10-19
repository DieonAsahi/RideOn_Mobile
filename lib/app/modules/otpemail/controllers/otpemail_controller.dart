import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:capbatu/app/services/connectivity_service.dart';
import 'package:capbatu/app/widgets/app_snackbar.dart';
import 'package:capbatu/app/widgets/otp_limit_dialog.dart';

class OtpemailController extends GetxController {
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  final otp = List.generate(6, (_) => ''.obs);
  final focusNodes = List.generate(6, (_) => FocusNode());
  final controllers = List.generate(6, (_) => TextEditingController());

  var otpExpiredSeconds = 180.obs;
  var isOtpExpired = false.obs;
  var isCooldown = false.obs;
  var secondsRemaining = 0.obs;
  final isVerifyingOtp = false.obs;
  final isResendingOtp = false.obs;

  // State untuk menyimpan error text OTP
  var otpError = RxnString();

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

  String getMaskedEmail() {
    if (email.isEmpty || !email.contains('@')) return email;
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 3) {
      return "${name.substring(0, 1)}***@$domain";
    }
    return "${name.substring(0, 3)}****@$domain";
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
    // Hapus error saat user mulai mengetik ulang
    otpError.value = null;

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
    if (isVerifyingOtp.value || isResendingOtp.value) return;

    otpError.value = null;

    if (fullOtp.length < 6) {
      otpError.value = "Kode OTP belum lengkap (6 digit)";
      return;
    }

    if (isOtpExpired.value) {
      otpError.value = "Kode OTP sudah kadaluarsa";
      return;
    }

    String type = 'signup';

    if (fromPage == 'forgot' || fromPage == 'profile') {
      type = "recovery";
    }

    isVerifyingOtp.value = true;
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
        // Ganti pesan error dari server dengan pesan kustom berbahasa Indonesia
        String serverError = (data['message'] ?? data['error'] ?? '')
            .toString()
            .toLowerCase();

        // Opsional: Cek jika error spesifik terkait expired/invalid
        if (serverError.contains('expired') ||
            serverError.contains('invalid')) {
          otpError.value = 'Kode OTP salah atau sudah tidak berlaku.';
        } else {
          otpError.value =
              'Verifikasi gagal. Silakan periksa kembali kode OTP Anda.';
        }
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        otpError.value = 'Tidak bisa terhubung ke server. Silakan coba lagi.';
      }
    } finally {
      isVerifyingOtp.value = false;
    }
  }

  void resendOtp() async {
    if (isCooldown.value || isResendingOtp.value || isVerifyingOtp.value) {
      return;
    }

    if (email.isEmpty) {
      otpError.value = 'Email tidak tersedia. Kembali dan masukkan email Anda.';
      return;
    }

    String type = 'signup';
    if (fromPage == 'forgot' || fromPage == 'profile') {
      type = "email";
    }

    isResendingOtp.value = true;
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

        // Bersihkan error jika sebelumnya ada
        otpError.value = null;

        startCooldown(180);
        startOtpExpiredTimer();
      } else {
        if (response.statusCode == 429 ||
            data['code'] == 'OTP_RATE_LIMIT' ||
            data['is_rate_limit'] == true ||
            OtpLimitDialog.isOtpLimitError(
              data['error'] ?? data['message'],
              statusCode: response.statusCode,
            )) {
          OtpLimitDialog.show(customTime: data['reset_time']?.toString());
        } else {
          otpError.value =
              data['message'] ?? data['error'] ?? 'Gagal mengirim ulang OTP.';
        }
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        otpError.value = 'Gagal mengirim ulang OTP. Silakan coba lagi.';
      }
    } finally {
      isResendingOtp.value = false;
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
