import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';

import '../controllers/notif_controller.dart';

class NotifView extends GetView<NotifController> {
  const NotifView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Get.back();
                      } else {
                        Get.offAllNamed('/mainscreen');
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      "Notifikasi",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Top Filter Tabs (Semua & Belum dibaca)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Obx(() {
                if (!controller.isPermissionGranted.value ||
                    controller.isLoading.value) {
                  return const SizedBox.shrink();
                }

                int selectedIndex = controller.filterOptions.indexOf(
                  controller.selectedFilter.value,
                );
                if (selectedIndex == -1) selectedIndex = 0;

                final screenWidth = Get.width;
                final screenHeight = Get.height;

                return Center(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 38,
                      maxHeight: screenHeight * 0.05,
                      maxWidth: 450,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double tabWidth =
                            constraints.maxWidth /
                            controller.filterOptions.length;

                        return Stack(
                          children: [
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              left: selectedIndex * tabWidth,
                              top: 0,
                              bottom: 0,
                              width: tabWidth,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: List.generate(
                                controller.filterOptions.length,
                                (index) {
                                  final String title =
                                      controller.filterOptions[index];
                                  final bool isSelected =
                                      selectedIndex == index;

                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          controller.changeFilter(title),
                                      behavior: HitTestBehavior.opaque,
                                      child: Center(
                                        child: AnimatedDefaultTextStyle(
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: screenWidth < 360
                                                ? 12
                                                : 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey.shade600,
                                          ),
                                          child: Text(title),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 4),

            // Content List (Grouped by Hari Ini, Minggu Ini, Bulan Ini)
            Expanded(
              child: Obx(() {
                if (!controller.isPermissionGranted.value) {
                  return _buildPermissionView();
                }

                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final timeSections = controller.groupedTimeSections;

                if (timeSections.isEmpty) {
                  return _buildEmptyView();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.getNotifications(silent: true);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: timeSections.length,
                    itemBuilder: (context, sectionIndex) {
                      final section = timeSections[sectionIndex];
                      return _buildTimeSection(section);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Section Rentang Waktu (Hari Ini, Minggu Ini, Bulan Ini, Lebih Lama)
  Widget _buildTimeSection(TimeSectionGroup section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 10, left: 2),
          child: Text(
            section.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        ...section.items.map((item) => _buildNotifCard(item)),
      ],
    );
  }

  /// Desain Kartu Notifikasi Sesuai Desain Awal
  Widget _buildNotifCard(NotifModel item) {
    final isUnread = !item.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFF0F8FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread ? const Color(0xFFBAE0FD) : Colors.grey.shade300,
          width: isUnread ? 1.2 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.onNotifCardTapped(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Komponen di Sebelah Kiri
                Image.asset(
                  item.image,
                  width: 54,
                  height: 54,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/icons/service.png',
                    width: 54,
                    height: 54,
                  ),
                ),
                const SizedBox(width: 14),

                // Detail Notifikasi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris Atas: Badge Status & Waktu Relatif
                      Row(
                        children: [
                          _buildStatusBadge(item.status),
                          const Spacer(),
                          Text(
                            item.time,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Judul Komponen (Bold)
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Deskripsi Notifikasi
                      Text(
                        item.desc,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Badge Status Notifikasi (Darurat, Mendesak, Segera, Pengingat)
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case "Darurat":
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFFF3B30);
        break;
      case "Mendesak":
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFFF7A00);
        break;
      case "Segera":
        bgColor = const Color(0xFFFFFDE7);
        textColor = const Color(0xFFFFB800);
        break;
      case "Pengingat":
        bgColor = const Color(0xFFE3F2FD);
        textColor = AppColors.primaryBlue;
        break;
      default:
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFFF7A00);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    String titleText = "Belum Ada Notifikasi";
    String descText =
        "Notifikasi akan muncul di sini jika ada pembaruan terbaru.";

    if (controller.selectedFilter.value == 'Belum dibaca') {
      titleText = "Semua Notifikasi Sudah Dibaca";
      descText = "Anda belum memiliki notifikasi baru yang belum dibaca.";
    }

    return RefreshIndicator(
      onRefresh: () async {
        await controller.getNotifications(silent: true);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: const Alignment(0.0, -0.3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/logo/empty_notification.png',
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      titleText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      descText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
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

  Widget _buildPermissionView() {
    return Align(
      alignment: const Alignment(0.0, -0.2),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo/izin_notif.png',
                width: 160,
                height: 160,
              ),
              const SizedBox(height: 16),
              const Text(
                "Izin Notifikasi Diperlukan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Izinkan notifikasi agar Anda mendapatkan pengingat servis dan informasi penting lainnya.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => controller.requestPermission(),
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
                  "Izinkan Notifikasi",
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
}
