import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:capbatu/app/widgets/skeleton_widget.dart';
import '../controllers/service_controller.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';

class ServiceView extends GetView<ServiceController> {
  const ServiceView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 30, bottom: 24),
              child: Center(
                child: Text(
                  "Servis",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await controller.getServices(force: true);
                      },
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(minHeight: 180),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              image: const DecorationImage(
                                image: AssetImage(
                                  "assets/images/kerusakan.png",
                                ),
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    "Ketahui kerusakan yang mungkin dialami dengan menjawab beberapa pertanyaan singkat",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: controller.checkDamage,
                                      child: Text(
                                        "Cek Kerusakan",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

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
                                    width: 90,
                                    height: 90,
                                    child: Image.asset(
                                      'assets/logo/bengkel_terdekat.png',
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
                                    width: 90,
                                    height: 90,
                                    child: Image.asset(
                                      'assets/logo/riwayat_servis.png',
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
                                    width: 90,
                                    height: 90,
                                    child: Image.asset(
                                      'assets/logo/estimasi_biaya.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  title: "Estimasi Biaya",
                                  onTap: controller.goToEstimate,
                                ),
                              ),
                            ],
                          ),

                          // const SizedBox(height: 30),
                          const SizedBox(height: 24),

                          Obx(() {
                            if (controller.isLoading.value) {
                              return const ServiceSkeleton();
                            }

                            if (controller.services.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 60),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/logo/empty_rwtservice.png',
                                        width: 160,
                                        height: 160,
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        "Komponen dalam Kondisi Baik",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "Anda belum memiliki komponen yang perlu di service.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: controller.services.map((item) {
                                String badgeText;
                                Color badgeColor;

                                if (item.status == "danger" ||
                                    item.severity == "Darurat") {
                                  badgeText = "Darurat";
                                  badgeColor = AppColors.red;
                                } else if (item.status == "warning" ||
                                    item.severity == "Mendesak") {
                                  badgeText = "Mendesak";
                                  badgeColor = AppColors.orange;
                                } else {
                                  badgeText = "Segera";
                                  badgeColor = const Color(0xFFFFB800);
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _serviceCard(
                                    image: DecorationImage(
                                      image: AssetImage(
                                        "assets/icons/${item.icon}.png",
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                    title: item.name,
                                    subtitle: item.message,
                                    badge: badgeText,
                                    badgeColor: badgeColor,
                                    isScheduled: item.isScheduled,
                                    onSchedule: () =>
                                        controller.goToAddHistory(item),
                                  ),
                                );
                              }).toList(),
                            );
                          }),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
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
        border: Border.all(color: AppColors.cardBorder, width: 1.0),
        boxShadow: [AppColors.cardShadow],
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
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onSchedule,
              child: const Text(
                "Jadwalkan",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
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
