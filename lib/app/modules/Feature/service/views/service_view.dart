import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/service_controller.dart';

class ServiceView extends GetView<ServiceController> {
  const ServiceView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.getServices();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    "Servis",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.services.isEmpty) {
                    return const Center(
                      child: Text("Tidak ada komponen yang perlu diservis"),
                    );
                  }

                  return Column(
                    children: controller.services.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _serviceCard(
                          image: DecorationImage(
                            image: AssetImage("assets/icons/${item.icon}.png"),
                            fit: BoxFit.contain,
                          ),
                          title: item.name,
                          subtitle: item.message,
                          badge: item.status == "danger"
                              ? "Darurat"
                              : "Mendesak",
                          badgeColor: item.status == "danger"
                              ? Colors.red
                              : Colors.orange,
                          isScheduled: item.isScheduled,
                          onSchedule: () => controller.goToAddHistory(item),
                        ),
                      );
                    }).toList(),
                  );
                }),

                const SizedBox(height: 24),

                Text(
                  "Untuk Anda",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _menuItem(
                        icon: SizedBox(
                          width: 45,
                          height: 45,
                          child: Image.asset(
                            'assets/icon/bengkel_terdekat.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        title: "Bengkel Terdekat",
                        onTap: controller.goToWorkshop,
                      ),
                    ),

                    Expanded(
                      child: _menuItem(
                        icon: SizedBox(
                          width: 45,
                          height: 45,
                          child: Image.asset(
                            'assets/icon/riwayat_servis.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        title: "Riwayat Servis",
                        onTap: controller.goToHistory,
                      ),
                    ),

                    Expanded(
                      child: _menuItem(
                        icon: SizedBox(
                          width: 45,
                          height: 45,
                          child: Image.asset(
                            'assets/icon/estimasi_biaya.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        title: "Estimasi Biaya",
                        onTap: controller.goToEstimate,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 180),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    image: const DecorationImage(
                      image: AssetImage("assets/images/kerusakan.png"),
                      fit: BoxFit.cover,
                    ),
                  ),

                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: Colors.black.withOpacity(0.45),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kendaraan bermasalah?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Ketahui kerusakan yang mungkin dialami\n"
                          "dengan menjawab beberapa pertanyaan\n"
                          "singkat.",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),

                        const SizedBox(height: 24),

                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: controller.checkDamage,
                            child: Text(
                              "Cek Kerusakan",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _serviceCard({
    required DecorationImage image,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required bool isScheduled,
    required VoidCallback onSchedule,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
            child: Container(decoration: BoxDecoration(image: image)),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 2),

                Text(subtitle, style: TextStyle(fontSize: 12)),
              ],
            ),
          ),

          const SizedBox(width: 10),

          if (!isScheduled)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005BFF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onSchedule,
              child: const Text(
                "Jadwalkan",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: Color(0xFFD8E7FF),
              shape: BoxShape.circle,
            ),
            child: Center(child: icon),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
