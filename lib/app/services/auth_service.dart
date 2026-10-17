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
    await LogoutProgressDialog.show();

    try {
      final box = GetStorage();

      // 1. Lepas relasi akun, tetapi pertahankan token untuk mode guest.
      try {
        await FirebaseMessagingService.disassociateTokenFromUser();
      } catch (_) {}

      // 2. Batalkan local notification inactivity jika ada
      try {
        await LocalNotificationService.cancelInactivityReminder();
      } catch (_) {}

      try {
        final serverClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID'];
        final googleSignIn = GoogleSignIn(serverClientId: serverClientId);
        await googleSignIn.signOut();
      } catch (_) {}

      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}

      await box.remove("token");
      await box.remove("user");
      await box.remove("vehicle_id");
      await box.write("last_closed", DateTime.now().toIso8601String());
      await box.remove("pending_notification_vehicle_id");
      await box.remove("pending_notification_id");

      // Setel reminder inaktivitas agar user yang logout tetap diingatkan jika 24 jam tidak buka aplikasi
      try {
        await LocalNotificationService.scheduleInactivityReminder();
      } catch (_) {}

      Get.offAllNamed('/login');
    } finally {
      if (Get.isDialogOpen == true) Get.back();
      _isLoggingOut = false;
    }
  }
}
