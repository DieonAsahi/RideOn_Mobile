import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:capbatu/app/services/auth_service.dart';
import 'package:capbatu/app/services/connectivity_service.dart';
import 'package:capbatu/app/modules/Feature/home/controllers/home_controller.dart';
import 'package:capbatu/app/modules/Feature/service/controllers/service_controller.dart';
import 'package:capbatu/app/modules/notif/controllers/notif_controller.dart';
import 'package:capbatu/app/widgets/app_snackbar.dart';
import 'package:capbatu/app/widgets/app_feedback_widgets.dart';

class Kendaraan {
  final String id;
  final String nama;
  final String plat;
  final String km;
  final String status;
  final String image;
  final double performance;
  final String lastServiceDate;
  final String nextServiceComponent;

  Kendaraan({
    required this.id,
    required this.nama,
    required this.plat,
    required this.km,
    required this.status,
    required this.image,
    required this.performance,
    required this.lastServiceDate,
    required this.nextServiceComponent,
  });
}

class KendaraanController extends GetxController {
  final box = GetStorage();
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  var isLoading = false.obs;
  var kendaraanList = <Kendaraan>[].obs;
  var activeVehicleId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    activeVehicleId.value = box.read("vehicle_id")?.toString() ?? "";
    getVehicles();
  }

  /// Pindahkan kendaraan yang aktif/digunakan saat ini ke posisi paling atas (index 0)
  void _reorderListForActiveVehicle() {
    final activeId = activeVehicleId.value.isNotEmpty
        ? activeVehicleId.value
        : box.read("vehicle_id")?.toString() ?? "";
    if (activeId.isEmpty || kendaraanList.isEmpty) return;

    final index = kendaraanList.indexWhere((k) => k.id == activeId);
    if (index > 0) {
      final selectedItem = kendaraanList.removeAt(index);
      kendaraanList.insert(0, selectedItem);
      kendaraanList.refresh();
    }
  }

  /// Sinkronkan kendaraan aktif dari storage saat tab atau halaman kendaraan dibuka
  void syncActiveVehicleFromStorage() {
    final stored = box.read("vehicle_id")?.toString();
    if (stored != null && stored.isNotEmpty) {
      activeVehicleId.value = stored;
      _reorderListForActiveVehicle();
    }
  }

  /// Dipanggil saat kendaraan diganti dari halaman Home atau halaman lain
  void onVehicleChangedFromExternal(String id) {
    activeVehicleId.value = id;
    _reorderListForActiveVehicle();
  }

  /// Dipanggil saat user memilih kendaraan di halaman kendaraan
  void setActiveVehicle(String id) {
    activeVehicleId.value = id;
    box.write("vehicle_id", id);
    _reorderListForActiveVehicle();

    if (Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      home.changeVehicle(id);
    }

    if (Get.isRegistered<ServiceController>()) {
      Get.find<ServiceController>().getServices(force: true);
    }

    if (Get.isRegistered<NotifController>()) {
      Get.find<NotifController>().getNotifications(silent: true);
    }
  }

  String formatServiceDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return "-";
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Ags',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return "${dt.day} ${months[dt.month]} ${dt.year}";
    } catch (_) {
      return "-";
    }
  }

  Future<void> deleteVehicle(String id) async {
    try {
      isLoading.value = true;
      final token = box.read("token");

      final response = await http.delete(
        Uri.parse("$baseUrl/api/vehicle/delete-vehicle/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        // Hapus langsung dari list lokal agar UI terupdate instan
        kendaraanList.removeWhere((item) => item.id == id);

        final currentActiveId = box.read("vehicle_id");
        if (currentActiveId == id) {
          box.remove("vehicle_id");
          if (kendaraanList.isNotEmpty) {
            setActiveVehicle(kendaraanList.first.id);
          }
        }

        // Tampilkan snackbar sukses segera setelah data terhapus di backend
        AppSnackbar.success("Kendaraan berhasil dihapus.");

        // Sinkronisasi data ke HomeController jika aktif
        if (Get.isRegistered<HomeController>()) {
          final home = Get.find<HomeController>();
          home.getVehicles();
          if (kendaraanList.isNotEmpty) {
            final activeId = box.read("vehicle_id") ?? kendaraanList.first.id;
            home.changeVehicle(activeId.toString());
          }
        }

        if (kendaraanList.isEmpty) {
          box.remove("vehicle_id");
          Get.offNamed('/pluskendaraan', arguments: true);
        }
      } else {
        String errorMsg = "Gagal menghapus kendaraan";
        try {
          final body = jsonDecode(response.body);
          if (body is Map &&
              (body['error'] != null || body['message'] != null)) {
            errorMsg = body['message'] ?? body['error'];
          }
        } catch (_) {}
        AppFeedback.vehicleDeleteFailed(message: errorMsg);
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        AppFeedback.vehicleDeleteFailed(
          message: 'Gagal menghapus kendaraan, periksa koneksi Anda.',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getVehicles({bool force = false}) async {
    if (!force && kendaraanList.isNotEmpty) {
      syncActiveVehicleFromStorage();
      return;
    }
    try {
      isLoading.value = true;

      final token = box.read("token");
      if (token == null) {
        await AuthService.logout();
        return;
      }

      final response = await http.get(
        Uri.parse("$baseUrl/api/vehicle/my-vehicles"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 401) {
        await AuthService.logout();
        return;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          final formatter = NumberFormat('#,###', 'id_ID');

          var parsedList = data.map<Kendaraan>((item) {
            final odo = int.tryParse(item["current_odometer"].toString()) ?? 0;
            final kmStr = "${formatter.format(odo)} km";

            final perf =
                double.tryParse(item["performance"].toString()) ?? 100.0;
            final score = perf.round().clamp(0, 100);

            // Sinkronkan status dengan aturan yang sama persis seperti Home
            String statusStr = item["status"]?.toString() ?? "";
            if (statusStr.isEmpty ||
                statusStr.toLowerCase() == "optimal" ||
                statusStr.toLowerCase() == "perlu servis") {
              if (score >= 75) {
                statusStr = "Baik";
              } else if (score >= 50) {
                statusStr = "Perlu perhatian";
              } else {
                statusStr = "Buruk";
              }
            }

            return Kendaraan(
              id: item["id"].toString(),
              nama: "${item["brand"] ?? ''} ${item["model"] ?? ''}".trim(),
              plat: item["plate_number"] ?? "-",
              km: kmStr,
              status: statusStr,
              image: item["vehicle_image"] ?? "",
              performance: perf,
              lastServiceDate: formatServiceDate(item["last_service_date"]),
              nextServiceComponent: item["next_service_component"] ?? "-",
            );
          }).toList();

          var list = parsedList.reversed.toList();

          final currentActive = box.read("vehicle_id")?.toString();
          if ((currentActive == null || currentActive.isEmpty) &&
              list.isNotEmpty) {
            activeVehicleId.value = list.first.id;
            box.write("vehicle_id", list.first.id);
          } else if (currentActive != null && currentActive.isNotEmpty) {
            activeVehicleId.value = currentActive;
            final idx = list.indexWhere((k) => k.id == currentActive);
            if (idx > 0) {
              final selectedItem = list.removeAt(idx);
              list.insert(0, selectedItem);
            }
          }

          kendaraanList.assignAll(list);
        }
      }
    } catch (e) {
      ConnectivityService.handleNetworkError(e);
    } finally {
      isLoading.value = false;
    }
  }
}
