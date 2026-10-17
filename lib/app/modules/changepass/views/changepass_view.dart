import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';

import '../controllers/changepass_controller.dart';
import '../../../widgets/form_label_with_tooltip.dart';

class ChangepassView extends GetView<ChangepassController> {
  const ChangepassView({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = AppColors.primaryBlue;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 24),
              child: Center(
                child: Text(
                  controller.isFromProfile
                      ? "Ganti Kata Sandi"
                      : "Lupa Kata Sandi",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            // Bagian Form (Bisa di-scroll jika layar kecil)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= KATA SANDI LAMA (HANYA PROFIL) =================
                    if (controller.isFromProfile) ...[
                      const FormLabelWithTooltip(
                        label: 'Kata Sandi Lama',
                        message: 'Masukkan kata sandi yang sedang digunakan.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => TextField(
                          controller: controller.oldPassController,
                          obscureText: controller.isOldPassObscure.value,
                          keyboardType: TextInputType.visiblePassword,
                          decoration:
                              _inputDecoration(
                                "Masukkan kata sandi lama",
                                errorText: controller.oldPassError.value,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Image.asset(
                                    controller.isOldPassObscure.value
                                        ? 'assets/image/eye_close.png'
                                        : 'assets/image/eye.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                  onPressed: controller.toggleOldPassVisibility,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ================= KATA SANDI BARU =================
                    const FormLabelWithTooltip(
                      label: 'Kata Sandi Baru',
                      message:
                          'Minimal 8 karakter dan wajib mengandung huruf besar, huruf kecil, serta angka.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => TextField(
                        controller: controller.newPassController,
                        obscureText: controller.isNewPassObscure.value,
                        keyboardType: TextInputType.visiblePassword,
                        decoration:
                            _inputDecoration(
                              "Masukkan kata sandi baru",
                              errorText: controller.newPassError.value,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Image.asset(
                                  controller.isNewPassObscure.value
                                      ? 'assets/image/eye_close.png'
                                      : 'assets/image/eye.png',
                                  width: 24,
                                  height: 24,
                                ),
                                onPressed: controller.toggleNewPassVisibility,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ================= KONFIRMASI KATA SANDI BARU =================
                    const FormLabelWithTooltip(
                      label: 'Konfirmasi Kata Sandi Baru',
                      message:
                          'Ketik ulang kata sandi baru dengan persis sama.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => TextField(
                        controller: controller.confirmPassController,
                        obscureText: controller.isConfirmPassObscure.value,
                        keyboardType: TextInputType.visiblePassword,
                        decoration:
                            _inputDecoration(
                              "Masukkan kata sandi baru", // Mengikuti placeholder di desain
                              errorText: controller.confirmPassError.value,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Image.asset(
                                  controller.isConfirmPassObscure.value
                                      ? 'assets/image/eye_close.png'
                                      : 'assets/image/eye.png',
                                  width: 24,
                                  height: 24,
                                ),
                                onPressed:
                                    controller.toggleConfirmPassVisibility,
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ================= TOMBOL AKSI (DI BAWAH) =================
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          controller.isFromProfile ? 12 : 50,
                        ),
                      ),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.changePassword,
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            controller.isFromProfile ? "Simpan" : "Lanjutkan",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi Helper inputDecoration yang menerima parameter errorText
  InputDecoration _inputDecoration(String hint, {String? errorText}) {
    return InputDecoration(
      hintText: hint,
      errorText: errorText, // Menampilkan error text otomatis
      errorStyle: const TextStyle(color: AppColors.red, fontSize: 12),
      errorMaxLines: 3,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.red, width: 1.5),
      ),
    );
  }
}
