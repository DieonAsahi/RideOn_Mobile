import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../services/firebase_messaging_service.dart';
import '../../../services/local_notification_service.dart';
import '../../../services/connectivity_service.dart';

class LoginController extends GetxController {
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final box = GetStorage();

  var isLoggingIn = false.obs;

  Future<void> checkVehicle() async {
    try {
      if (await FirebaseMessagingService.openPendingNotificationAfterLogin()) {
        return;
      }

      final token = box.read("token");
      final response = await http.get(
        Uri.parse("$baseUrl/api/vehicle/my-vehicle"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final vehicle = jsonDecode(response.body);
        box.write("vehicle_id", vehicle["id"]);
        Get.offNamed('/mainscreen');
      } else {
        Get.offNamed('/pluskendaraan', arguments: true);
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        Get.offNamed('/pluskendaraan', arguments: true);
      }
    }
  }

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email dan Password tidak boleh kosong");
      return;
    }

    try {
      isLoggingIn.value = true;
      final url = Uri.parse("$baseUrl/api/auth/login");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data["session"]["access_token"];

        await box.write("token", token);
        await box.write("last_closed", DateTime.now().toIso8601String());
        await LocalNotificationService.cancelInactivityReminder();
        await FirebaseMessagingService.syncToken();

        await checkVehicle();
      } else {
        isLoggingIn.value = false;
        Get.snackbar("Error", data['error'] ?? "Login gagal");
      }
    } catch (e) {
      isLoggingIn.value = false;
      if (!ConnectivityService.handleNetworkError(e)) {
        Get.snackbar("Error", "Tidak bisa terhubung ke server");
      }
    } finally {
      // isLoggingIn will turn false automatically when navigating away
    }
  }

  Future<void> loginGoogle() async {
    try {
      isLoggingIn.value = true;
      final serverClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ??
          '223603698019-imou4debdr194jicsps6aalvl22lmls1.apps.googleusercontent.com';
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: serverClientId,
      );

      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        isLoggingIn.value = false;
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        isLoggingIn.value = false;
        Get.snackbar("Error", "Gagal mendapatkan token Google");
        return;
      }

      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      final token = response.session?.accessToken;

      if (token == null) {
        isLoggingIn.value = false;
        Get.snackbar("Error", "Autentikasi gagal");
        return;
      }

      await box.write("token", token);
      await box.write("last_closed", DateTime.now().toIso8601String());
      await LocalNotificationService.cancelInactivityReminder();
      await FirebaseMessagingService.syncToken();

      await syncGoogleUser();
      await checkVehicle();
    } catch (e) {
      isLoggingIn.value = false;
      if (!ConnectivityService.handleNetworkError(e)) {
        Get.snackbar("Error", "Terjadi kesalahan saat login Google");
      }
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
