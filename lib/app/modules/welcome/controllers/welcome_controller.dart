import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:capbatu/app/services/auth_service.dart';
import 'package:capbatu/app/services/local_notification_service.dart';

class WelcomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final box = GetStorage();

  late AnimationController animController;
  late Animation<Offset> slideAnimation;
  late Animation<double> tiltAnimation;

  // Variabel Animasi Asap
  late Animation<double> smokeOpacity;
  late Animation<double> smokeScale;

  @override
  void onInit() {
    super.onInit();

    animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // 1. Animasi Meluncur
    slideAnimation =
        Tween<Offset>(begin: const Offset(-1.5, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: animController, curve: Curves.easeOutBack),
        );

    // 2. Animasi Jamping (Diperlama)
    tiltAnimation = TweenSequence<double>([
      // Fase 1: Tarikan awal, ban depan ngangkat (agak cepat)
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: -0.22,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 15,
      ),
      // Fase 2: TAHAN JAMPING AGAK LAMA (50% dari waktu total)
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.22, end: -0.22),
        weight: 50,
      ),
      // Fase 3: Roda depan turun dan mantul saat ngerem
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -0.22,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 35,
      ),
    ]).animate(animController);

    // 3. Efek Asap (Opacity)
    smokeOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.9),
        weight: 15, // Cepat muncul saat digas
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.9,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 85, // Memudar perlahan-lahan ditiup angin
      ),
    ]).animate(animController);

    // 4. Efek Asap (Membesar)
    smokeScale = Tween<double>(begin: 0.5, end: 4.5).animate(
      CurvedAnimation(parent: animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void onReady() async {
    super.onReady();

    await Future.delayed(const Duration(milliseconds: 300));
    animController.forward();

    await Future.delayed(const Duration(milliseconds: 2800));
    _runStartupLogic();
  }

  void _runStartupLogic() {
    final isFirstInstall = box.read("first_install") ?? true;
    final token = box.read("token");
    final lastClosedStr = box.read("last_closed");

    if (lastClosedStr != null) {
      final lastClosed = DateTime.tryParse(lastClosedStr);
      if (lastClosed != null) {
        final diff = DateTime.now().difference(lastClosed);
        if (diff >= const Duration(hours: 24)) {
          AuthService.logout();
          return;
        }
      }
    }

    // Aplikasi dibuka kembali, batalkan inactivity reminder
    LocalNotificationService.cancelInactivityReminder();

    if (isFirstInstall) {
      Get.offAllNamed("/onboarding");
      return;
    }

    if (token != null && token.toString().isNotEmpty) {
      box.write("last_closed", DateTime.now().toIso8601String());
      _checkVehicleAndRoute(token.toString());
    } else {
      Get.offAllNamed("/login");
    }
  }

  Future<void> _checkVehicleAndRoute(String token) async {
    try {
      final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];
      final response = await http
          .get(
            Uri.parse("$baseUrl/api/vehicle/my-vehicle"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 7));

      if (response.statusCode == 401) {
        await AuthService.logout();
        return;
      }

      if (response.statusCode == 200) {
        final vehicle = jsonDecode(response.body);
        if (vehicle != null && vehicle["id"] != null) {
          box.write("vehicle_id", vehicle["id"]);
          Get.offAllNamed("/mainscreen");
          return;
        }
      }
      await AuthService.logout();
    } catch (e) {
      print("Error checking vehicle on app launch: $e");
      final storedVehicleId = box.read("vehicle_id");
      if (storedVehicleId != null && storedVehicleId.toString().isNotEmpty) {
        Get.offAllNamed("/mainscreen");
      } else {
        await AuthService.logout();
      }
    }
  }

  @override
  void onClose() {
    animController.dispose();
    super.onClose();
  }
}