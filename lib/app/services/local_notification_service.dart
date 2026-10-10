import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin notification =
      FlutterLocalNotificationsPlugin();

  static const int inactivityNotifId = 99999;

  static Future<void> Function(String? payload)? onNotificationTap;

  static Future<void> init({bool requestPermission = true}) async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await notification.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        onNotificationTap?.call(response.payload);
      },
    );

    if (requestPermission) {
      await notification
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  static Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const android = AndroidNotificationDetails(
      'rideon_notification',
      'RideOn Notification',
      channelDescription: 'Reminder komponen kendaraan',
      importance: Importance.max,
      priority: Priority.high,
    );

    await notification.show(
      id,
      title,
      body,
      const NotificationDetails(android: android),
      payload: payload,
    );
  }

  /// Setel pengingat inaktivitas jika aplikasi ditutup/di-background selama 24 jam
  static Future<void> scheduleInactivityReminder() async {
    try {
      await cancel(inactivityNotifId);

      final scheduledDate =
          tz.TZDateTime.now(tz.local).add(const Duration(hours: 24));

      const android = AndroidNotificationDetails(
        'rideon_inactivity',
        'Pengingat Aktivitas RideOn',
        channelDescription:
            'Pengingat untuk memeriksa kondisi kendaraan setelah 24 jam tidak dibuka',
        importance: Importance.high,
        priority: Priority.high,
      );

      await notification.zonedSchedule(
        inactivityNotifId,
        'RideOn',
        'Ayo periksa kondisi kendaraan Anda!',
        scheduledDate,
        const NotificationDetails(android: android),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('Inactivity reminder berhasil dijadwalkan untuk 24 jam ke depan.');
    } catch (e) {
      print('Gagal menjadwalkan inactivity reminder: $e');
    }
  }

  /// Batalkan pengingat inaktivitas saat user membuka aplikasi kembali
  static Future<void> cancelInactivityReminder() async {
    try {
      await cancel(inactivityNotifId);
      print('Inactivity reminder dibatalkan.');
    } catch (e) {
      print('Gagal membatalkan inactivity reminder: $e');
    }
  }

  static Future<void> cancel(int id) => notification.cancel(id);

  static Future<String?> getLaunchPayload() async {
    final details = await notification.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return details?.notificationResponse?.payload;
    }
    return null;
  }
}
