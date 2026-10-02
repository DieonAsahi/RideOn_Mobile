import 'dart:ui'; // Wajib di-import untuk ImageFilter (efek blur)

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/bengkel_controller.dart';

class BengkelView extends GetView<BengkelController> {
  const BengkelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 1. SEMBUNYIKAN FAB JIKA IZIN BELUM ADA ATAU GPS MATI
      floatingActionButton: Obx(() {
        if (!controller.isPermissionGranted.value ||
            (!controller.isGpsEnabled.value &&
                !controller.isGpsDismissed.value)) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton.extended(
          backgroundColor: const Color(0xFF006BFF),
          onPressed: () {
            Get.toNamed('/petabengkel');
          },
          icon: const Icon(Icons.map_outlined, color: Colors.white),
          label: const Text(
            "Lihat Peta",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        );
      }),

      // 2. GUNAKAN STACK UNTUK MENUMPUK POP-UP DI ATAS SELURUH LAYAR
      body: Stack(
        children: [
          /// ==========================================
          /// LAYER 1: KONTEN UTAMA (HEADER, SEARCH, LIST)
          /// ==========================================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios),
                      ),
                      const Expanded(
                        child: Text(
                          "Bengkel Terdekat",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: Obx(() {
                      // KONDISI 1: IZIN LOKASI BELUM DIBERIKAN
                      if (!controller.isPermissionGranted.value) {
                        return Align(
                          alignment: const Alignment(0.0, -0.2),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/logo/missing_lokasi.png',
                                height: 160,
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                "Izin lokasi diperlukan",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Izinkan akses lokasi agar kami dapat menemukan bengkel terdekat dari lokasi Anda.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () =>
                                    controller.requestLocationPermission(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF006BFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  "Izinkan Lokasi",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // KONDISI 2: JIKA IZIN SUDAH ADA TAPI GPS MATI
                      // Kita biarkan background tetap me-render list/kosong/loading
                      // karena pop-up akan menutupi layar ini dari Layer 2 (Stack)

                      return Column(
                        children: [
                          TextField(
                            controller: controller.searchController,
                            onChanged: controller.searchBengkel,
                            decoration: InputDecoration(
                              hintText: "Cari bengkel...",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                              suffixIcon: SizedBox(
                                width: 20,
                                height: 20,
                                child: Center(
                                  child: Image.asset(
                                    "assets/icon/search.png",
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Expanded(
                            child: () {
                              if (controller.isLoading.value) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (controller.filteredBengkelList.isEmpty) {
                                return Align(
                                  alignment: const Alignment(0.0, -0.3),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/logo/missing_lokasi.png',
                                        height: 160,
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        "Bengkel tidak ditemukan",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Tidak ada bengkel yang sesuai dengan pencarian Anda.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount:
                                    controller.filteredBengkelList.length,
                                itemBuilder: (context, index) {
                                  final item =
                                      controller.filteredBengkelList[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 18),
                                    // ... (KODE DESAIN CARD LIST BENGKEL ANDA TETAP SAMA SEPERTI SEBELUMNYA)
                                  );
                                },
                              );
                            }(),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          /// ==========================================
          /// LAYER 2: OVERLAY POP-UP ANIMASI (Hanya jika GPS Mati)
          /// ==========================================
          Obx(() {
            if (controller.isPermissionGranted.value &&
                !controller.isGpsEnabled.value &&
                !controller.isGpsDismissed.value) {
              return Positioned.fill(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // A. BLOKIR LAYAR & EFEK BLUR BACKGROUND
                    BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 4.0,
                        sigmaY: 4.0,
                      ), // Intensitas blur
                      child: Container(
                        color: Colors.black.withOpacity(
                          0.4,
                        ), // Warna gelap transparan
                      ),
                    ),

                    // B. ANIMASI MANTUL (POP)
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutBack, // Memberikan efek memantul
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value.clamp(0.0, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/logo/missing_lokasi.png',
                                height: 120,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Lokasi perangkat tidak aktif",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Aktifkan layanan lokasi perangkat untuk menemukan bengkel terdekat dari lokasi Anda.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 28),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        controller.dismissGpsDialog();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Color(0xFF006BFF),
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                      ),
                                      child: const Text(
                                        "Nanti",
                                        style: TextStyle(
                                          color: Color(0xFF006BFF),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          controller.openGpsSettings(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF006BFF,
                                        ),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                      ),
                                      child: const Text(
                                        "Aktifkan",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
