import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';

import '../controllers/otpemail_controller.dart';
import '../../../widgets/form_label_with_tooltip.dart';

class OtpemailView extends GetView<OtpemailController> {
  const OtpemailView({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = AppColors.primaryBlue;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              // ================= GAMBAR ASET =================
              Image.asset(
                'assets/logo/otp.png',
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.mark_email_read,
                  size: 100,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 30),

              // ================= TEKS JUDUL =================
              const Text(
                "Verifikasi Email",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // ================= TEKS DESKRIPSI =================
              Text(
                "Kami telah mengirimkan kode verifikasi ke email Anda. Masukkan 6 digit kode untuk melanjutkan.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  children: [
                    const TextSpan(text: "Kode dikirimkan ke email "),
                    TextSpan(
                      text: controller.getMaskedEmail(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ================= KOTAK INPUT OTP (6 DIGIT) =================
              const FormLabelWithTooltip(
                label: 'Kode OTP',
                message:
                    'Masukkan enam angka yang dikirim ke alamat email Anda. Kode berlaku selama tiga menit.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    height: 55,
                    child: Obx(() {
                      final hasError = controller.otpError.value != null;
                      return TextField(
                        controller: controller.controllers[index],
                        focusNode: controller.focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor: hasError
                              ? AppColors.errorSurface
                              : Colors.grey.shade50,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: hasError
                                  ? AppColors.red
                                  : Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: hasError
                                  ? AppColors.red
                                  : Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: hasError ? AppColors.red : primaryBlue,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) =>
                            controller.onChanged(index, value),
                      );
                    }),
                  );
                }),
              ),

              // ================= ERROR TEXT MERAH DI BAWAH KOTAK OTP =================
              Obx(() {
                if (controller.otpError.value != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      controller.otpError.value!,
                      style: const TextStyle(
                        color: AppColors.red,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              const SizedBox(height: 25),

              // ================= INFO SISA WAKTU =================
              Obx(() {
                if (controller.isOtpExpired.value) {
                  return const Text(
                    "Kode OTP sudah kadaluarsa.",
                    style: TextStyle(color: AppColors.red, fontSize: 13),
                  );
                } else {
                  final minutes = (controller.otpExpiredSeconds.value ~/ 60)
                      .toString()
                      .padLeft(2, '0');
                  final seconds = (controller.otpExpiredSeconds.value % 60)
                      .toString()
                      .padLeft(2, '0');
                  return Text(
                    "Sisa waktu: $minutes:$seconds",
                    style: TextStyle(
                      color: AppColors.orange,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }
              }),

              const SizedBox(height: 15),

              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "Tidak menerima kode OTP? ",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                  Obx(
                    () => GestureDetector(
                      onTap: controller.isCooldown.value
                          ? null
                          : controller.resendOtp,
                      child: Text(
                        controller.isCooldown.value
                            ? "Kirim ulang dalam ${controller.secondsRemaining.value}s"
                            : "Kirim ulang",
                        style: TextStyle(
                          color: controller.isCooldown.value
                              ? Colors.grey.shade400
                              : primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

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
                  onPressed: controller.verifyOtp,
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
}
