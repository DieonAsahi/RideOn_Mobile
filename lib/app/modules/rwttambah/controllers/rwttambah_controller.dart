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
import 'package:capbatu/app/modules/rwtservis/controllers/rwtservis_controller.dart';

class RwttambahController extends GetxController {
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  final detailController = TextEditingController();
  final tanggalController = TextEditingController();
  final bengkelController = TextEditingController();
  final biayaController = TextEditingController();

  DateTime? selectedDate;

  var isEdit = false.obs;
  var originalStatus = ''.obs;
  var serviceId = 0.obs;

  var currentOdometer = 0.obs;
  var existingOdometer = 0.obs;
  var odometerUpdatedToday = false.obs;

  var selectedComponentId = 0.obs;
  var components = <Map<String, dynamic>>[].obs;

  var selectedJenis = 'Servis Rutin'.obs;
  var selectedStatus =
      ''.obs; // 🌟 Diubah ke String kosong agar tidak auto preselect

  // 🌟 Variable penampung inline validation error text
  var componentError = RxnString();
  var detailError = RxnString();
  var tanggalError = RxnString();
  var bengkelError = RxnString();
  var biayaError = RxnString();
  var statusError = RxnString();
  var odometerError = RxnString();

  final box = GetStorage();
  var isLoading = false.obs;

  /// State Machine Dropdown Status
  List<String> get availableStatusOptions {
    if (!isEdit.value) {
      // 1. TAMBAH SERVIS: Hanya bisa "Dijadwalkan" atau "Proses"[cite: 3]
      return ['Dijadwalkan', 'Proses'];
    }
    // 2. EDIT (Berasal dari "Selesai"): Tetap "Selesai" & terkunci (dropdown disable)[cite: 6]
    if (originalStatus.value == 'Selesai') {
      return ['Selesai'];
    }
    // 3. EDIT (Berasal dari status non-Selesai): Bebas memilih "Dijadwalkan", "Proses", "Selesai" (misal: reschedule)[cite: 2]
    return ['Dijadwalkan', 'Proses', 'Selesai'];
  }

  // Aktifkan dropdown kecuali jika status aslinya 'Selesai'[cite: 6]
  bool get isStatusDropdownEnabled {
    if (isEdit.value && originalStatus.value == 'Selesai') {
      return false;
    }
    return true;
  }

  bool get isComponentEnabled => !isEdit.value;
  bool get isJenisEnabled => !isEdit.value;
  bool get isDetailEnabled =>
      !isEdit.value || originalStatus.value != 'Selesai';

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
      selectedJenis.value = 'Servis Rutin';

      if (args['component'] != null) {
        final comp = args['component'];
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

      final rawStatus = data['status']?.toString() ?? '';
      originalStatus.value = rawStatus == 'Diproses' ? 'Proses' : rawStatus;

      // 🌟 Ambil status aslinya, tidak auto-select (auto pre-select ditiadakan)[cite: 6]
      selectedStatus.value = originalStatus.value;

      bengkelController.text = data['bengkel'] ?? '';

      selectedJenis.value = data['jenis'] == 'SERVIS RUTIN'
          ? 'Servis Rutin'
          : 'Perbaikan';

      tanggalController.text = data['tanggal'] ?? '';
      try {
        selectedDate = DateTime.parse(data['tanggal']);
      } catch (_) {
        selectedDate = DateTime.now();
      }

      biayaController.text = (data['biaya'] == null || data['biaya'] == '-')
          ? ''
          : data['biaya']
                .toString()
                .replaceAll('Rp ', '')
                .replaceAll('.', '')
                .trim();

      detailController.text = data['jenis'] == 'PERBAIKAN'
          ? (data['detail'] ?? '')
          : '';

      if (data['jenis'] == 'SERVIS RUTIN') {
        selectedComponentId.value = data['component_id'] ?? 0;
      }

      if (data['odometer'] != null) {
        final odoStr = data['odometer'].toString().replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );
        existingOdometer.value = int.tryParse(odoStr) ?? 0;
      }
    } else {
      isEdit.value = false;
      originalStatus.value = '';
      selectedStatus.value =
          ''; // Tambah servis default tidak auto-select agar "Pilih Status" muncul[cite: 5]
    }
  }

  void changeJenis(String value) {
    selectedJenis.value = value;
    // Reset error text
    componentError.value = null;
    detailError.value = null;
  }

  void changeStatus(String value) {
    selectedStatus.value = value;
    statusError.value = null;
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
          final updatedAt = DateTime.parse(
            data["last_odometer_update"],
          ).toLocal();

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
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      selectedDate = pickedDate;
      tanggalError.value = null; // hapus error
      tanggalController.text =
          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    }
  }

  // Melakukan validasi semua field, mengembalikan true jika valid
  bool validateFields() {
    bool isValid = true;

    // Reset error
    odometerError.value = null;
    biayaError.value = null;
    componentError.value = null;
    detailError.value = null;
    tanggalError.value = null;
    bengkelError.value = null;
    statusError.value = null;

    // Cek Odometer (Jika tambah, wajib update hari ini)[cite: 2]
    if (!isEdit.value && !odometerUpdatedToday.value) {
      odometerError.value = "Update odometer terlebih dahulu sebelum menyimpan";
      isValid = false;
    }

    // Cek Status dropdown
    if (selectedStatus.value.isEmpty) {
      statusError.value = "Silakan pilih status riwayat servis terlebih dahulu";
      isValid = false;
    }

    // Cek Biaya (Jika status yang dipilih atau diganti adalah 'Selesai')[cite: 6]
    if (selectedStatus.value == "Selesai" &&
        biayaController.text.trim().isEmpty) {
      biayaError.value = "Biaya servis wajib diisi";
      isValid = false;
    }

    // Cek Komponen (Servis Rutin)
    if (selectedJenis.value == "Servis Rutin" &&
        selectedComponentId.value == 0) {
      componentError.value = "Komponen harus dipilih";
      isValid = false;
    }

    // Cek Detail (Perbaikan)
    if (selectedJenis.value == "Perbaikan" &&
        detailController.text.trim().isEmpty) {
      detailError.value = "Detail perbaikan wajib diisi";
      isValid = false;
    }

    // Cek Tanggal
    if (tanggalController.text.isEmpty) {
      tanggalError.value = "Tanggal tidak boleh kosong";
      isValid = false;
    }

    // Cek Nama Bengkel
    if (bengkelController.text.trim().isEmpty) {
      bengkelError.value = "Nama bengkel tidak boleh kosong";
      isValid = false;
    }

    return isValid;
  }

  Future<void> simpanRiwayat() async {
    if (isLoading.value) return;
    if (!validateFields()) return;

    try {
      isLoading.value = true;

      final token = box.read("token");
      final vehicleId = box.read("vehicle_id");
      final date = selectedDate ?? DateTime.now();
      final serviceDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final cleanCost = biayaController.text.trim().isEmpty
          ? 0
          : (int.tryParse(
                  biayaController.text.replaceAll(RegExp(r'[^0-9]'), ''),
                ) ??
                0);

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
          "cost": cleanCost,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchHome(force: true);
        }
        if (Get.isRegistered<KendaraanController>()) {
          Get.find<KendaraanController>().getVehicles(force: true);
        }
        if (Get.isRegistered<ServiceController>()) {
          Get.find<ServiceController>().getServices(force: true);
        }
        if (Get.isRegistered<RwtservisController>()) {
          Get.find<RwtservisController>().loadServiceHistory();
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
        AppFeedback.serviceHistoryAddFailed(message: msg);
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        AppFeedback.serviceHistoryAddFailed(
          message: 'Gagal menyimpan riwayat servis, periksa koneksi Anda.',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRiwayat() async {
    if (isLoading.value) return;
    if (!validateFields()) return;

    try {
      isLoading.value = true;

      final token = box.read("token");
      final vehicleId = box.read("vehicle_id");
      final date = selectedDate ?? DateTime.now();
      final serviceDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final cleanCost = biayaController.text.trim().isEmpty
          ? 0
          : (int.tryParse(
                  biayaController.text.replaceAll(RegExp(r'[^0-9]'), ''),
                ) ??
                0);

      final odoToSend = existingOdometer.value > 0
          ? existingOdometer.value
          : currentOdometer.value;

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
          "odometer": odoToSend,
          "status": selectedStatus.value,
          "service_date": serviceDate,
          "workshop_name": bengkelController.text,
          "cost": cleanCost,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchHome(force: true);
        }
        if (Get.isRegistered<KendaraanController>()) {
          Get.find<KendaraanController>().getVehicles(force: true);
        }
        if (Get.isRegistered<ServiceController>()) {
          Get.find<ServiceController>().getServices(force: true);
        }
        if (Get.isRegistered<RwtservisController>()) {
          Get.find<RwtservisController>().loadServiceHistory();
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
        AppFeedback.serviceHistoryUpdateFailed(message: msg);
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        AppFeedback.serviceHistoryUpdateFailed(
          message: 'Gagal memperbarui riwayat servis, periksa koneksi Anda.',
        );
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
    selectedStatus.value = ""; // reset to empty to allow default placeholder
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
