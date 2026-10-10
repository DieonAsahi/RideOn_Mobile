import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/connectivity_service.dart';
import '../core/theme/app_theme.dart';

class GlobalNoInternetOverlay extends StatefulWidget {
  const GlobalNoInternetOverlay({super.key});

  @override
  State<GlobalNoInternetOverlay> createState() =>
      _GlobalNoInternetOverlayState();
}

class _GlobalNoInternetOverlayState extends State<GlobalNoInternetOverlay> {
  bool _showRetryError = false;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ConnectivityService>()) {
      return const SizedBox.shrink();
    }

    final conn = ConnectivityService.to;

    return Obx(() {
      if (!conn.isOffline.value) {
        return const SizedBox.shrink();
      }

      return Positioned.fill(
        child: Material(
          color: Colors.white,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ilustrasi tidak ada koneksi
                      Image.asset(
                        'assets/logo/no_internet.png',
                        width: 280,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/logo/no_internet.png',
                          width: 260,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.wifi_off_rounded,
                            size: 100,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Judul
                      Text(
                        "Tidak ada koneksi internet",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        "Periksa jaringan Anda dan muat ulang\nhalaman",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Tombol Muat ulang (Outlined sesuai mockup)
                      Obx(
                        () => OutlinedButton(
                          onPressed: conn.isChecking.value
                              ? null
                              : () async {
                                  setState(() => _showRetryError = false);
                                  final ok = await conn.checkConnection();
                                  if (ok) {
                                    conn.reloadActiveControllers();
                                  } else {
                                    setState(() => _showRetryError = true);
                                  }
                                },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryBlue,
                            side: const BorderSide(
                              color: AppColors.primaryBlue,
                              width: 1.6,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: conn.isChecking.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryBlue,
                                  ),
                                )
                              : Text(
                                  "Muat ulang",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                        ),
                      ),

                      // Notifikasi jika koneksi masih belum tersedia
                      if (_showRetryError) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFCC80)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 18,
                                color: AppColors.orange,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  "Koneksi belum tersedia. Pastikan Wi-Fi atau Data Seluler aktif.",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
