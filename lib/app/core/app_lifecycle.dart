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
      if (token != null && token.toString().isNotEmpty) {
        box.write("last_closed", DateTime.now().toIso8601String());
        // Setel local notification tepat 24 jam setelah aplikasi ditutup
        await LocalNotificationService.scheduleInactivityReminder();
      }
    }

    // Saat user membuka aplikasi kembali
    if (state == AppLifecycleState.resumed) {
      // Batalkan local notification pengingat inaktivitas
      await LocalNotificationService.cancelInactivityReminder();

      if (token != null && token.toString().isNotEmpty) {
        final last = box.read("last_closed");

        if (last != null) {
          final diff = DateTime.now().difference(DateTime.parse(last));

          // Auto-Logout jika user tidak membuka aplikasi selama 1x24 jam
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
}