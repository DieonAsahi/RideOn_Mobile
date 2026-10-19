import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:capbatu/app/services/connectivity_service.dart';
import 'package:capbatu/app/widgets/app_snackbar.dart';
import 'package:capbatu/app/widgets/otp_limit_dialog.dart';
import 'package:capbatu/app/widgets/app_feedback_widgets.dart';

class RegisterController extends GetxController {
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // State untuk Toggle UI Password
  var isPasswordObscure = true.obs;
  var isConfirmPasswordObscure = true.obs;
  var isRegistering = false.obs;

  // State untuk Error Validasi Form
  var nameError = RxnString();
  var emailError = RxnString();
  var passwordError = RxnString();
  var confirmPasswordError = RxnString();

  void togglePasswordVisibility() {
    isPasswordObscure.value = !isPasswordObscure.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordObscure.value = !isConfirmPasswordObscure.value;
  }

  void register() async {
    if (isRegistering.value) return;

    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    // Reset error text
    nameError.value = null;
    emailError.value = null;
    passwordError.value = null;
    confirmPasswordError.value = null;
    bool isValid = true;

    // --- VALIDASI NAMA ---
    if (name.isEmpty) {
      nameError.value = "Nama tidak boleh kosong";
      isValid = false;
    }

    // --- VALIDASI EMAIL ---
    if (email.isEmpty) {
      emailError.value = "Email tidak boleh kosong";
      isValid = false;
    } else if (!email.contains('@')) {
      emailError.value = "Format email tidak valid (harus memakai @)";
      isValid = false;
    }

    // --- VALIDASI KATA SANDI ---
    if (password.isEmpty) {
      passwordError.value = "Kata sandi tidak boleh kosong";
      isValid = false;
    } else if (password.length < 8) {
      passwordError.value = "Kata sandi minimal 8 karakter";
      isValid = false;
    } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
      passwordError.value =
          "Kata sandi harus berisi huruf besar, huruf kecil, dan angka";
      isValid = false;
    }

    // --- VALIDASI KONFIRMASI KATA SANDI ---
    if (confirmPassword.isEmpty) {
      confirmPasswordError.value = "Konfirmasi kata sandi tidak boleh kosong";
      isValid = false;
    } else if (password != confirmPassword) {
      confirmPasswordError.value = "Kata sandi tidak cocok";
      isValid = false;
    }

    if (!isValid) return;

    isRegistering.value = true;
    try {
      final url = Uri.parse("$baseUrl/api/auth/register");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "full_name": name,
          "email": email,
          "password": password,
          "confirm_password": confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        AppSnackbar.success(data['message'] ?? "Register berhasil.");

        Get.toNamed(
          '/otpemail',
          arguments: {"email": email, "from": "register"},
        );
      } else {
        if (response.statusCode == 429 ||
            data['is_rate_limit'] == true ||
            OtpLimitDialog.isOtpLimitError(
              data['error'],
              statusCode: response.statusCode,
            )) {
          OtpLimitDialog.show(customTime: data['reset_time']?.toString());
        } else {
          AppFeedback.registerFailed(
            message: data['message'] ?? data['error'] ?? 'Register gagal.',
          );
        }
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        AppFeedback.registerFailed(
          message: 'Gagal mendaftar, periksa koneksi Anda.',
        );
      }
    } finally {
      isRegistering.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
