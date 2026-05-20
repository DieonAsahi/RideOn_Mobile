import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterController extends GetxController {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void register() async {
    if (emailController.text.isEmpty ||
        nameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar("Error", "All fields are required");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    try {
      final url = Uri.parse(
        "https://hireable-unelegant-linwood.ngrok-free.dev/register",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "full_name": nameController.text,
          "email": emailController.text,
          "password": passwordController.text,
          "confirm_password": confirmPasswordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar("Success", data['message'] ?? "Register berhasil");

        Get.toNamed(
          '/otpemail',
          arguments: {"email": emailController.text, "from": "register"},
        );
      } else {
        Get.snackbar("Error", data['error'] ?? "Register gagal");
      }
    } catch (e) {
      Get.snackbar("Error", "Tidak bisa konek ke server");
      print(e);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
