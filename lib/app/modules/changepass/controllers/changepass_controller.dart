import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../services/connectivity_service.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/app_feedback_widgets.dart';

class ChangepassController extends GetxController {
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  final oldPassController =
      TextEditingController(); // Tambahan untuk sandi lama
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();

  String accessToken = '';
  String refreshToken = '';
  bool isFromProfile = false;

  final isLoading = false.obs;

  // State untuk Toggle UI Password
  var isOldPassObscure = true.obs;
  var isNewPassObscure = true.obs;
  var isConfirmPassObscure = true.obs;

  // State untuk Error Validasi Form
  var oldPassError = RxnString();
  var newPassError = RxnString();
  var confirmPassError = RxnString();

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      accessToken = Get.arguments['access_token'] ?? '';
      refreshToken = Get.arguments['refresh_token'] ?? '';
      isFromProfile = Get.arguments['from_profile'] ?? false;
    }
  }

  void toggleOldPassVisibility() =>
      isOldPassObscure.value = !isOldPassObscure.value;
  void toggleNewPassVisibility() =>
      isNewPassObscure.value = !isNewPassObscure.value;
  void toggleConfirmPassVisibility() =>
      isConfirmPassObscure.value = !isConfirmPassObscure.value;

  void changePassword() async {
    if (isLoading.value) return;

    String oldPass = oldPassController.text;
    String newPass = newPassController.text;
    String confirmPass = confirmPassController.text;

    // Reset error text
    oldPassError.value = null;
    newPassError.value = null;
    confirmPassError.value = null;
    bool isValid = true;

    // Validasi Sandi Lama (Hanya jika dari profil)
    if (isFromProfile) {
      if (oldPass.isEmpty) {
        oldPassError.value = "Kata sandi lama tidak boleh kosong";
        isValid = false;
      } else if (oldPass.length < 8) {
        oldPassError.value = "Kata sandi minimal 8 karakter";
        isValid = false;
      } else if (oldPass.length > 15) {
        oldPassError.value = "Kata sandi maksimal 15 karakter";
        isValid = false;
      }
    }

    // Validasi Sandi Baru
    if (newPass.isEmpty) {
      newPassError.value = "Kata sandi baru tidak boleh kosong";
      isValid = false;
    } else if (newPass.length < 8) {
      newPassError.value = "Kata sandi minimal 8 karakter";
      isValid = false;
    } else if (newPass.length > 15) {
      newPassError.value = "Kata sandi maksimal 15 karakter";
      isValid = false;
    } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(newPass)) {
      newPassError.value = "Harus berisi huruf besar, huruf kecil, dan angka";
      isValid = false;
    }

    // Validasi Konfirmasi Sandi Baru
    if (confirmPass.isEmpty) {
      confirmPassError.value = "Konfirmasi kata sandi tidak boleh kosong";
      isValid = false;
    } else if (newPass != confirmPass) {
      confirmPassError.value = "Konfirmasi kata sandi tidak cocok";
      isValid = false;
    }

    if (!isValid) return;

    try {
      isLoading.value = true;
      final url = Uri.parse("$baseUrl/api/auth/update-password");

      // Siapkan payload
      Map<String, dynamic> payload = {
        "access_token": accessToken,
        "refresh_token": refreshToken,
        "new_password": newPass,
      };

      // Tambahkan old_password jika perubahan dilakukan dari dalam profil
      if (isFromProfile) {
        payload["old_password"] = oldPass;
      }

      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(response.body);
      } catch (_) {}

      if (response.statusCode == 200) {
        AppSnackbar.success(data['message'] ?? "Password berhasil diubah.");

        if (isFromProfile) {
          Get.offNamed('/profil');
        } else {
          Get.offNamed('/login');
        }
      } else {
        AppFeedback.passwordChangeFailed(
          message:
              data['message'] ?? data['error'] ?? 'Gagal mengubah kata sandi.',
        );
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        AppFeedback.passwordChangeFailed(
          message: 'Gagal mengubah kata sandi, periksa koneksi Anda.',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    oldPassController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();
    super.onClose();
  }
}
