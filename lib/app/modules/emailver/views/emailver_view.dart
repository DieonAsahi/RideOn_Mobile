import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';
import '../controllers/emailver_controller.dart';
import '../../../widgets/form_label_with_tooltip.dart';

class EmailverView extends GetView<EmailverController> {
  const EmailverView({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = AppColors.primaryBlue;

    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih bersih
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),

              // ================= GAMBAR ASET =================
              Image.asset(
                'assets/logo/verif.png', // Sesuai permintaan
                height: 140, // Ukuran disesuaikan agar proporsional
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.security, // Fallback icon jika gambar belum ada
                  size: 100,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 30),

              // ================= TEKS JUDUL =================
              const Text(
                "Konfirmasi Email Anda",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // ================= TEKS DESKRIPSI =================
              Text(
                "Demi keamanan, kami akan mengirim kode verifikasi ke email yang terdaftar di akun Anda.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),

              // ================= TEXT FIELD EMAIL =================
              const FormLabelWithTooltip(
                label: 'Email',
                message:
                    'Masukkan alamat email akun yang terdaftar agar kami dapat mengirim kode pemulihan.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => TextField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    "Masukkan email terdaftar",
                    errorText: controller.emailError.value,
                  ),
                ),
              ),
              const SizedBox(height: 35),

              // ================= TOMBOL LANJUTKAN =================
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  onPressed: controller.sendOtp,
                  child: const Text(
                    "Lanjutkan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

  // Helper untuk form decoration (Sama seperti Login/Register tanpa Prefix Icon)
  InputDecoration _inputDecoration(String hint, {String? errorText}) {
    return InputDecoration(
      hintText: hint,
      errorText: errorText,
      errorMaxLines: 3,
      errorStyle: const TextStyle(color: AppColors.red, fontSize: 12),
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.red, width: 1.5),
      ),
    );
  }
}
