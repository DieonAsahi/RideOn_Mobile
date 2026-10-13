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

class LoginController extends GetxController with GetTickerProviderStateMixin {
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final box = GetStorage();

  var isLoggingIn = false.obs;

  // State untuk Toggle UI Password
  var isObscure = true.obs;

  // State untuk Error Validasi Form
  var emailError = RxnString();
  var passwordError = RxnString();

  // Variabel Animasi UI
  late AnimationController sheetAnimController;
  late Animation<Offset> sheetOffsetAnim;
  late AnimationController logoAnimController;
  late Animation<Offset> logoOffsetAnim;

  @override
  void onInit() {
    super.onInit();

    // 1. Setup Animasi Container Putih (Durasi diperlama jadi 1.2 detik agar santai)
    sheetAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    // Dimulai dari Offset(0, 1.5) yang memastikan container benar-benar bersembunyi di bawah layar
    sheetOffsetAnim =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: sheetAnimController,
            curve: Curves
                .fastOutSlowIn, // Curve yang memberikan efek cepat di awal lalu melambat halus di akhir
          ),
        );

    // 2. Setup Animasi Logo
    logoAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Durasi logo 1.5 detik
    );
    logoOffsetAnim =
        Tween<Offset>(begin: const Offset(0, 1.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: logoAnimController,
            curve: Curves.fastOutSlowIn,
          ),
        );
  }

  // Dipanggil otomatis oleh GetX SETELAH layar pertama kali selesai di-render
  @override
  void onReady() {
    super.onReady();

    // Beri jeda 400ms agar layar biru polos terlihat sejenak, baru container naik
    Future.delayed(const Duration(milliseconds: 400), () {
      sheetAnimController.forward();

      // Beri jeda lagi 500ms agar logo menyusul naik saat container masih di tengah perjalanan
      Future.delayed(const Duration(milliseconds: 500), () {
        logoAnimController.forward();
      });
    });
  }

  void togglePasswordVisibility() {
    isObscure.value = !isObscure.value;
  }

  // ================= LOGIKA LOGIN (TETAP SAMA) ================= //

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

    emailError.value = null;
    passwordError.value = null;
    bool isValid = true;

    // Validasi Email
    if (email.isEmpty) {
      emailError.value = "Email tidak boleh kosong";
      isValid = false;
    } else if (!email.contains('@')) {
      emailError.value = "Format email tidak valid (harus memakai @)";
      isValid = false;
    }

    // Validasi Sandi
    if (password.isEmpty) {
      passwordError.value = "Kata sandi tidak boleh kosong";
      isValid = false;
    } else if (password.length < 8) {
      passwordError.value = "Kata sandi minimal 8 karakter";
      isValid = false;
    } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
      passwordError.value = "Kata sandi harus berisi huruf besar, huruf kecil, dan angka";
      isValid = false;
    }

    if (!isValid) return;

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
    }
  }

  Future<void> loginGoogle() async {
    try {
      isLoggingIn.value = true;
      final serverClientId =
          dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ??
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
    sheetAnimController.dispose();
    logoAnimController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}