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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),

              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.toNamed('/mainscreen'),
                    icon: const Icon(Icons.arrow_back_ios),
                  ),

                  const Expanded(
                    child: Text(
                      "Notifikasi",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(width: 40),
                ],
              ),
            ),

            /// LIST
            Expanded(
              child: Obx(() {
                if (!controller.isPermissionGranted.value) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Perizinan Notifikasi Dinonaktifkan",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Aktifkan perizinan notifikasi untuk menerima pengingat servis dan update kendaraan Anda.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => controller.requestPermission(),
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
                              "Aktifkan Perizinan Notifikasi",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.notifList.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await controller.getNotifications();
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 250),
                        Center(child: Text("Belum ada notifikasi")),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.getNotifications();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.notifList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final data = controller.notifList[index];
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
        return const Color(0xFFFF4D4F);

      case "Mendesak":
        return const Color(0xFFFF8A00);

      case "Segera":
        return const Color(0xFFFFC107);

      default:
        return const Color(0xFFFFC107);
    }
  }

  Color getBorderColor() {
    if (!data.isRead) {
      return const Color(0xFF2782FF);
    }

    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => controller.markAsRead(data),
      child: Container(
        padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

          border: Border.all(
          color: getBorderColor(),
          width: data.isRead ? 1 : 2,
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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const Spacer(),

                    Text(
                      data.time,
                      style: TextStyle(
                        fontSize: 10,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                /// DESC
                Text(
                  data.desc,
                  style: const TextStyle(fontSize: 13, height: 1.4),
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
