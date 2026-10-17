import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'local_notification_service.dart';
import '../widgets/in_app_notification_banner.dart';
import '../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalNotificationService.init(requestPermission: false);
  await FirebaseMessagingService.showMessageNotification(message);
}

class FirebaseMessagingService {
  static const _installationIdKey = 'fcm_installation_id';

  static final FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    LocalNotificationService.onNotificationTap = _openNotification;
    // Permission
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('FCM permission: ${settings.authorizationStatus}');

    // Ambil token
    await syncToken();

    // Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('FCM FOREGROUND');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');

      await showMessageNotification(message);
      InAppNotificationBanner.show(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_openRemoteMessage);

    // Token berubah
    messaging.onTokenRefresh.listen((newToken) async {
      await syncToken(newToken);
    });
  }

  static Future<void> handleInitialMessage() async {
    final message = await messaging.getInitialMessage();
    if (message != null) await _openRemoteMessage(message);

    final localPayload = await LocalNotificationService.getLaunchPayload();
    if (localPayload != null) await _openNotification(localPayload);
  }

  static Future<void> showMessageNotification(RemoteMessage message) async {
    final notificationId = int.tryParse(message.data['notification_id'] ?? '');
    final vehicleId = message.data['vehicle_id']?.toString() ?? '';
    final type = message.data['type']?.toString();
    final rawCategory = message.data['category']?.toString();
    final category = (type == 'service_update')
        ? 'status'
        : (rawCategory ?? 'component');

    final groupKey = category == 'component' && vehicleId.isNotEmpty
        ? 'vehicle_comp_$vehicleId'
        : null;

    await LocalNotificationService.show(
      id:
          notificationId ??
          DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      title: message.data['title'] ?? message.notification?.title ?? 'RideOn',
      body: message.data['body'] ?? message.notification?.body ?? '',
      groupKey: groupKey,
      payload: jsonEncode({
        'vehicle_id': message.data['vehicle_id'],
        'notification_id': message.data['notification_id'],
      }),
    );
  }

  static String? _devicePlatform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return null;
  }

  // Dipanggil saat aplikasi dibuka, token berubah, dan setelah login agar token
  // guest yang sama dapat ditautkan ke user yang baru masuk.
  static Future<void> syncToken([String? latestToken]) async {
    try {
      final token = latestToken ?? await messaging.getToken();
      final platform = _devicePlatform();
      final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];
      final box = GetStorage();
      final accessToken = box.read<String>('token');
      final installationId = box.read<String>(_installationIdKey);

      if (token == null ||
          token.isEmpty ||
          platform == null ||
          baseUrl == null) {
        return;
      }

      final headers = <String, String>{'Content-Type': 'application/json'};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/fcm/register-token'),
        headers: headers,
        body: jsonEncode({
          'token': token,
          'platform': platform,
          'installation_id': installationId,
        }),
      );

      if (response.statusCode == 200) {
        final payload = jsonDecode(response.body);
        final returnedInstallationId = payload is Map<String, dynamic>
            ? payload['installation_id']?.toString()
            : null;

        if (returnedInstallationId != null &&
            returnedInstallationId.isNotEmpty) {
          await box.write(_installationIdKey, returnedInstallationId);
        }
      }
    } catch (_) {
      // Token akan dicoba lagi pada pembukaan aplikasi atau refresh berikutnya.
    }
  }

  /// Saat logout, pertahankan identitas perangkat agar tetap bisa menjadi guest.
  /// Backend hanya melepas relasi `user_id`; token FCM dan installation_id aman.
  static Future<void> disassociateTokenFromUser() async {
    final box = GetStorage();
    final accessToken = box.read<String>('token');
    final installationId = box.read<String>(_installationIdKey);
    final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

    if (accessToken == null ||
        accessToken.isEmpty ||
        installationId == null ||
        installationId.isEmpty ||
        baseUrl == null) {
      return;
    }

    try {
      await http.post(
        Uri.parse('$baseUrl/api/fcm/token/disassociate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'installation_id': installationId}),
      );
    } catch (_) {
      // Relasi akan dicoba diperbarui lagi saat token disinkronkan berikutnya.
    }
  }

  /// Hapus FCM token di database backend dan hapus token instance pada perangkat
  static Future<void> deleteTokenFromServer() async {
    final accessToken = GetStorage().read<String>('token');
    final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];
    String? token;

    try {
      token = await messaging.getToken();
    } catch (_) {}

    if (accessToken != null && baseUrl != null) {
      try {
        await http.delete(
          Uri.parse('$baseUrl/api/fcm/token'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({'token': token ?? ''}),
        );
      } catch (e) {
        print('Gagal menghapus token FCM dari backend: $e');
      }
    }

    try {
      await messaging.deleteToken();
    } catch (e) {
      print('Gagal deleteToken dari FCM instance: $e');
    }
  }

  static Future<void> _openRemoteMessage(RemoteMessage message) =>
      _openNotification(
        jsonEncode({
          'vehicle_id': message.data['vehicle_id'],
          'notification_id': message.data['notification_id'],
        }),
      );

  static Future<bool> openPendingNotificationAfterLogin() async {
    final box = GetStorage();
    final vehicleId = box.read<String>('pending_notification_vehicle_id');
    final notificationId = box.read<String>('pending_notification_id');

    if (vehicleId == null || notificationId == null) return false;

    await _openTargetNotification(
      vehicleId: vehicleId,
      notificationId: notificationId,
    );
    return true;
  }

  static Future<void> _openNotification(String? payload) async {
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final vehicleId = data['vehicle_id']?.toString();
      final notificationId = data['notification_id']?.toString();
      if (vehicleId == null ||
          vehicleId.isEmpty ||
          notificationId == null ||
          notificationId.isEmpty) {
        return;
      }

      final box = GetStorage();
      final accessToken = box.read<String>('token');
      if (accessToken == null || accessToken.isEmpty) {
        await box.write('pending_notification_vehicle_id', vehicleId);
        await box.write('pending_notification_id', notificationId);
        Get.offAllNamed('/login');
        return;
      }

      await _openTargetNotification(
        vehicleId: vehicleId,
        notificationId: notificationId,
      );
    } catch (_) {
      // Payload tidak lengkap/tidak valid tidak boleh mengganggu navigasi aplikasi.
    }
  }

  static Future<void> _openTargetNotification({
    required String vehicleId,
    required String notificationId,
  }) async {
    final box = GetStorage();
    await markNotificationRead(notificationId);
    await box.write('vehicle_id', vehicleId);
    await box.remove('pending_notification_vehicle_id');
    await box.remove('pending_notification_id');

    await Get.offAllNamed('/mainscreen');
    Get.toNamed('/notif');
  }

  static Future<void> markNotificationRead(String notificationId) async {
    final accessToken = GetStorage().read<String>('token');
    final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];
    if (accessToken == null || baseUrl == null) return;

    try {
      await http.patch(
        Uri.parse('$baseUrl/api/vehicle/notifications/$notificationId/read'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
    } catch (_) {}
  }

  static Future<bool> isNotificationPermissionGranted() async {
    final settings = await messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  static Future<bool> requestNotificationPermission() async {
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }
}
