import 'dart:convert';
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
    String? groupKey,
    bool setAsGroupSummary = false,
  }) async {
    final android = AndroidNotificationDetails(
      'rideon_notification',
      'RideOn Notification',
      channelDescription: 'Reminder komponen kendaraan',
      importance: Importance.max,
      priority: Priority.high,
      groupKey: groupKey,
      setAsGroupSummary: setAsGroupSummary,
    );

    await notification.show(
      id,
      title,
      body,
      NotificationDetails(android: android),
      payload: payload,
    );
  }

  /// Setel pengingat inaktivitas jam 8 pagi jika user tidak membuka aplikasi selama >= 1 hari (24 jam)
  /// Berlaku untuk user yang sedang logout maupun yang baru download belum pernah login
  static Future<void> scheduleInactivityReminder() async {
    try {
      await cancel(inactivityNotifId);

      final now = tz.TZDateTime.now(tz.local);

      // Target jam 08:00 pagi besok
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        8,
        0,
        0,
      ).add(const Duration(days: 1));

      // Jika dari waktu sekarang ke jam 8 pagi besok kurang dari 24 jam penuh,
      // jadwalkan ke jam 8 pagi hari berikutnya (lusa) agar memenuhi syarat inaktivitas >= 24 jam (1 hari)
      if (scheduledDate.difference(now).inHours < 24) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const android = AndroidNotificationDetails(
        'rideon_inactivity',
        'Pengingat Aktivitas RideOn',
        channelDescription:
            'Pengingat jam 8 pagi untuk memeriksa kondisi kendaraan setelah 1 hari tidak dibuka',
        importance: Importance.high,
        priority: Priority.high,
      );

      await notification.zonedSchedule(
        inactivityNotifId,
        'RideOn',
        'Buka aplikasi dan mulai pengecekan kondisi kendaraan Anda!',
        scheduledDate,
        const NotificationDetails(android: android),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('Inactivity reminder jam 8 pagi berhasil dijadwalkan pada: $scheduledDate');
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

  static const int odoReminder00Id = 80000;
  static const int odoReminder08Id = 80008;
  static const int odoReminder16Id = 80016;

  /// Jadwalkan pengingat update odometer lokal setiap 8 jam (00:00, 08:00, 16:00)
  /// jika user belum mengupdate odometer pada hari tersebut
  static Future<void> scheduleOdometerReminder() async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final hours = [0, 8, 16];
      final ids = [odoReminder00Id, odoReminder08Id, odoReminder16Id];

      const android = AndroidNotificationDetails(
        'rideon_odometer_reminder',
        'Pengingat Update Odometer',
        channelDescription:
            'Pengingat rutin untuk memperbarui angka odometer kendaraan',
        importance: Importance.high,
        priority: Priority.high,
      );

      for (var i = 0; i < hours.length; i++) {
        final targetHour = hours[i];
        final notifId = ids[i];

        tz.TZDateTime scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          targetHour,
          0,
          0,
        );

        // Jika waktu jam tersebut sudah lewat hari ini, jadwalkan untuk besok
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        await notification.zonedSchedule(
          notifId,
          'Kontrol Kendaraanmu 🛵',
          'Ayo kontrol kendaraanmu dengan mengupdate odometer kendaraan',
          scheduledDate,
          const NotificationDetails(android: android),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: jsonEncode({
            'type': 'odometer_reminder',
            'action': 'update_odometer',
          }),
        );
      }
    } catch (e) {
      print('Gagal menjadwalkan odometer reminder: $e');
    }
  }

  /// Batalkan notifikasi pengingat odometer hari ini setelah user berhasil update odometer
  static Future<void> cancelOdometerReminderToday() async {
    try {
      await cancel(odoReminder00Id);
      await cancel(odoReminder08Id);
      await cancel(odoReminder16Id);
      print('Odometer reminder hari ini berhasil dibatalkan.');
    } catch (e) {
      print('Gagal membatalkan odometer reminder: $e');
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
