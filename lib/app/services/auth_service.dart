import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_messaging_service.dart';
import 'local_notification_service.dart';
import '../widgets/app_feedback_widgets.dart';

class AuthService {
  static bool _isLoggingOut = false;

  static Future<void> logout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      // Tutup dialog konfirmasi / dialog lain yang masih aktif sebelumnya
      int preCloseAttempts = 0;
      while (Get.isDialogOpen == true && preCloseAttempts < 5) {
        Get.back();
        preCloseAttempts++;
      }

      // 1. Tampilkan dialog loading "Sedang keluar..."
      // JANGAN DI-AWAIT agar tidak memblokir eksekusi!
      LogoutProgressDialog.show();

      // 2. Kumpulkan seluruh remote calls (FCM, Supabase, Google, LocalNotification)
      final List<Future<dynamic>> remoteCalls = [];

      // a. Lepas relasi FCM di backend
      remoteCalls.add(
        FirebaseMessagingService.disassociateTokenFromUser().catchError((_) {}),
      );

      // b. Batalkan reminder lokal
      remoteCalls.add(
        LocalNotificationService.cancelInactivityReminder().catchError((_) {}),
      );

      // c. Sign out Supabase
      remoteCalls.add(
        Supabase.instance.client.auth.signOut().catchError((_) {}),
      );

      // d. Sign out Google jika client id tersedia
      try {
        final serverClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID'];
        final googleSignIn = GoogleSignIn(serverClientId: serverClientId);
        remoteCalls.add(
          googleSignIn.signOut().catchError((_) => null),
        );
      } catch (_) {}

      // Jalankan seluruh remote calls secara paralel dengan batas waktu KETAT 3 DETIK.
      // Jika lewat 3 detik, fungsi ini akan melempar TimeoutException dan langsung masuk catch.
      await Future.wait(remoteCalls).timeout(const Duration(seconds: 3));
    } catch (_) {
      // ABAIKAN SEMUA ERROR REMOTE! (Timeout, koneksi putus, server down)
      // Jangan biarkan error di sini menghentikan proses logout lokal.
    } finally {
      // 3. PEMBERSIHAN LOKAL (WAJIB TEREKSEKUSI)
      try {
        final box = GetStorage();
        await box.remove("token");
        await box.remove("user");
        await box.remove("vehicle_id");
        await box.write("last_closed", DateTime.now().toIso8601String());
        await box.remove("pending_notification_vehicle_id");
        await box.remove("pending_notification_id");
      } catch (_) {}

      // Jadwalkan reminder inaktivitas baru (fire & forget)
      try {
        LocalNotificationService.scheduleInactivityReminder();
      } catch (_) {}

      // 4. TUTUP DIALOG LOADING DENGAN AMAN
      int closeAttempts = 0;
      while (Get.isDialogOpen == true && closeAttempts < 5) {
        Get.back();
        closeAttempts++;
      }

      _isLoggingOut = false;

      // 5. PAKSA PINDAH KE LOGIN
      Get.offAllNamed('/login');
    }
  }
}
