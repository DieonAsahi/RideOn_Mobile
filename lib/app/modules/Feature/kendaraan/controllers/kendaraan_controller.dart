import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:capbatu/app/services/auth_service.dart';

class Kendaraan {
  final String id;
  final String nama;
  final String plat;
  final String km;
  final String status;
  final String image;
  final double performance;

  Kendaraan({
    required this.id,
    required this.nama,
    required this.plat,
    required this.km,
    required this.status,
    required this.image,
    required this.performance,
  });
}

class KendaraanController extends GetxController {
  final box = GetStorage();
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  var isLoading = false.obs;
  var kendaraanList = <Kendaraan>[].obs;

  // void goToTambahKendaraan() {
  //   Get.toNamed('/pluskendaraan', arguments: false);
  // }

  @override
  void onInit() {
    super.onInit();
    getVehicles();
  }

  Future<void> deleteVehicle(String id) async {
    try {
      final token = box.read("token");

      final response = await http.delete(
        Uri.parse("$baseUrl/api/vehicle/delete-vehicle/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("DELETE STATUS: ${response.statusCode}");
      print("DELETE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final currentActiveId = box.read("vehicle_id");
        if (currentActiveId == id) {
          box.remove("vehicle_id");
        }

        await getVehicles();

        Get.snackbar("Berhasil", "Kendaraan berhasil dihapus");

        if (kendaraanList.isEmpty) {
          box.remove("vehicle_id");
          Get.offNamed('/pluskendaraan', arguments: true);
        } else if (box.read("vehicle_id") == null && kendaraanList.isNotEmpty) {
          box.write("vehicle_id", kendaraanList.first.id);
        }
      } else {
        Get.snackbar("Error", "Gagal menghapus kendaraan");
      }
    } catch (e) {
      print(e);

      Get.snackbar("Error", "Terjadi kesalahan");
    }
  }

  Future<void> getVehicles() async {
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

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 401) {
        await AuthService.logout();
        return;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          kendaraanList.value = data.map<Kendaraan>((item) {
            return Kendaraan(
              id: item["id"],
              nama: "${item["brand"]} ${item["model"]}",
              plat: item["plate_number"] ?? "-",
              km: "${item["current_odometer"] ?? 0} km",
              status: item["status"] ?? "Optimal",
              image: item["vehicle_image"] ?? "",
              performance: double.tryParse(item["performance"].toString()) ?? 100,
            );
          }).toList();
        }
      }
    } catch (e) {
      print("Error getVehicles: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
