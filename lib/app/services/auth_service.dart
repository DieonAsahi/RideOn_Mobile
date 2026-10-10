import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_messaging_service.dart';
import 'local_notification_service.dart';

class AuthService {
  static bool _isLoggingOut = false;

  static Future<void> logout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      final box = GetStorage();

      // 1. Hapus FCM Token dari database backend dan hapus token instance perangkat
      try {
        await FirebaseMessagingService.deleteTokenFromServer();
      } catch (e) {
        print('Error deleting FCM token during logout: $e');
      }

      // 2. Batalkan local notification inactivity jika ada
      try {
        await LocalNotificationService.cancelInactivityReminder();
      } catch (_) {}

      try {
        final serverClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID'];
        final googleSignIn = GoogleSignIn(
          serverClientId: serverClientId,
        );
        await googleSignIn.signOut();
      } catch (_) {}

      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}

      await box.remove("token");
      await box.remove("user");
      await box.remove("vehicle_id");
      await box.remove("last_closed");
      await box.remove("pending_notification_vehicle_id");
      await box.remove("pending_notification_id");

      Get.offAllNamed('/login');
    } finally {
      _isLoggingOut = false;
    }
  }
}
