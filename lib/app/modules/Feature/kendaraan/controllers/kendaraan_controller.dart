import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:capbatu/app/services/auth_service.dart';
import 'package:capbatu/app/services/connectivity_service.dart';
import 'package:capbatu/app/modules/Feature/home/controllers/home_controller.dart';
import 'package:capbatu/app/widgets/app_snackbar.dart';

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

  void setActiveVehicle(String id) {
    activeVehicleId.value = id;
    box.write("vehicle_id", id);
    if (Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      home.vehicleId = id;
      home.fetchHome();
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

        // Paksa refresh dari backend untuk sinkronisasi state
        await getVehicles(force: true);

        // Sinkronisasi data ke HomeController jika aktif
        if (Get.isRegistered<HomeController>()) {
          final home = Get.find<HomeController>();
          await home.getVehicles();
          if (kendaraanList.isNotEmpty) {
            final activeId = box.read("vehicle_id") ?? kendaraanList.first.id;
            home.changeVehicle(activeId.toString());
          }
        }

        // Tampilkan snackbar sukses HANYA setelah data benar-benar terhapus
        AppSnackbar.success("Kendaraan berhasil dihapus.");

        if (kendaraanList.isEmpty) {
          box.remove("vehicle_id");
          Get.offNamed('/pluskendaraan', arguments: true);
        }
      } else {
        String errorMsg = "Gagal menghapus kendaraan";
        try {
          final body = jsonDecode(response.body);
          if (body is Map && (body['error'] != null || body['message'] != null)) {
            errorMsg = body['error'] ?? body['message'];
          }
        } catch (_) {}
        Get.snackbar("Error", errorMsg);
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        Get.snackbar("Error", "Gagal menghapus kendaraan");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getVehicles({bool force = false}) async {
    if (!force && kendaraanList.isNotEmpty) return;
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

            return Kendaraan(
              id: item["id"].toString(),
              nama: "${item["brand"] ?? ''} ${item["model"] ?? ''}".trim(),
              plat: item["plate_number"] ?? "-",
              km: kmStr,
              status: item["status"] ?? "Optimal",
              image: item["vehicle_image"] ?? "",
              performance:
                  double.tryParse(item["performance"].toString()) ?? 100,
              lastServiceDate: formatServiceDate(item["last_service_date"]),
              nextServiceComponent: item["next_service_component"] ?? "-",
            );
          }).toList();

          kendaraanList.value = parsedList.reversed.toList();

          final currentActive = box.read("vehicle_id");
          if ((currentActive == null || currentActive.toString().isEmpty) &&
              kendaraanList.isNotEmpty) {
            setActiveVehicle(kendaraanList.first.id);
          } else {
            activeVehicleId.value = currentActive?.toString() ?? "";
          }
        }
      }
    } catch (e) {
      print("Error getVehicles: $e");
      ConnectivityService.handleNetworkError(e);
    } finally {
      isLoading.value = false;
    }
  }
}
