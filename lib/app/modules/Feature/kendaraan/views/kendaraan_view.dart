import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kendaraan_controller.dart';

class KendaraanView extends GetView<KendaraanController> {
  const KendaraanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.getVehicles();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Center(
                          child: Text(
                            "Kendaraan",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (controller.kendaraanList.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text("Belum ada kendaraan"),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: controller.kendaraanList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final data = controller.kendaraanList[index];

                            return KendaraanCard(
                              id: data.id,
                              nama: data.nama,
                              plat: data.plat,
                              km: data.km,
                              status: data.status,
                              image: data.image,
                            );
                          },
                        );
                      }),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              right: 16,
              bottom: 96,
              child: FloatingActionButton(
                heroTag:
                    'addKendaraanFab',
                backgroundColor: const Color(0xFF006BFF),
                onPressed: () async {
                  final result = await Get.toNamed('/pluskendaraan');

                  print("RESULT = $result");

                  if (result == true) {
                    await controller.getVehicles();
                  }
                },
                child: const Icon(Icons.add, color: Colors.white),
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

  const KendaraanCard({
    super.key,
    required this.id,
    required this.nama,
    required this.plat,
    required this.km,
    required this.status,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    String iconPath;
    Color statusColor;

    if (status == "Perlu Servis") {
      iconPath = "assets/icon/danger.png";
      statusColor = Colors.red;
    } else if (status == "Perlu Perhatian") {
      iconPath = "assets/icon/warning.png";
      statusColor = Colors.orange;
    } else {
      iconPath = "assets/icon/optimal.png";
      statusColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black, width: 0.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: image.isNotEmpty
                      ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return const Icon(Icons.directions_bike, size: 50);
                          },
                        )
                      : const Icon(Icons.directions_bike, size: 50),
                ),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),

                    Text(
                      plat,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      km,
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Image.asset(iconPath, width: 16, height: 16),
                        const SizedBox(width: 5),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          Positioned(
            top: -5,
            right: -10,

            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),

              onSelected: (value) {
                if (value == 'hapus') {
                  FocusScope.of(context).unfocus();
                  final kendaraanController = Get.find<KendaraanController>();
                  final isLast = kendaraanController.kendaraanList.length <= 1;

                  // Delay dialog agar popup menu route selesai tertutup sempurna (menghindari popup dialog ikut ter-dismiss)
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
                                fontSize: 16,
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
                                fontSize: 16,
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
                  height: 25,
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/icon/hapus.png",
                        width: 16,
                        height: 16,
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
