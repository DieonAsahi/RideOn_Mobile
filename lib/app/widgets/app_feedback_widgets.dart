import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Feedback reusable. Pemanggil cukup memakai contoh:
/// AppFeedback.loginFailed(); AppFeedback.registerSuccess();
class AppFeedback {
  static void _show({
    required String title,
    required String message,
    required bool error,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      backgroundColor: error
          ? const Color(0xFFFEE2E2)
          : const Color(0xFFDCFCE7),
      colorText: error ? const Color(0xFFB91C1C) : const Color(0xFF166534),
      icon: Icon(
        error ? Icons.error_outline : Icons.check_circle_outline,
        color: error ? const Color(0xFFB91C1C) : const Color(0xFF166534),
      ),
    );
  }

  static void loginFailed({String? message}) => _show(
    title: 'Login gagal',
    message: message?.trim().isNotEmpty == true
        ? message!.trim()
        : 'Periksa email dan kata sandi Anda.',
    error: true,
  );
  static Future<void> registerSuccess() => Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: const Icon(
        Icons.mark_email_read_outlined,
        color: Color(0xFF006BFF),
        size: 42,
      ),
      title: const Text('Akun berhasil dibuat', textAlign: TextAlign.center),
      content: const Text(
        'Silakan verifikasi email Anda, lalu login untuk melanjutkan.',
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(onPressed: Get.back, child: const Text('Mengerti')),
      ],
    ),
    barrierDismissible: false,
  );
  static void registerFailed({String? message}) => _show(
    title: 'Pendaftaran gagal',
    message: message?.trim().isNotEmpty == true
        ? message!.trim()
        : 'Silakan coba lagi.',
    error: true,
  );
  static void passwordChangeFailed({String? message}) => _show(
    title: 'Gagal mengubah kata sandi',
    message: message?.trim().isNotEmpty == true
        ? message!.trim()
        : 'Silakan coba lagi.',
    error: true,
  );
  static void profileUpdateFailed({String? message}) => _show(
    title: 'Gagal memperbarui profil',
    message: message?.trim().isNotEmpty == true
        ? message!.trim()
        : 'Silakan coba lagi.',
    error: true,
  );
  static void vehicleAddFailed({String? message}) => _show(
    title: 'Gagal menambahkan kendaraan',
    message: message?.trim().isNotEmpty == true
        ? message!.trim()
        : 'Silakan coba lagi.',
    error: true,
  );
  static void odometerUpdateFailed({String? message}) => _show(
    title: 'Gagal memperbarui odometer',
    message: message?.trim().isNotEmpty == true
        ? message!.trim()
        : 'Silakan coba lagi.',
    error: true,
  );
  static void serviceHistoryAddFailed({String? message}) => _show(
    title: 'Gagal menyimpan riwayat servis',
    message: message?.trim().isNotEmpty == true
        ? message!.trim()
        : 'Silakan coba lagi.',
    error: true,
  );
  static void serviceHistoryUpdateFailed({String? message}) => _show(
    title: 'Gagal memperbarui riwayat servis',
    message: message?.trim().isNotEmpty == true
        ? message!.trim()
        : 'Silakan coba lagi.',
    error: true,
  );
  static void diagnosisFailed({String? message}) => _show(
    title: 'Diagnosa gagal',
    message: message?.trim().isNotEmpty == true
        ? message!.trim()
        : 'Hasil diagnosa belum dapat dibuat. Silakan coba lagi.',
    error: true,
  );
  static void vehicleDeleteFailed({String? message}) => _show(
    title: 'Gagal menghapus kendaraan',
    message: message?.trim().isNotEmpty == true
        ? message!.trim()
        : 'Silakan coba lagi.',
    error: true,
  );
  static void serviceHistoryCancelFailed({String? message}) => _show(
    title: 'Gagal membatalkan servis',
    message: message?.trim().isNotEmpty == true
        ? message!.trim()
        : 'Silakan coba lagi.',
    error: true,
  );
  static void serviceHistoryDeleteFailed({String? message}) => _show(
    title: 'Gagal menghapus riwayat servis',
    message: message?.trim().isNotEmpty == true
        ? message!.trim()
        : 'Silakan coba lagi.',
    error: true,
  );
  static void serviceHistoryLoadFailed({String? message}) => _show(
    title: 'Gagal memuat riwayat servis',
    message: message?.trim().isNotEmpty == true
        ? message!.trim()
        : 'Silakan coba lagi.',
    error: true,
  );
  static void inputRequired({required String message}) =>
      _show(title: 'Data belum lengkap', message: message, error: true);
  static void cameraUnavailable({String? message}) => _show(
    title: 'Kamera tidak tersedia',
    message: message?.trim().isNotEmpty == true
        ? message!.trim()
        : 'Kamera tidak dapat diakses. Periksa izin kamera lalu coba lagi.',
    error: true,
  );
}

class LogoutProgressDialog extends StatelessWidget {
  const LogoutProgressDialog({super.key});

  static Future<void> show() =>
      Get.dialog(const LogoutProgressDialog(), barrierDismissible: false);

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sedang keluar',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Kami sedang mengamankan sesi Anda...',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class EmptyCostEstimate extends StatelessWidget {
  final VoidCallback? onRetry;
  const EmptyCostEstimate({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 54,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada estimasi biaya',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Data estimasi biaya belum tersedia saat ini.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Muat ulang'),
            ),
          ],
        ],
      ),
    ),
  );
}
