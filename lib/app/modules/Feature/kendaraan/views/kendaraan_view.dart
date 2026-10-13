import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:capbatu/app/widgets/skeleton_widget.dart';
import '../controllers/kendaraan_controller.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';

class KendaraanView extends GetView<KendaraanController> {
  const KendaraanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.getVehicles(force: true);
                },
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Center(
                              child: Text(
                                "Kendaraan",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          Obx(() {
                            if (controller.isLoading.value) {
                              return const KendaraanSkeleton();
                            }

                            if (controller.kendaraanList.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 80),
                                child: Center(
                                  child: Text(
                                    "Belum ada kendaraan",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              itemCount: controller.kendaraanList.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final data = controller.kendaraanList[index];
                                final isActive =
                                    controller.activeVehicleId.value == data.id;

                                return KendaraanCard(
                                  id: data.id,
                                  nama: data.nama,
                                  plat: data.plat,
                                  km: data.km,
                                  status: data.status,
                                  image: data.image,
                                  lastServiceDate: data.lastServiceDate,
                                  nextServiceComponent:
                                      data.nextServiceComponent,
                                  isActive: isActive,
                                );
                              },
                            );
                          }),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // TOMBOL TAMBAH KENDARAAN (FAB)
            Positioned(
              right: 16,
              bottom: 96,
              child: SizedBox(
                width: 54,
                height: 54,
                child: FloatingActionButton(
                  heroTag: 'addKendaraanFab',
                  backgroundColor: const Color(0xFF0085FF),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onPressed: () async {
                    final result = await Get.toNamed('/pluskendaraan');
                    if (result == true) {
                      await controller.getVehicles(force: true);
                    }
                  },
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KendaraanCard extends StatelessWidget {
  final String id;
  final String nama;
  final String plat;
  final String km;
  final String status;
  final String image;
  final String lastServiceDate;
  final String nextServiceComponent;
  final bool isActive;

  const KendaraanCard({
    super.key,
    required this.id,
    required this.nama,
    required this.plat,
    required this.km,
    required this.status,
    required this.image,
    required this.lastServiceDate,
    required this.nextServiceComponent,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    Color statusTextColor;
    String statusIcon;

    if (status == "Perlu Servis") {
      statusTextColor = AppColors.red;
      statusIcon = "assets/icon/danger.png";
    } else if (status == "Perlu Perhatian") {
      statusTextColor = AppColors.orange;
      statusIcon = "assets/icon/warning.png";
    } else {
      statusTextColor = AppColors.green;
      statusIcon = "assets/icon/optimal.png";
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? AppColors.primaryBlue : AppColors.cardBorder,
          width: isActive ? 1.8 : 1.0,
        ),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Stack(
        children: [
          /// ==========================================
          /// LAYER 1: KONTEN UTAMA KARTU
          /// ==========================================
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isActive)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF5FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/icons/checklist_fill.png',
                            width: 14,
                            height: 14,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Digunakan saat ini",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0085FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 2. GAMBAR & INFO KENDARAAN
                // (Menjorok ke dalam / Indented menggunakan horizontal padding 10)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    // Mengubah menjadi sejajar tengah secara vertikal
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 95,
                        height: 95,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: image.isNotEmpty
                              ? Image.network(
                                  image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.two_wheeler,
                                    size: 45,
                                    color: Colors.grey,
                                  ),
                                )
                              : const Icon(
                                  Icons.two_wheeler,
                                  size: 45,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Text(
                                nama,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              plat,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // STATUS BADGE
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical:
                                    4, // Sedikit ditebalkan agar proporsional
                              ),
                              decoration: BoxDecoration(
                                color: statusTextColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    statusIcon,
                                    width: 14,
                                    height: 14,
                                    color: statusTextColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      fontSize:
                                          12, // Sedikit diperbesar dari sebelumnya
                                      color: statusTextColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. JARAK DIPERDEKAT DARI 12 MENJADI 8
                const SizedBox(height: 8),

                // 4. BARIS BAWAH: ODOMETER, TERAKHIR SERVIS, SERVIS MENDATANG
                // (Kembali sejajar dengan batas pinggir, tanpa padding tambahan kiri-kanan)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12, // Tinggi container bawah disesuaikan agar pas
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Odometer",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8C9199),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              km,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Terakhir Servis",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8C9199),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lastServiceDate,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Servis Mendatang",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8C9199),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              nextServiceComponent,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// ==========================================
          /// LAYER 2: TOMBOL TITIK TIGA (ABSOLUTE KANAN ATAS)
          /// ==========================================
          Positioned(
            top: 6,
            right: 6,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.more_vert, color: Colors.black87),
              onSelected: (value) {
                if (value == 'hapus') {
                  FocusScope.of(context).unfocus();
                  final kendaraanController = Get.find<KendaraanController>();
                  final isLast = kendaraanController.kendaraanList.length <= 1;

                  Future.delayed(const Duration(milliseconds: 100), () {
                    Get.dialog(
                      AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        title: const Text(
                          "Konfirmasi Hapus",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          isLast
                              ? "Ini adalah satu-satunya kendaraan Anda. Jika Anda menghapus maka Anda wajib menambahkan kendaraan baru.\n\nApakah Anda yakin ingin menghapus?"
                              : "Apakah Anda yakin ingin menghapus kendaraan ini?",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                        actions: [
                          OutlinedButton(
                            onPressed: () {
                              Get.back();
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            child: const Text(
                              "Tidak",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Get.back();
                              await kendaraanController.deleteVehicle(id);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text(
                              "Ya",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      barrierDismissible: false,
                    );
                  });
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'hapus',
                  height: 30,
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/icon/hapus.png",
                        width: 16,
                        height: 16,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.delete,
                          size: 16,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Hapus",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
