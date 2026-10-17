import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/rwttambah_controller.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';
import '../../../widgets/form_label_with_tooltip.dart';

class RwttambahView extends GetView<RwttambahController> {
  const RwttambahView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        if (controller.isEdit.value) {
          _showUnsavedChangesDialog(context);
        } else {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        // Logika yang sama juga diterapkan di tombol back AppBar
                        if (controller.isEdit.value) {
                          _showUnsavedChangesDialog(context);
                        } else {
                          Get.back();
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                    Expanded(
                      child: Obx(
                        () => Text(
                          controller.isEdit.value
                              ? "Edit Servis"
                              : "Tambah Servis",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FormLabelWithTooltip(
                        label: 'Jenis',
                        message:
                            'Pilih Servis Rutin untuk perawatan berkala atau Perbaikan untuk kerusakan tertentu.',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),

                      const SizedBox(height: 10),

                      Obx(
                        () => Row(
                          children: [
                            _jenisButton(
                              title: 'Servis Rutin',
                              selected:
                                  controller.selectedJenis.value ==
                                  'Servis Rutin',
                              enabled: controller.isJenisEnabled,
                              onTap: () =>
                                  controller.changeJenis('Servis Rutin'),
                            ),
                            const SizedBox(width: 10),
                            _jenisButton(
                              title: 'Perbaikan',
                              selected:
                                  controller.selectedJenis.value == 'Perbaikan',
                              enabled: controller.isJenisEnabled,
                              onTap: () => controller.changeJenis('Perbaikan'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ================= KOLOM DINAMIS (DETAIL / KOMPONEN) =================
                      Obx(() {
                        if (controller.selectedJenis.value == 'Perbaikan') {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _inputLabel(
                                'Detail',
                                helperText:
                                    'Jelaskan pekerjaan perbaikan yang dilakukan.',
                              ),
                              const SizedBox(height: 8),
                              _textField(
                                controller: controller.detailController,
                                hint: "Contoh : Ganti Kampas Rem",
                                readOnly: !controller.isDetailEnabled,
                                errorText: controller
                                    .detailError
                                    .value, // Inline error
                              ),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _inputLabel(
                              'Komponen',
                              helperText:
                                  'Pilih komponen yang diservis dari daftar yang tersedia.',
                            ),
                            const SizedBox(height: 8),

                            DropdownButtonFormField<int>(
                              value: controller.selectedComponentId.value == 0
                                  ? null
                                  : controller.selectedComponentId.value,
                              hint: const Text(
                                "Pilih Komponen",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              items: controller.components.map((item) {
                                return DropdownMenuItem<int>(
                                  value: item["id"],
                                  child: Text(item["name"]),
                                );
                              }).toList(),
                              onChanged: controller.isComponentEnabled
                                  ? (value) {
                                      if (value != null) {
                                        controller.selectedComponentId.value =
                                            value;
                                        controller.componentError.value = null;
                                      }
                                    }
                                  : null,
                              decoration: InputDecoration(
                                fillColor: controller.isComponentEnabled
                                    ? Colors.white
                                    : Colors.grey.shade100,
                                filled: !controller.isComponentEnabled,
                                errorText: controller.componentError.value,
                                errorStyle: const TextStyle(
                                  color: AppColors.red,
                                  fontSize: 11,
                                ),
                                errorMaxLines: 3,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryBlue,
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: AppColors.red,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: AppColors.red,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),

                      const SizedBox(height: 20),

                      // ================= TANGGAL =================
                      _inputLabel(
                        'Tanggal',
                        helperText:
                            'Pilih tanggal saat servis atau perbaikan dilakukan.',
                      ),
                      const SizedBox(height: 8),

                      Obx(
                        () => TextField(
                          controller: controller.tanggalController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'dd/mm/yyyy',
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            errorText:
                                controller.tanggalError.value, // Inline error
                            errorStyle: const TextStyle(
                              color: AppColors.red,
                              fontSize: 11,
                            ),
                            errorMaxLines: 3,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            suffixIcon: IconButton(
                              onPressed: controller.pickDate,
                              icon: Image.asset(
                                'assets/icon/calender.png',
                                width: 20,
                                height: 20,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.primaryBlue,
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.red,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.red,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= ODOMETER =================
                      _inputLabel(
                        'Odometer (km)',
                        helperText:
                            'Nilai ini berasal dari odometer kendaraan yang telah diperbarui hari ini.',
                      ),
                      const SizedBox(height: 8),

                      Obx(
                        () => InputDecorator(
                          decoration: InputDecoration(
                            suffixText: 'km',
                            errorText: controller.odometerError.value,
                            errorStyle: const TextStyle(
                              color: AppColors.red,
                              fontSize: 11,
                            ),
                            errorMaxLines: 3,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.primaryBlue,
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.red,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.red,
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: Text(
                            controller.currentOdometer.value.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= NAMA BENGKEL =================
                      _inputLabel(
                        'Nama Bengkel',
                        helperText:
                            'Masukkan nama bengkel atau tempat servis yang menangani kendaraan.',
                      ),
                      const SizedBox(height: 8),

                      Obx(
                        () => _textField(
                          controller: controller.bengkelController,
                          hint: "Contoh : Bengkel Motor Jaya",
                          errorText:
                              controller.bengkelError.value, // Inline error
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= TOTAL BIAYA (Conditional seandainya status Selesai) =================
                      Obx(() {
                        if (controller.selectedStatus.value != "Selesai") {
                          return const SizedBox();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _inputLabel(
                              'Total Biaya',
                              helperText:
                                  'Masukkan total biaya servis dalam angka Rupiah tanpa titik atau huruf.',
                            ),
                            const SizedBox(height: 8),

                            TextField(
                              controller: controller.biayaController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],

                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                prefixText: 'Rp ',
                                errorText:
                                    controller.biayaError.value, // Inline error
                                errorStyle: const TextStyle(
                                  color: AppColors.red,
                                  fontSize: 11,
                                ),
                                errorMaxLines: 3,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryBlue,
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: AppColors.red,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: AppColors.red,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      }),

                      // ================= STATUS DENGAN PLACEHOLDER =================
                      _inputLabel(
                        'Status',
                        helperText:
                            'Pilih status pekerjaan servis yang sesuai.',
                      ),
                      const SizedBox(height: 8),

                      Obx(() {
                        final options = controller.availableStatusOptions;
                        final String? currentValue =
                            options.contains(controller.selectedStatus.value) &&
                                controller.selectedStatus.value.isNotEmpty
                            ? controller.selectedStatus.value
                            : null;

                        return DropdownButtonFormField<String>(
                          value: currentValue,
                          hint: const Text(
                            "Pilih Status",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          items: options
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: controller.isStatusDropdownEnabled
                              ? (value) {
                                  if (value != null) {
                                    controller.changeStatus(value);
                                  }
                                }
                              : null,
                          decoration: InputDecoration(
                            fillColor: controller.isStatusDropdownEnabled
                                ? Colors.white
                                : Colors.grey.shade100,
                            filled: !controller.isStatusDropdownEnabled,
                            errorText: controller.statusError.value,
                            errorStyle: const TextStyle(
                              color: AppColors.red,
                              fontSize: 11,
                            ),
                            errorMaxLines: 3,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.primaryBlue,
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.red,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.red,
                                width: 1.5,
                              ),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // ================= TOMBOL SIMPAN (STICKY DI BAWAH) =================
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (controller.isEdit.value) {
                        controller.updateRiwayat();
                      } else {
                        controller.simpanRiwayat();
                      }
                    },
                    child: Obx(
                      () => controller.isLoading.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Simpan",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputLabel(String title, {required String helperText}) {
    return FormLabelWithTooltip(
      label: title,
      message: helperText,
      style: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        color: Colors.black,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    String? hint,
    bool readOnly = false,
    String? errorText, // Menerima feedback inline error
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        filled: readOnly,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        errorText: errorText, // Set inline validasi
        errorStyle: const TextStyle(color: AppColors.red, fontSize: 11),
        errorMaxLines: 3,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        ),
      ),
      style: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        color: Colors.black,
      ),
    );
  }

  Widget _jenisButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primaryBlue : AppColors.cardBorder,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: selected ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showUnsavedChangesDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        // 🌟 KUNCI RESPONSIVE 1: Bungkus dengan Container dan batasi Max Width
        child: Container(
          constraints: const BoxConstraints(
            maxWidth:
                400, // Di tablet, lebarnya akan mentok di 400px (tidak kepanjangan)
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Agar tinggi menyesuaikan isi
            children: [
              // 🌟 KUNCI RESPONSIVE 2: Gambar dinamis (maksimal 90px)
              Image.asset(
                'assets/icons/warning.png',
                width: Get.width > 400 ? 90 : Get.width * 0.22,
                height: Get.width > 400 ? 90 : Get.width * 0.22,
              ),
              const SizedBox(height: 20),

              const Text(
                "Perubahan belum disimpan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                "Anda akan kehilangan perubahan jika keluar sekarang.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5C5C5C),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [
                    // 🌟 KUNCI RESPONSIVE 3: Menggunakan Expanded agar membagi layar 50:50
                    Expanded(
                      child: SizedBox(
                        height: 42, // Tingginya tetap dikunci agar stabil
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            side: const BorderSide(
                              color: AppColors
                                  .primaryBlue, // Sesuaikan dengan warna Anda
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Get.back();
                            Get.back();
                          },
                          child: const Text(
                            "Keluar",
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Jarak yang fleksibel (tidak terlalu besar)
                    const SizedBox(width: 12),

                    // 🌟 KUNCI RESPONSIVE 3: Expanded kedua
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: AppColors.primaryBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Get.back();
                          },
                          child: const Text(
                            "Lanjut Edit",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
