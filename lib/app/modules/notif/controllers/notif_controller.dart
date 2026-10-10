import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../services/local_notification_service.dart';
import '../../../services/firebase_messaging_service.dart';
import '../../../services/location_service.dart';
import '../../../services/connectivity_service.dart';

class NotifModel {
  final int id;
  final String image;
  final String status;
  final String title;
  final String desc;
  final String time;
  final bool isRead;

  NotifModel({
    required this.id,
    required this.image,
    required this.status,
    required this.title,
    required this.desc,
    required this.time,
    required this.isRead,
  });

  factory NotifModel.fromJson(Map<String, dynamic> json) {
    return NotifModel(
      id: json["id"],
      image: "assets/icons/${json["master_components"]["icon"]}.png",
      status: json["severity"],
      title: json["title"],
      desc: json["message"],
      time: _formatElapsedTime(DateTime.parse(json["created_at"])),
      isRead: json['is_read'] == true,
    );
  }

  static String _formatElapsedTime(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt.toLocal());
    final totalMinutes = difference.isNegative ? 0 : difference.inMinutes;

    if (totalMinutes < 1) return 'baru saja';
    if (totalMinutes < 60) return '$totalMinutes menit yang lalu';

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours < 24) {
      final minuteText = minutes > 0 ? ' $minutes menit' : '';
      return '$hours jam$minuteText yang lalu';
    }

    final days = hours ~/ 24;
    final remainingHours = hours % 24;
    final hourText = remainingHours > 0 ? ' $remainingHours jam' : '';
    return '$days hari$hourText yang lalu';
  }

  NotifModel copyWith({bool? isRead}) => NotifModel(
    id: id,
    image: image,
    status: status,
    title: title,
    desc: desc,
    time: time,
    isRead: isRead ?? this.isRead,
  );
}

class NotifController extends GetxController with WidgetsBindingObserver {
  final box = GetStorage();
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  var notifList = <NotifModel>[].obs;
  var isLoading = false.obs;
  var isPermissionGranted = true.obs;

  final List<String> filterOptions = ['Semua', 'Belum dibaca'];
  var selectedFilter = 'Semua'.obs;

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  List<NotifModel> get filteredNotifList {
    if (selectedFilter.value == 'Belum dibaca') {
      return notifList.where((notif) => !notif.isRead).toList();
    }
    return notifList;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    checkPermissionAndLoad();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // Saat notifikasi HP ditarik / drawer ditutup, jangan auto refresh
      // Hanya cek izin jika sebelumnya izin ditolak
      if (!isPermissionGranted.value) {
        final granted =
            await FirebaseMessagingService.isNotificationPermissionGranted();
        if (granted) {
          isPermissionGranted.value = true;
          await getNotifications(silent: true);
        }
      }
    }
  }

  Future<void> checkPermissionAndLoad() async {
    final granted =
        await FirebaseMessagingService.isNotificationPermissionGranted();
    isPermissionGranted.value = granted;
    if (granted) {
      await getNotifications();
    }
  }

  Future<void> requestPermission() async {
    final granted =
        await FirebaseMessagingService.requestNotificationPermission();
    isPermissionGranted.value = granted;
    if (granted) {
      await getNotifications();
    } else {
      // Buka pengaturan aplikasi jika ditolak secara permanen
      await LocationService.openAppSettings();
    }
  }

  Future<void> getNotifications({bool silent = false}) async {
    // Jika data sudah ada, jangan tampilkan full-screen loading agar tidak kedap-kedip
    final shouldShowLoading = !silent && notifList.isEmpty;
    if (shouldShowLoading) {
      isLoading.value = true;
    }

    try {
      final token = box.read("token");
      final vehicleId = box.read("vehicle_id");

      final response = await http.get(
        Uri.parse("$baseUrl/api/vehicle/notifications/$vehicleId"),
        headers: {"Authorization": "Bearer $token"},
      );

      print("STATUS CODE : ${response.statusCode}");
      print("RESPONSE BODY : ${response.body}");

      if (response.statusCode == 200) {
        try {
          final List data = jsonDecode(response.body);
          final newList = data.map((e) => NotifModel.fromJson(e)).toList();

          // Refresh hanya jika benar-benar ada data update baru dari backend
          if (_hasDataChanged(newList)) {
            notifList.value = newList;
          }
        } catch (e, s) {
          print("FROM JSON ERROR: $e");
          print(s);
        }
      }
    } catch (e) {
      print("Error fetchNotifications: $e");
      ConnectivityService.handleNetworkError(e);
    } finally {
      if (shouldShowLoading) {
        isLoading.value = false;
      }
    }
  }

  /// Cek apakah data notifikasi dari backend benar-benar memiliki perubahan
  bool _hasDataChanged(List<NotifModel> newList) {
    if (newList.length != notifList.length) return true;
    for (int i = 0; i < newList.length; i++) {
      if (newList[i].id != notifList[i].id ||
          newList[i].isRead != notifList[i].isRead ||
          newList[i].title != notifList[i].title ||
          newList[i].desc != notifList[i].desc) {
        return true;
      }
    }
    return false;
  }

  Future<void> markAsRead(NotifModel notification) async {
    if (notification.isRead) return;

    final token = box.read("token");
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/api/vehicle/notifications/${notification.id}/read"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final index = notifList.indexWhere(
          (item) => item.id == notification.id,
        );
        if (index >= 0) notifList[index] = notification.copyWith(isRead: true);
        await LocalNotificationService.cancel(notification.id);
      } else {
        print(
          'Gagal menandai notifikasi dibaca: ${response.statusCode} ${response.body}',
        );
      }
    } catch (error) {
      print('Request status baca notifikasi gagal: $error');
    }
  }
}
