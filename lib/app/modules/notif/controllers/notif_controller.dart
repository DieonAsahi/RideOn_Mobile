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
import '../../Feature/home/controllers/home_controller.dart';

class NotifModel {
  final int id;
  final String vehicleId;
  final String vehicleName;
  final String vehiclePlate;
  final int? componentId;
  final String type; // 'schedule_reminder' atau 'daily_warning'
  final String notificationType; // 'Pengingat Jadwal' atau 'Peringatan Cek Harian'
  final String image;
  final String status;
  final String title;
  final String desc;
  final String time;
  final DateTime createdAt;
  final bool isRead;

  NotifModel({
    required this.id,
    required this.vehicleId,
    required this.vehicleName,
    required this.vehiclePlate,
    this.componentId,
    required this.type,
    required this.notificationType,
    required this.image,
    required this.status,
    required this.title,
    required this.desc,
    required this.time,
    required this.createdAt,
    required this.isRead,
  });

  factory NotifModel.fromJson(Map<String, dynamic> json) {
    String iconKey = json["master_components"]?["icon"]?.toString().trim() ?? "";
    if (iconKey.endsWith(".png")) {
      iconKey = iconKey.substring(0, iconKey.length - 4);
    }

    if (iconKey.isEmpty) {
      final t = (json["title"] ?? "").toString().toLowerCase();
      final m = (json["message"] ?? "").toString().toLowerCase();
      if (t.contains("oli mesin") || m.contains("oli mesin")) {
        iconKey = "oli_mesin";
      } else if (t.contains("oli gardan") || m.contains("oli gardan")) {
        iconKey = "oli_gardan";
      } else if (t.contains("kampas rem") || m.contains("kampas rem")) {
        iconKey = "kampas_rem";
      } else if (t.contains("filter udara") || m.contains("filter udara")) {
        iconKey = "filter_udara";
      } else if (t.contains("busi") || m.contains("busi")) {
        iconKey = "busi";
      } else if (t.contains("cvt") || m.contains("cvt")) {
        iconKey = "cvt";
      } else {
        iconKey = "service";
      }
    }

    final img = "assets/icons/$iconKey.png";

    final created =
        DateTime.tryParse(json["created_at"]?.toString() ?? '') ??
            DateTime.now();

    final isSchedule = json["severity"] == "Pengingat" ||
        (json["title"]?.toString().toLowerCase().contains("jadwal") ?? false) ||
        json["type"] == "schedule_reminder";

    return NotifModel(
      id: json["id"] ?? 0,
      vehicleId: json["vehicle_id"]?.toString() ?? "",
      vehicleName: json["vehicle_name"]?.toString() ??
          (json["vehicles"] != null
              ? "${json["vehicles"]["brand"] ?? ""} ${json["vehicles"]["model"] ?? ""}".trim()
              : "Kendaraan"),
      vehiclePlate: json["vehicle_plate"]?.toString() ??
          (json["vehicles"]?["plate_number"]?.toString() ?? "-"),
      componentId: json["component_id"] != null
          ? int.tryParse(json["component_id"].toString())
          : null,
      type: json["type"]?.toString() ??
          (isSchedule ? "schedule_reminder" : "daily_warning"),
      notificationType: json["notification_type"]?.toString() ??
          (isSchedule ? "Pengingat Jadwal" : "Peringatan Cek Harian"),
      image: img,
      status: json["severity"] ?? (isSchedule ? "Pengingat" : "Darurat"),
      title: json["title"] ?? "Notifikasi Servis",
      desc: json["message"] ?? "",
      time: _formatElapsedTime(created),
      createdAt: created,
      isRead: json['is_read'] == true,
    );
  }

  static String _formatElapsedTime(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt.toLocal());
    final totalMinutes = difference.isNegative ? 0 : difference.inMinutes;

    if (totalMinutes < 1) return 'baru saja';
    if (totalMinutes < 60) return '$totalMinutes menit yang lalu';

    final hours = totalMinutes ~/ 60;
    if (hours < 24) {
      return '$hours jam yang lalu';
    }

    final days = hours ~/ 24;
    return '$days hari yang lalu';
  }

  NotifModel copyWith({bool? isRead}) => NotifModel(
    id: id,
    vehicleId: vehicleId,
    vehicleName: vehicleName,
    vehiclePlate: vehiclePlate,
    componentId: componentId,
    type: type,
    notificationType: notificationType,
    image: image,
    status: status,
    title: title,
    desc: desc,
    time: time,
    createdAt: createdAt,
    isRead: isRead ?? this.isRead,
  );
}

class TimeSectionGroup {
  final String title; // "Hari Ini", "Minggu Ini", "Bulan Ini", "Lebih Lama"
  final List<NotifModel> items;

  TimeSectionGroup({
    required this.title,
    required this.items,
  });
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

  /// Hanya menampilkan notifikasi pada kendaraan yang sedang dipilih saat ini
  List<NotifModel> get filteredNotifList {
    final currentVehicleId = box.read("vehicle_id")?.toString() ?? "";
    var list = notifList.toList();

    // Filter kendaraan terpilih saat ini
    if (currentVehicleId.isNotEmpty) {
      list = list
          .where((notif) => notif.vehicleId.isEmpty || notif.vehicleId == currentVehicleId)
          .toList();
    }

    // Filter tab "Belum dibaca"
    if (selectedFilter.value == 'Belum dibaca') {
      list = list.where((notif) => !notif.isRead).toList();
    }

    return list;
  }

  /// Kelompokkan notifikasi berdasarkan rentang waktu: Hari Ini, Minggu Ini, Bulan Ini, Lebih Lama
  List<TimeSectionGroup> get groupedTimeSections {
    final list = filteredNotifList;
    if (list.isEmpty) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<NotifModel> hariIniList = [];
    final List<NotifModel> mingguIniList = [];
    final List<NotifModel> bulanIniList = [];
    final List<NotifModel> lebihLamaList = [];

    for (final notif in list) {
      final notifDate = DateTime(
        notif.createdAt.year,
        notif.createdAt.month,
        notif.createdAt.day,
      );
      final diffDays = today.difference(notifDate).inDays;

      if (diffDays <= 0) {
        hariIniList.add(notif);
      } else if (diffDays <= 7) {
        mingguIniList.add(notif);
      } else if (diffDays <= 30) {
        bulanIniList.add(notif);
      } else {
        lebihLamaList.add(notif);
      }
    }

    final sections = <TimeSectionGroup>[];

    if (hariIniList.isNotEmpty) {
      sections.add(TimeSectionGroup(title: "Hari Ini", items: hariIniList));
    }
    if (mingguIniList.isNotEmpty) {
      sections.add(TimeSectionGroup(title: "Minggu Ini", items: mingguIniList));
    }
    if (bulanIniList.isNotEmpty) {
      sections.add(TimeSectionGroup(title: "Bulan Ini", items: bulanIniList));
    }
    if (lebihLamaList.isNotEmpty) {
      sections.add(TimeSectionGroup(title: "Lebih Lama", items: lebihLamaList));
    }

    return sections;
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
      if (!isPermissionGranted.value) {
        final granted =
            await FirebaseMessagingService.isNotificationPermissionGranted();
        if (granted) {
          isPermissionGranted.value = true;
          await getNotifications(silent: true);
        }
      } else {
        await getNotifications(silent: true);
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
      await LocationService.openAppSettings();
    }
  }

  /// Ambil notifikasi HANYA untuk kendaraan yang sedang dipilih saat ini
  Future<void> getNotifications({bool silent = false}) async {
    final shouldShowLoading = !silent && notifList.isEmpty;
    if (shouldShowLoading) {
      isLoading.value = true;
    }

    try {
      final token = box.read("token");
      final currentVehicleId = box.read("vehicle_id")?.toString() ?? "";

      final url = currentVehicleId.isNotEmpty
          ? "$baseUrl/api/vehicle/notifications/$currentVehicleId"
          : "$baseUrl/api/vehicle/notifications";

      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      print("STATUS CODE : ${response.statusCode}");

      if (response.statusCode == 200) {
        try {
          final List data = jsonDecode(response.body);
          var newList = data.map((e) => NotifModel.fromJson(e)).toList();

          // Pastikan hanya kendaraan yang sedang dipilih saat ini
          if (currentVehicleId.isNotEmpty) {
            newList = newList
                .where((n) => n.vehicleId.isEmpty || n.vehicleId == currentVehicleId)
                .toList();
          }

          if (_hasDataChanged(newList)) {
            notifList.value = newList;
          }
          updateUnreadBadge();
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

  void updateUnreadBadge() {
    final unread = notifList.where((n) => !n.isRead).length;
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().unreadNotifCount.value = unread;
    }
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
        if (index >= 0) {
          notifList[index] = notification.copyWith(isRead: true);
        }
        await LocalNotificationService.cancel(notification.id);
        updateUnreadBadge();
      }
    } catch (error) {
      print('Request status baca notifikasi gagal: $error');
    }
  }

  /// Aksi Klik Kartu Notifikasi:
  /// Tandai dibaca, lalu buka Tambah Riwayat Servis sesuai kendaraan & komponen.
  void onNotifCardTapped(NotifModel notif) {
    markAsRead(notif);

    if (notif.vehicleId.isNotEmpty) {
      box.write('vehicle_id', notif.vehicleId);
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().syncVehicleFromStorage();
      }
    }

    Get.toNamed(
      '/rwttambah',
      arguments: {
        'jadwalkan': true,
        'component_id': notif.componentId,
        'vehicle_id': notif.vehicleId,
      },
    )?.then((_) {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().syncVehicleFromStorage();
      }
      getNotifications(silent: true);
    });
  }
}
