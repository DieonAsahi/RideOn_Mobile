import 'dart:ui';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../controllers/bengkel_controller.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';

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

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: SizedBox(
            height: 40,
            child: FloatingActionButton.extended(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onPressed: () {
                Get.toNamed('/petabengkel');
              },
              icon: Image.asset('assets/image/peta.png', width: 18, height: 18),
              label: const Text(
                "Lihat Peta",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
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
              padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: Obx(() {
                      // KONDISI 1: IZIN LOKASI BELUM DIBERIKAN
                      if (!controller.isPermissionGranted.value) {
                        return Align(
                          alignment: const Alignment(0.0, -0.2),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/logo/izin_lokasi.png',
                                    width: 160,
                                    height: 160,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Izin Lokasi Diperlukan",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Izinkan akses lokasi agar kami dapat menemukan bengkel terdekat dari lokasi Anda.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () =>
                                        controller.requestLocationPermission(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
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
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: "Cari bengkel...",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                              // PERBAIKAN DI SINI
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  controller.searchBengkel(
                                    controller.searchController.text,
                                  );
                                },
                                child: SizedBox(
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
                                String emptyTitle = "";
                                String emptyDesc = "";
                                String emptyImage =
                                    ""; // Kosongkan default-nya terlebih dahulu

                                if (!controller.isGpsEnabled.value) {
                                  emptyTitle = "Lokasi Perangkat Tidak Aktif";
                                  emptyDesc =
                                      "Aktifkan layanan lokasi perangkat untuk menemukan bengkel terdekat dari lokasi Anda.";
                                  emptyImage = 'assets/logo/missing_lokasi.png';
                                } else if (controller
                                    .searchController
                                    .text
                                    .isNotEmpty) {
                                  emptyTitle = "Bengkel Tidak Ditemukan";
                                  emptyDesc =
                                      "Tidak ada bengkel yang sesuai dengan pencarian Anda.";
                                  emptyImage = 'assets/logo/bengkel_empty.png';
                                } else {
                                  emptyTitle = "Belum Ada Bengkel";
                                  emptyDesc =
                                      "Saat ini belum ada data bengkel yang tersedia di sekitar Anda.";
                                  emptyImage = 'assets/logo/bengkel_empty.png';
                                }
                                return Align(
                                  alignment: const Alignment(0.0, -0.3),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        emptyImage,
                                        height: 160,
                                        width: 160,
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        emptyTitle,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        emptyDesc,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      if (!controller.isGpsEnabled.value) ...[
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () =>
                                              controller.openGpsSettings(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF2196F3,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                          ),
                                          child: const Text(
                                            "Aktifkan GPS",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
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
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: const Color(0xFFE1E1E1),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(18),
                                            topRight: Radius.circular(18),
                                          ),
                                          child:
                                              (item['image'] == null ||
                                                  item['image']
                                                      .toString()
                                                      .trim()
                                                      .isEmpty)
                                              ? Image.asset(
                                                  'assets/image/placeholder.png',
                                                  height: 150,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.network(
                                                  item['image'],
                                                  height: 150,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Image.asset(
                                                          'assets/image/placeholder.png',
                                                          height: 150,
                                                          width:
                                                              double.infinity,
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(14),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          item['nama'] ?? '',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 3,
                                                        ),
                                                        Text(
                                                          item['jenis'] ?? '',
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .black87,
                                                                fontSize: 12,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Get.toNamed(
                                                        '/rwttambah',
                                                        arguments: {
                                                          "nama_bengkel":
                                                              item['nama'],
                                                        },
                                                      );
                                                    },
                                                    child: Container(
                                                      width: 32,
                                                      height: 32,
                                                      padding:
                                                          const EdgeInsets.all(
                                                            7,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .primaryBlue,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Image.asset(
                                                        "assets/image/bagikan.png",
                                                        width: 24,
                                                        height: 24,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Text(
                                                    item['jarak'] ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text("|"),
                                                  const SizedBox(width: 5),
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    item['rating'] ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    item['ulasan'] ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
                                width: 120,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Lokasi Perangkat Tidak Aktif",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
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
                                          color: AppColors.primaryBlue,
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
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
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
                                          0xFF2196F3,
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
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
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
