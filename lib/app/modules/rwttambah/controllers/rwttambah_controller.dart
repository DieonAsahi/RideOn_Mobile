import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:capbatu/app/services/connectivity_service.dart';
import 'package:capbatu/app/widgets/app_snackbar.dart';
import 'package:capbatu/app/modules/Feature/home/controllers/home_controller.dart';
import 'package:capbatu/app/modules/Feature/kendaraan/controllers/kendaraan_controller.dart';

class RwttambahController extends GetxController {
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  final detailController = TextEditingController();
  final tanggalController = TextEditingController();
  final bengkelController = TextEditingController();
  final biayaController = TextEditingController();

  DateTime? selectedDate;

  var isEdit = false.obs;
  var serviceId = 0.obs;

  var currentOdometer = 0.obs;
  var odometerUpdatedToday = false.obs;

  var selectedComponentId = 0.obs;
  var components = <Map<String, dynamic>>[].obs;

  var selectedJenis = 'Servis Rutin'.obs;
  var selectedStatus = 'Dijadwalkan'.obs;
  var isStatusLocked = false.obs;

  final box = GetStorage();

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args != null && args['vehicle_id'] != null) {
      box.write('vehicle_id', args['vehicle_id'].toString());
    }

    loadVehicleOdometer();
    loadMasterComponents();

    if (args != null && args['jenis'] == 'Perbaikan') {
      selectedJenis.value = 'Perbaikan';
    }

    if (args != null && args["nama_bengkel"] != null) {
      bengkelController.text = args['nama_bengkel'] ?? '';
    }

    if (args != null && args['jadwalkan'] == true) {
      selectedStatus.value = 'Dijadwalkan';
      isStatusLocked.value = true;
      selectedJenis.value = 'Servis Rutin';

      if (args['component'] != null) {
        final comp = args['component'];
        // Jika comp bertipe ServiceItem atau Map
        try {
          selectedComponentId.value = comp.id;
        } catch (_) {
          if (comp is Map && comp['id'] != null) {
            selectedComponentId.value = comp['id'];
          }
        }
      } else if (args['component_id'] != null) {
        selectedComponentId.value = args['component_id'];
      }
    }

    if (args != null && args['isEdit'] == true) {
      isEdit.value = true;

      final data = args['data'];

      serviceId.value = data['id'];

      // isi form
      bengkelController.text = data['bengkel'];
      serviceId.value = data['id'];

      selectedJenis.value = data['jenis'] == 'SERVIS RUTIN'
          ? 'Servis Rutin'
          : 'Perbaikan';

      selectedStatus.value = data['status'];

      tanggalController.text = data['tanggal'];
      selectedDate = DateTime.parse(data['tanggal']);

      bengkelController.text = data['bengkel'];
      biayaController.text = data['biaya'] == '-'
          ? ''
          : data['biaya'].replaceAll('Rp ', '');

      detailController.text = data['jenis'] == 'PERBAIKAN'
          ? data['detail']
          : '';

      if (data['jenis'] == 'SERVIS RUTIN') {
        selectedComponentId.value = data['component_id'] ?? 0;
      }
    }
  }

  void changeJenis(String value) {
    selectedJenis.value = value;
  }

  void changeStatus(String value) {
    selectedStatus.value = value;
  }

  Future<void> loadMasterComponents() async {
    try {
      final token = box.read("token");

      final response = await http.get(
        Uri.parse("$baseUrl/api/vehicle/master-components"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        components.value = List<Map<String, dynamic>>.from(
          jsonDecode(response.body),
        );
      }
    } catch (e) {
      ConnectivityService.handleNetworkError(e);
    }
  }

  Future<void> loadVehicleOdometer() async {
    try {
      final token = box.read("token");
      final vehicleId = box.read("vehicle_id");

      if (vehicleId == null || vehicleId.toString().isEmpty) return;

      final response = await http.get(
        Uri.parse("$baseUrl/api/vehicle/vehicle-odometer/$vehicleId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        currentOdometer.value = data["current_odometer"] ?? 0;

        if (data["last_odometer_update"] != null) {
          final updatedAt =
              DateTime.parse(data["last_odometer_update"]).toLocal();

          odometerUpdatedToday.value =
              DateTime.now().difference(updatedAt).inDays == 0;
        }
      }
    } catch (e) {
      ConnectivityService.handleNetworkError(e);
    }
  }

  Future<void> pickDate() async {
    final pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      selectedDate = pickedDate;

      tanggalController.text =
          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    }
  }

  Future<void> simpanRiwayat() async {
    if (!odometerUpdatedToday.value) {
      Get.snackbar("Perhatian", "Update odometer terlebih dahulu");
      return;
    }

    if (selectedStatus.value == "Selesai" && biayaController.text.isEmpty) {
      Get.snackbar("Error", "Biaya servis wajib diisi");
      return;
    }

    if (selectedJenis.value == "Servis Rutin" &&
        selectedComponentId.value == 0) {
      Get.snackbar("Error", "Pilih komponen terlebih dahulu");
      return;
    }

    if (selectedJenis.value == "Perbaikan" &&
        detailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Detail perbaikan wajib diisi');
      return;
    }
    if (tanggalController.text.isEmpty || bengkelController.text.isEmpty) {
      Get.snackbar('Error', 'Semua field wajib diisi');
      return;
    }

    try {
      isLoading.value = true;

      final token = box.read("token");
      final vehicleId = box.read("vehicle_id");
      final serviceDate =
          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

      final response = await http.post(
        Uri.parse("$baseUrl/api/vehicle/service-history"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "vehicle_id": vehicleId,
          "component_id": selectedJenis.value == "Servis Rutin"
              ? selectedComponentId.value
              : null,
          "service_type": selectedJenis.value,
          "detail": selectedJenis.value == "Perbaikan"
              ? detailController.text
              : null,
          "odometer": currentOdometer.value,
          "status": selectedStatus.value,
          "service_date": serviceDate,
          "workshop_name": bengkelController.text,
          "cost": biayaController.text.isEmpty
              ? 0
              : int.parse(biayaController.text),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchHome(force: true);
        }
        if (Get.isRegistered<KendaraanController>()) {
          Get.find<KendaraanController>().getVehicles(force: true);
        }

        AppSnackbar.success("Data berhasil disimpan.");

        Get.offNamed('/rwtservis');
      } else {
        String msg = "Gagal menyimpan riwayat servis";
        try {
          final err = jsonDecode(response.body);
          if (err is Map && (err['message'] != null || err['error'] != null)) {
            msg = err['message'] ?? err['error'];
          }
        } catch (_) {}
        Get.snackbar("Error", msg);
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        Get.snackbar("Error", "Gagal menyimpan riwayat servis");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRiwayat() async {
    if (!odometerUpdatedToday.value) {
      Get.snackbar("Perhatian", "Update odometer terlebih dahulu");
      return;
    }

    if (selectedStatus.value == "Selesai" && biayaController.text.isEmpty) {
      Get.snackbar("Error", "Biaya servis wajib diisi");
      return;
    }

    if (selectedJenis.value == "Servis Rutin" &&
        selectedComponentId.value == 0) {
      Get.snackbar("Error", "Pilih komponen terlebih dahulu");
      return;
    }

    if (selectedJenis.value == "Perbaikan" &&
        detailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Detail perbaikan wajib diisi');
      return;
    }
    if (tanggalController.text.isEmpty || bengkelController.text.isEmpty) {
      Get.snackbar('Error', 'Semua field wajib diisi');
      return;
    }

    try {
      isLoading.value = true;

      final token = box.read("token");
      final vehicleId = box.read("vehicle_id");
      final serviceDate =
          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

      final response = await http.put(
        Uri.parse("$baseUrl/api/vehicle/service-history/${serviceId.value}"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "vehicle_id": vehicleId,
          "component_id": selectedJenis.value == "Servis Rutin"
              ? selectedComponentId.value
              : null,
          "service_type": selectedJenis.value,
          "detail": selectedJenis.value == "Perbaikan"
              ? detailController.text
              : null,
          "odometer": currentOdometer.value,
          "status": selectedStatus.value,
          "service_date": serviceDate,
          "workshop_name": bengkelController.text,
          "cost": biayaController.text.isEmpty
              ? 0
              : int.parse(biayaController.text),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchHome(force: true);
        }
        if (Get.isRegistered<KendaraanController>()) {
          Get.find<KendaraanController>().getVehicles(force: true);
        }

        AppSnackbar.success("Data berhasil diperbarui.");

        Get.offNamed('/rwtservis');
      } else {
        String msg = "Gagal menyimpan riwayat servis";
        try {
          final err = jsonDecode(response.body);
          if (err is Map && (err['message'] != null || err['error'] != null)) {
            msg = err['message'] ?? err['error'];
          }
        } catch (_) {}
        Get.snackbar("Error", msg);
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        Get.snackbar("Error", "Gagal memperbarui riwayat servis");
      }
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    detailController.clear();
    tanggalController.clear();
    bengkelController.clear();
    biayaController.clear();
    selectedDate = null;
    selectedComponentId.value = 0;
    selectedJenis.value = "Servis Rutin";
    selectedStatus.value = "Dijadwalkan";
  }

  @override
  void onClose() {
    detailController.dispose();
    tanggalController.dispose();
    bengkelController.dispose();
    biayaController.dispose();
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().syncVehicleFromStorage();
    }
    super.onClose();
  }
}
