import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';
import '../controllers/pluskendaraan_controller.dart';
import '../../../widgets/form_label_with_tooltip.dart';
import '../../../widgets/base_bottom_sheet.dart';

class PluskendaraanView extends GetView<PluskendaraanController> {
  const PluskendaraanView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Colors.black,
            ),
            onPressed: () => _handleBackPress(context),
          ),
          centerTitle: true,
          title: const Text(
            "Tambah Kendaraan",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // ================= PROGRESS BAR 3 SEGMEN =================
              Obx(() => _buildProgressBar()),

              const SizedBox(height: 10),

              // ================= KONTEN FORM PER STEP =================
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Obx(() {
                    switch (controller.step.value) {
                      case 1:
                        return _buildStep1(context);
                      case 2:
                        return _buildStep2();
                      case 3:
                        return _buildStep3();
                      default:
                        return _buildStep1(context);
                    }
                  }),
                ),
              ),

              // ================= TOMBOL AKSI DI BAGIAN BAWAH =================
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Obx(() => _buildBottomButton()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= WIDGET PROGRESS BAR =================
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _buildProgressSegment(stepNumber: 1)),
          const SizedBox(width: 8),
          Expanded(child: _buildProgressSegment(stepNumber: 2)),
          const SizedBox(width: 8),
          Expanded(child: _buildProgressSegment(stepNumber: 3)),
        ],
      ),
    );
  }

  Widget _buildProgressSegment({required int stepNumber}) {
    final isActive = controller.step.value >= stepNumber;
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryBlue : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // ================= STEP 1: INFORMASI UMUM KENDARAAN =================
  Widget _buildStep1(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          'Merek Kendaraan',
          helperText: 'Pilih merek kendaraan sesuai STNK atau kendaraan Anda.',
        ),
        const SizedBox(height: 8),
        Obx(
          () => DropdownButtonFormField<String>(
            value: controller.selectedBrand.value.isEmpty
                ? null
                : controller.selectedBrand.value,
            hint: Text(
              "Merek",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
            items: controller.brandOptions
                .map(
                  (brand) => DropdownMenuItem(value: brand, child: Text(brand)),
                )
                .toList(),
            onChanged: controller.onBrandChanged,
            decoration: _inputDecoration(
              errorText: controller.brandError.value,
            ),
          ),
        ),

        const SizedBox(height: 18),

        _buildLabel(
          'Model Kendaraan',
          helperText: 'Pilih model yang sesuai dengan merek kendaraan.',
        ),
        const SizedBox(height: 8),
        Obx(() {
          final isEnabled = controller.isModelDropdownEnabled;
          final availableModels = controller.availableModels;
          final currentVal =
              availableModels.contains(controller.selectedModel.value)
              ? controller.selectedModel.value
              : null;

          return DropdownButtonFormField<String>(
            value: isEnabled ? currentVal : null,
            hint: Text(
              "Model",
              style: TextStyle(
                color: isEnabled ? Colors.grey.shade400 : Colors.grey.shade400,
                fontSize: 13,
              ),
            ),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: isEnabled ? Colors.black54 : Colors.grey.shade400,
            ),
            items: isEnabled
                ? availableModels
                      .map(
                        (model) =>
                            DropdownMenuItem(value: model, child: Text(model)),
                      )
                      .toList()
                : null,
            onChanged: isEnabled ? controller.onModelChanged : null,
            decoration: _inputDecoration(
              filled: !isEnabled,
              fillColor: isEnabled ? Colors.white : Colors.grey.shade100,
              errorText: controller.modelError.value,
            ),
          );
        }),

        const SizedBox(height: 18),

        _buildLabel(
          'Tahun Produksi',
          helperText:
              'Pilih tahun produksi kendaraan yang tertera pada dokumen kendaraan.',
        ),
        const SizedBox(height: 8),
        Obx(
          () => DropdownButtonFormField<String>(
            value: controller.selectedYear.value.isEmpty
                ? null
                : controller.selectedYear.value,
            hint: Text(
              "Tahun",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
            items: controller.yearOptions
                .map((year) => DropdownMenuItem(value: year, child: Text(year)))
                .toList(),
            onChanged: controller.onYearChanged,
            decoration: _inputDecoration(errorText: controller.yearError.value),
          ),
        ),

        const SizedBox(height: 18),

        _buildLabel(
          'Plat Nomor Kendaraan',
          helperText:
              'Gunakan format seperti A 1234 BC tanpa simbol atau tanda baca.',
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextField(
            controller: controller.platController,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(fontSize: 14),
            onChanged: (val) {
              if (controller.platError.value.isNotEmpty) {
                controller.platError.value = '';
              }
            },
            decoration: _inputDecoration(
              hintText: "Contoh : A 1234 BC",
              errorText: controller.platError.value,
            ),
          ),
        ),

        const SizedBox(height: 18),

        _buildLabel(
          'Gambar Kendaraan',
          helperText: 'Unggah foto kendaraan yang jelas agar mudah dikenali.',
        ),
        const SizedBox(height: 8),
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _showImageSourcePicker(context),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: controller.imageError.value.isNotEmpty
                          ? AppColors.red
                          : Colors.grey.shade300,
                      width: controller.imageError.value.isNotEmpty ? 1.2 : 1,
                    ),
                  ),
                  child: controller.selectedVehicleImage != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Image.file(
                                controller.selectedVehicleImage!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.file_upload_outlined,
                              size: 38,
                              color: AppColors.primaryBlue,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Unggah gambar",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (controller.imageError.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 12),
                  child: Text(
                    controller.imageError.value,
                    style: const TextStyle(color: AppColors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // ================= STEP 2: ESTIMASI HARIAN & ODOMETER =================
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          'Estimasi penggunaan harian',
          helperText:
              'Masukkan rata-rata jarak tempuh per hari dalam angka kilometer.',
        ),
        const SizedBox(height: 4),
        Text(
          "Anda tetap dapat memperbaharui odometer secara manual untuk mendapatkan angka yang akurat.",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => TextField(
            controller: controller.estimasiHarianController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],

            style: const TextStyle(fontSize: 14),
            onChanged: (val) {
              if (controller.estimasiError.value.isNotEmpty) {
                controller.estimasiError.value = '';
              }
            },
            decoration: _inputDecoration(
              hintText: "Contoh : 15",
              suffixText: "km/hari",
              errorText: controller.estimasiError.value,
            ),
          ),
        ),

        const SizedBox(height: 24),

        _buildLabel(
          'Angka Odometer',
          helperText:
              'Masukkan hanya angka kilometer saat ini, tanpa titik atau huruf.',
        ),
        const SizedBox(height: 12),
        Obx(
          () => TextField(
            controller: controller.odometerController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],

            style: const TextStyle(fontSize: 14),
            onChanged: (val) {
              if (controller.odometerError.value.isNotEmpty) {
                controller.odometerError.value = '';
              }
            },
            decoration: _inputDecoration(
              hintText: "Contoh : 4000",
              errorText: controller.odometerError.value,
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // ================= STEP 3: RIWAYAT KOMPONEN KENDARAAN =================
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Center(
          child: Text(
            "Waktu terakhir ganti komponen kendaraan",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Obx(
          () => Column(
            children: controller.komponen.map((item) {
              final errorText = controller.komponenErrors[item]?.value ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(
                      item,
                      helperText:
                          'Masukkan jumlah hari sejak komponen ini terakhir diganti.',
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.komponenControllers[item],
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(fontSize: 14),
                      onChanged: (val) {
                        if (controller.komponenErrors[item]?.value.isNotEmpty ??
                            false) {
                          controller.komponenErrors[item]?.value = '';
                        }
                      },
                      decoration: _inputDecoration(
                        hintText:
                            controller.komponenHints[item] ?? "Contoh : 30",
                        suffixText: "hari yang lalu",
                        errorText: errorText,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  void _showUnsavedChangesDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/warning.png',
                width: Get.width > 400 ? 90 : Get.width * 0.22,
                height: Get.width > 400 ? 90 : Get.width * 0.22,
              ),
              const SizedBox(height: 20),
              const Text(
                "Batalkan tambah kendaraan?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Data yang sudah diisi akan hilang jika Anda keluar sekarang.",
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
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            side: const BorderSide(
                              color: AppColors.primaryBlue,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Get.back();
                            controller.cancelAddingVehicle();
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
                    const SizedBox(width: 12),
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
                            "Lanjut Isi",
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

  void _handleBackPress(BuildContext context) {
    if (controller.step.value > 1) {
      controller.prevStep();
      return;
    }

    _showUnsavedChangesDialog(context);
  }

  // ================= BOTTOM BUTTON (LANJUT / SIMPAN) =================
  Widget _buildBottomButton() {
    if (controller.step.value < 3) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: controller.nextStep,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.white,
          ),
          child: const Text(
            "Lanjut",
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.saveVehicle,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: controller.isLoading.value
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
    );
  }

  // ================= HELPER WIDGETS & DECORATION =================
  Widget _buildLabel(String text, {required String helperText}) {
    return FormLabelWithTooltip(
      label: text,
      message: helperText,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hintText,
    String? suffixText,
    String? errorText,
    bool filled = false,
    Color? fillColor,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      suffixText: suffixText,
      suffixStyle: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      errorText: (errorText != null && errorText.isNotEmpty) ? errorText : null,
      errorStyle: const TextStyle(
        color: AppColors.red,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      errorMaxLines: 3,
      filled: filled,
      fillColor: fillColor ?? Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.red, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.red, width: 1.5),
      ),
    );
  }

  void _showImageSourcePicker(BuildContext context) {
    BaseBottomSheet.show(
      context: context,
      title: "Foto Kendaraan",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Image.asset(
              'assets/image/camera.png',
              width: 24,
              height: 24,
            ),
            title: const Text("Kamera", style: TextStyle(color: Colors.black)),
            onTap: () {
              Get.back();
              controller.pickVehicleImage(ImageSource.camera);
            },
          ),
          Divider(color: Colors.grey.shade300, height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Image.asset(
              'assets/image/galeri.png',
              width: 24,
              height: 24,
            ),
            title: const Text("Galeri", style: TextStyle(color: Colors.black)),
            onTap: () {
              Get.back();
              controller.pickVehicleImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }
}
