import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Get.back();
                        } else {
                          Get.offNamed('/mainscreen');
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                  ),

                  const Text(
                    "Notifikasi",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            Obx(() {
              if (!controller.isPermissionGranted.value ||
                  controller.isLoading.value) {
                return const SizedBox.shrink();
              }

              int selectedIndex = controller.filterOptions.indexOf(
                controller.selectedFilter.value,
              );
              if (selectedIndex == -1) selectedIndex = 0;

              // Mengambil dimensi layar
              final screenWidth = Get.width;
              final screenHeight = Get.height;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 36,
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
                                  color: const Color(0xFF2583FD),
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
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
                ),
              );
            }),

            const SizedBox(height: 16),

            /// LIST
            Expanded(
              child: Obx(() {
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
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => controller.requestPermission(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
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

                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final displayList = controller.filteredNotifList;

                if (displayList.isEmpty) {
                  String titleText = "Belum Ada Notifikasi";
                  String descText =
                      "Notifikasi akan muncul di sini jika ada pembaruan terbaru.";

                  if (controller.selectedFilter == 'Belum dibaca' &&
                      controller.filterOptions.isNotEmpty) {
                    titleText = "Semua Notifikasi Sudah Dibaca";
                    descText =
                        "Anda belum memiliki notifikasi baru yang belum dibaca.";
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
                                    width: 160,
                                    height: 160,
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    titleText,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    descText,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
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

                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.getNotifications(silent: true);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: displayList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final data = displayList[index];
                      return NotifCard(data: data);
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
}

class NotifCard extends GetView<NotifController> {
  final NotifModel data;

  const NotifCard({super.key, required this.data});

  Color getStatusColor() {
    switch (data.status) {
      case "Darurat":
        return const Color(0xFFFF0000);

      case "Mendesak":
        return const Color(0xFFFF6200);

      case "Segera":
        return const Color(0xFFFFC107);

      default:
        return const Color(0xFFFFC107);
    }
  }

  Color getBorderColor() {
    if (!data.isRead) {
      return const Color(0xFF2196F3);
    }

    return Colors.grey.shade300;
  }

  Color getBackgroundColor() {
    if (!data.isRead) {
      return const Color(0xFFF0F8FF);
    }

    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => controller.markAsRead(data),
      child: Container(
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: getBackgroundColor(),

          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: getBorderColor(),
            width: 1.2, //data.isRead ? 1 : 2,
          ),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// IMAGE
            Image.asset(data.image, width: 58, height: 58, fit: BoxFit.contain),

            const SizedBox(width: 14),

            /// CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// STATUS + TIME
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),

                        decoration: BoxDecoration(
                          color: getStatusColor().withOpacity(0.15),

                          borderRadius: BorderRadius.circular(4),
                        ),

                        child: Text(
                          data.status,
                          style: TextStyle(
                            fontSize: 10,
                            color: getStatusColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const Spacer(),

                      Text(
                        data.time,
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// TITLE
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  /// DESC
                  Text(
                    data.desc,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
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
}
