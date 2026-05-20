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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF006BFF),
        onPressed: () {
          Get.toNamed('/pluskendaraan');
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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

              Obx(
                () => ListView.separated(
                  shrinkWrap: true, // WAJIB
                  physics: const NeverScrollableScrollPhysics(), // WAJIB
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.kendaraanList.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = controller.kendaraanList[index];

                    return KendaraanCard(
                      nama: data.nama,
                      plat: data.plat,
                      km: data.km,
                      status: data.status,
                      image: data.image,
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class KendaraanCard extends StatelessWidget {
  final String nama;
  final String plat;
  final String km;
  final String status;
  final String image;

  const KendaraanCard({
    super.key,
    required this.nama,
    required this.plat,
    required this.km,
    required this.status,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning = status == "Perlu Servis";

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
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
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
                        Icon(
                          isWarning
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle,
                          size: 16,
                          color: isWarning ? Colors.orange : Colors.green,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            color: isWarning ? Colors.orange : Colors.green,
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

                  Get.dialog(
                    AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),

                      title: const Text(
                        "Konfirmasi",
                        style: TextStyle(fontSize: 16),
                      ),

                      content: const Text(
                        "Apakah Anda yakin ingin menghapus?",
                        style: TextStyle(fontSize: 13),
                      ),

                      actions: [
                        OutlinedButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          
                          child: const Text("Tidak"),
                        ),

                        ElevatedButton(
                          onPressed: () {
                            /// logic hapus nanti di sini

                            Get.back();
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),

                          child: const Text(
                            "Ya",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },

              itemBuilder: (context) => [
                const PopupMenuItem(value: 'hapus', child: Text("Hapus")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
