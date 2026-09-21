import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../services/firebase_messaging_service.dart';

class LoginController extends GetxController {
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final box = GetStorage();

  Future<void> checkVehicle() async {
    try {
      if (await FirebaseMessagingService.openPendingNotificationAfterLogin()) {
        return;
      }

      final token = box.read("token");
      print("TOKEN:");
      print(token);

      final response = await http.get(
        Uri.parse("$baseUrl/api/vehicle/my-vehicle"),
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
        Get.offNamed('/pluskendaraan', arguments: true);
      }
    } catch (e) {
      print(e);
      Get.offNamed('/pluskendaraan', arguments: true);
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
      final url = Uri.parse("$baseUrl/api/auth/login");

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

        await box.write("token", token);
        await FirebaseMessagingService.syncToken();

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

  Future<void> loginGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId:
            '223603698019-imou4debdr194jicsps6aalvl22lmls1.apps.googleusercontent.com',
      );

      // TAMBAHKAN INI
      await googleSignIn.signOut();
      // Kalau masih otomatis pilih akun, gunakan disconnect juga
      // await googleSignIn.disconnect();

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print("USER CANCEL LOGIN");
        return;
      }

      final googleAuth = await googleUser.authentication;

      final idToken = googleAuth.idToken;

      if (idToken == null) {
        print("ID TOKEN NULL");
        return;
      }

      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      final token = response.session?.accessToken;

      if (token == null) {
        print("TOKEN NULL");
        return;
      }

      await box.write("token", token);
      await FirebaseMessagingService.syncToken();

      await syncGoogleUser();
      await checkVehicle();
    } catch (e, s) {
      print(e);
      print(s);
    }
  }

  Future<void> syncGoogleUser() async {
    final token = box.read("token");

    await http.post(
      Uri.parse("$baseUrl/api/auth/google-sync"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
