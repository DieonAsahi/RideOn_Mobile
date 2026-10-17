import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:capbatu/app/services/connectivity_service.dart';
import 'package:capbatu/app/widgets/app_snackbar.dart';
import 'package:capbatu/app/widgets/otp_limit_dialog.dart';

class EmailverController extends GetxController {
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  final emailController = TextEditingController();
  bool fromProfile = false;
  String fromPage = 'forgot';

  // State untuk menyimpan pesan error
  var emailError = RxnString();

  Future<void> sendOtp() async {
    final email = emailController.text.trim();

    // Reset error text setiap kali tombol ditekan
    emailError.value = null;
    bool isValid = true;

    // Validasi kosong
    if (email.isEmpty) {
      emailError.value = "Email tidak boleh kosong";
      isValid = false;
    }
    // Validasi format email yang benar (berisi @ dan domain valid)
    else if (!GetUtils.isEmail(email)) {
      emailError.value = "Format email tidak valid (contoh: nama@email.com)";
      isValid = false;
    }

    // Hentikan eksekusi API jika validasi gagal
    if (!isValid) return;

    try {
      // ================= CHECK EMAIL =================
      final checkUrl = Uri.parse("$baseUrl/api/auth/check-email");

      final checkResponse = await http.post(
        checkUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final checkData = jsonDecode(checkResponse.body);

      // EMAIL TIDAK ADA / ERROR LAINNYA
      if (checkResponse.statusCode != 200) {
        emailError.value =
            checkData['message'] ??
            checkData['error'] ??
            'Email tidak ditemukan.';
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
        AppSnackbar.success(
          data['message'] ?? "Email verifikasi berhasil dikirim.",
        );

        Get.toNamed('/otpemail', arguments: {"email": email, "from": fromPage});
      } else {
        if (response.statusCode == 429 ||
            data['is_rate_limit'] == true ||
            OtpLimitDialog.isOtpLimitError(
              data['error'],
              statusCode: response.statusCode,
            )) {
          OtpLimitDialog.show(customTime: data['reset_time']?.toString());
        } else {
          emailError.value =
              data['message'] ?? data['error'] ?? 'Gagal mengirim kode OTP.';
        }
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        emailError.value = 'Tidak bisa terhubung ke server. Silakan coba lagi.';
      }
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
