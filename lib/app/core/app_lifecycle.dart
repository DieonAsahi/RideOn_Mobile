import 'package:flutter/widgets.dart';
import 'package:get_storage/get_storage.dart';

import 'package:capbatu/app/services/auth_service.dart';
import 'package:capbatu/app/services/local_notification_service.dart';

class AppLifecycle extends WidgetsBindingObserver {
  final box = GetStorage();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final token = box.read("token");

    // Saat aplikasi ditutup atau masuk ke background
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      box.write("last_closed", DateTime.now().toIso8601String());
      // Setel local notification tepat 24 jam setelah aplikasi ditutup
      // (Berlaku untuk user login, user logout, maupun baru download belum login)
      await LocalNotificationService.scheduleInactivityReminder();
    }

    // Saat user membuka aplikasi kembali
    if (state == AppLifecycleState.resumed) {
      // Batalkan local notification pengingat inaktivitas
      await LocalNotificationService.cancelInactivityReminder();

      final last = box.read("last_closed");

      // Auto-Logout jika user yang sedang login tidak membuka aplikasi selama >= 24 jam
      if (token != null && token.toString().isNotEmpty && last != null) {
        final diff = DateTime.now().difference(DateTime.parse(last));

        if (diff >= const Duration(hours: 24)) {
          await AuthService.logout();
          return;
        }
      }

      // Perbarui waktu aktif terakhir
      box.write("last_closed", DateTime.now().toIso8601String());
    }
  }
}