import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class RwtservisController extends GetxController {
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
        Uri.parse(
          "https://backend-capstone-snowy.vercel.app/api/vehicle/service-history/$vehicleId",
        ),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        // Tambahkan .cast<Map<String, dynamic>>() di akhir agar tipe datanya mutlak dan tidak bikin UI crash
        riwayat.value = data
            .map((item) {
              Color statusColor = Colors.grey;

              if (item["status"] == "Diproses") {
                statusColor = Colors.orange;
              } else if (item["status"] == "Selesai") {
                statusColor = Colors.green;
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
      print("ERROR RIWAYAT UI: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteServiceHistory(int id) async {
    try {
      isLoading.value = true;

      final token = box.read("token");

      final response = await http.delete(
        Uri.parse(
          "https://backend-capstone-snowy.vercel.app/api/vehicle/service-history/$id",
        ),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        Get.snackbar("Berhasil", "Riwayat servis berhasil dihapus");

        await loadServiceHistory();
      } else {
        Get.snackbar("Error", response.body);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
