import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final box = GetStorage();

  Future<void> checkVehicle() async {
    try {
      final token = box.read("token");
      print("TOKEN:");
      print(token);

      final response = await http.get(
        Uri.parse(
          "https://hireable-unelegant-linwood.ngrok-free.dev/api/vehicle/my-vehicle",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        final vehicle = jsonDecode(response.body);

        box.write("vehicle_id", vehicle["id"]);

        Get.offNamed('/mainscreen');
      } else {
        Get.offAllNamed('/pluskendaraan', arguments: true);
      }
    } catch (e) {
      print(e);
      Get.offAllNamed('/pluskendaraan', arguments: true);
    }
  }

  void login() async {
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email and Password cannot be empty");
      return;
    }

    try {
      final url = Uri.parse(
        "https://hireable-unelegant-linwood.ngrok-free.dev/api/auth/login",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data["session"]["access_token"];

        box.write("token", token);

        Get.snackbar("Success", "Login berhasil");

        print(data);

        await checkVehicle();
      } else {
        Get.snackbar("Error", data['error'] ?? "Login gagal");
      }
    } catch (e) {
      Get.snackbar("Error", "Tidak bisa konek ke server");
      print(e);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
