import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:capbatu/app/services/connectivity_service.dart';
import 'package:capbatu/app/widgets/app_snackbar.dart';
import 'package:capbatu/app/widgets/app_feedback_widgets.dart';
import 'package:capbatu/app/modules/Feature/home/controllers/home_controller.dart';
import 'package:capbatu/app/modules/Feature/kendaraan/controllers/kendaraan_controller.dart';
import 'package:capbatu/app/modules/Feature/service/controllers/service_controller.dart';

class RwtservisController extends GetxController {
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  final List<String> filterOptions = ['Semua', 'Servis Rutin', 'Perbaikan'];
  var selectedFilter = 'Semua'.obs;
  final box = GetStorage();
  var riwayat = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  List<Map<String, dynamic>> get filteredData {
    if (selectedFilter.value == 'Semua') {
      return riwayat;
    }
    return riwayat
        .where((item) => item['jenis'] == selectedFilter.value.toUpperCase())
        .toList();
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  @override
  void onInit() {
    super.onInit();
    loadServiceHistory();
  }

  Future<void> loadServiceHistory() async {
    try {
      isLoading.value = true;

      final token = box.read("token");
      final vehicleId = box.read("vehicle_id");

      final response = await http.get(
        Uri.parse("$baseUrl/api/vehicle/service-history/$vehicleId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        riwayat.value = data
            .where((item) => item["status"]?.toString() != "Dibatalkan")
            .map((item) {
              Color statusColor = Colors.grey;
              final st = item["status"]?.toString();

              if (st == "Proses" || st == "Diproses") {
                statusColor = Colors.orange;
              } else if (st == "Selesai") {
                statusColor = Colors.green;
              } else if (st == "Dijadwalkan") {
                statusColor = const Color(0xFF2196F3);
              }

              // Di dalam loadServiceHistory()
              return {
                "id": item["id"],
                "component_id": item["component_id"],
                "jenis": item["service_type"].toString().toUpperCase(),
                "detail":
                    item["service_type"].toString().toLowerCase() ==
                        "servis rutin"
                    ? (item["master_components"]?["name"] ?? "-")
                    : (item["detail"] ?? "-"),
                "tanggal": item["service_date"] ?? "-",
                "odometer": "${item["odometer"] ?? 0} km",
                "bengkel": item["workshop_name"] ?? "-",
                "biaya": item["cost"] == null ? "-" : "Rp ${item["cost"]}",
                "status": item["status"] ?? "-",
                "statusColor": statusColor,
              };
            })
            .toList()
            .cast<Map<String, dynamic>>();
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        AppFeedback.serviceHistoryLoadFailed(
          message: 'Gagal memuat riwayat servis, periksa koneksi Anda.',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelServiceHistory(int id) async {
    try {
      isLoading.value = true;
      final token = box.read("token");

      final response = await http.put(
        Uri.parse("$baseUrl/api/vehicle/service-history/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"status": "Dibatalkan"}),
      );

      if (response.statusCode == 200) {
        AppSnackbar.success("Proses servis berhasil dibatalkan.");

        await loadServiceHistory();

        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchHome(force: true);
        }
        if (Get.isRegistered<KendaraanController>()) {
          Get.find<KendaraanController>().getVehicles(force: true);
        }
        if (Get.isRegistered<ServiceController>()) {
          Get.find<ServiceController>().getServices(force: true);
        }
      } else {
        String msg = "Gagal membatalkan servis";
        try {
          final err = jsonDecode(response.body);
          if (err is Map && (err['message'] != null || err['error'] != null)) {
            msg = err['message'] ?? err['error'];
          }
        } catch (_) {}
        AppFeedback.serviceHistoryCancelFailed(message: msg);
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        AppFeedback.serviceHistoryCancelFailed(
          message: 'Gagal membatalkan servis, periksa koneksi Anda.',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteServiceHistory(int id) async {
    try {
      isLoading.value = true;

      final token = box.read("token");

      final response = await http.delete(
        Uri.parse("$baseUrl/api/vehicle/service-history/$id"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        riwayat.removeWhere((item) => item['id'] == id);
        AppSnackbar.success("Riwayat servis berhasil dihapus.");

        await loadServiceHistory();

        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchHome(force: true);
        }
        if (Get.isRegistered<KendaraanController>()) {
          Get.find<KendaraanController>().getVehicles(force: true);
        }
        if (Get.isRegistered<ServiceController>()) {
          Get.find<ServiceController>().getServices(force: true);
        }
      } else {
        String msg = "Gagal menghapus riwayat servis";
        try {
          final err = jsonDecode(response.body);
          if (err is Map && (err['message'] != null || err['error'] != null)) {
            msg = err['message'] ?? err['error'];
          }
        } catch (_) {}
        AppFeedback.serviceHistoryDeleteFailed(message: msg);
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        AppFeedback.serviceHistoryDeleteFailed(
          message: 'Gagal menghapus riwayat servis, periksa koneksi Anda.',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
