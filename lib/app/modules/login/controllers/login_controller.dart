import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> loginGoogle() async {
    try {
      print("STEP 1");

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId:
            '223603698019-imou4debdr194jicsps6aalvl22lmls1.apps.googleusercontent.com',
      );

      print("STEP 2");

      final googleUser = await googleSignIn.signIn();

      print("GOOGLE USER:");
      print(googleUser?.email);

      if (googleUser == null) {
        print("USER CANCEL LOGIN");
        return;
      }

      final googleAuth = await googleUser.authentication;

      print("ACCESS TOKEN:");
      print(googleAuth.accessToken);

      print("ID TOKEN:");
      print(googleAuth.idToken);

      final idToken = googleAuth.idToken;

      if (idToken == null) {
        print("ID TOKEN NULL");
        return;
      }

      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      print("SUPABASE USER:");
      print(response.user);

      print("SUPABASE SESSION:");
      print(response.session);

      final token = response.session?.accessToken;

      print("ACCESS TOKEN SUPABASE:");
      print(token);

      if (token == null) {
        print("TOKEN NULL");
        return;
      }

      box.write("token", token);

      await syncGoogleUser();

      await checkVehicle();
    } catch (e, s) {
      print("GOOGLE LOGIN ERROR:");
      print(e);
      print(s);

      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> syncGoogleUser() async {
    final token = box.read("token");

    await http.post(
      Uri.parse(
        "https://hireable-unelegant-linwood.ngrok-free.dev/api/auth/google-sync",
      ),
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
