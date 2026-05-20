import 'package:get/get.dart';
import 'package:flutter/material.dart';

class RwttambahController extends GetxController {
  final detailController = TextEditingController();
  final tanggalController = TextEditingController();
  final odometerController = TextEditingController();
  final bengkelController = TextEditingController();
  final biayaController = TextEditingController();

  var selectedJenis = 'Servis Rutin'.obs;
  var selectedStatus = 'Dijadwalkan'.obs;
  var isStatusLocked = false.obs;

  @override
  void onInit() {
    super.onInit();

    // cek apakah datang dari tombol jadwalkan
    final args = Get.arguments;

    if (args != null && args['jadwalkan'] == true) {
      selectedStatus.value = 'Dijadwalkan';
      isStatusLocked.value = true;
    }
  }

  void changeJenis(String value) {
    selectedJenis.value = value;
  }

  void changeStatus(String value) {
    selectedStatus.value = value;
  }

  Future<void> pickDate() async {
    final pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      tanggalController.text =
          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    }
  }

  void simpanRiwayat() {
    if (detailController.text.isEmpty ||
        tanggalController.text.isEmpty ||
        odometerController.text.isEmpty ||
        bengkelController.text.isEmpty ||
        biayaController.text.isEmpty) {
      Get.snackbar('Error', 'Semua field wajib diisi');
      return;
    }

    Get.snackbar('Success', 'Riwayat servis berhasil disimpan');

    Get.offNamed('/rwtservis');
  }

  @override
  void onClose() {
    detailController.dispose();
    tanggalController.dispose();
    odometerController.dispose();
    bengkelController.dispose();
    biayaController.dispose();
    super.onClose();
  }
}
