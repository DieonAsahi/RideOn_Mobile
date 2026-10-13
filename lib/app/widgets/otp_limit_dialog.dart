import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpLimitDialog {
  /// Tampilkan modal dialog mencapai batas permintaan OTP sesuai desain referensi
  static void show({String? customTime}) {
    // Tutup dialog lama jika ada
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    // Default waktu kembali adalah 1 jam ke depan dengan format HH.mm (contoh: 17.47)
    final nextHour = DateTime.now().add(const Duration(hours: 1));
    final retryTime =
        customTime ??
        "${nextHour.hour.toString().padLeft(2, '0')}.${nextHour.minute.toString().padLeft(2, '0')}";

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo/limit_otp.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: Color(0xFF2196F3),
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Mencapai Batas Permintaan OTP",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF4A4A4A),
                    height: 1.45,
                  ),
                  children: [
                    TextSpan(
                      text:
                          "Anda telah mencapai batas permintaan kode OTP, silahkan kembali lagi pukul ",
                    ),
                    TextSpan(
                      text: retryTime,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 140,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF2196F3),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Kembali",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2196F3),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// Helper untuk mendeteksi apakah respons error dari backend berkaitan dengan limit OTP Supabase
  static bool isOtpLimitError(dynamic error, {int? statusCode}) {
    if (statusCode == 429) return true;
    if (error == null) return false;
    final msg = error.toString().toLowerCase();
    return msg.contains("rate limit") ||
        msg.contains("rate_limit") ||
        msg.contains("over_email_send_rate_limit") ||
        msg.contains("too many requests") ||
        msg.contains("security purposes") ||
        msg.contains("batas permintaan") ||
        msg.contains("email rate limit");
  }
}
