import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/changepass_controller.dart';

class ChangepassView extends GetView<ChangepassController> {
  const ChangepassView({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2196F3);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Bagian Form (Bisa di-scroll jika layar kecil)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ================= JUDUL DINAMIS =================
                    Center(
                      child: Text(
                        controller.isFromProfile
                            ? "Ganti Kata Sandi"
                            : "Lupa Kata Sandi",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ================= KATA SANDI LAMA (HANYA PROFIL) =================
                    if (controller.isFromProfile) ...[
                      const Text(
                        "Kata Sandi Lama",
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
                                        ? 'assets/icons/eye_close.png'
                                        : 'assets/icons/eye.png',
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
                    const Text(
                      "Kata Sandi Baru",
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
                                      ? 'assets/icons/eye_close.png'
                                      : 'assets/icons/eye.png',
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
                    const Text(
                      "Konfirmasi Kata Sandi Baru",
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
                                      ? 'assets/icons/eye_close.png'
                                      : 'assets/icons/eye.png',
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

            // ================= TOMBOL LANJUTKAN (DI BAWAH) =================
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
                        borderRadius: BorderRadius.circular(25),
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
                        : const Text(
                            "Lanjutkan", // Mengikuti teks tombol di desain
                            style: TextStyle(
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
      errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
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
        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}
