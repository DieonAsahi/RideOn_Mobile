import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/notif_controller.dart';

class NotifView extends GetView<NotifController> {
  const NotifView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

            // Top Filter Tabs (Semua & Belum di Baca)
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
                                  color: const Color(0xFF2583FD),
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
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
                );
              }),
            ),

            const SizedBox(height: 8),

            // Content List
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

  /// Header Rentang Waktu ("Hari Ini", "Minggu Ini", "Lebih Lama")
  Widget _buildTimeSection(TimeSectionGroup section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header Box (Sesuai Desain: rounded white container dengan judul tebal warna biru)
        Container(
          margin: const EdgeInsets.only(top: 14, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            section.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0052CC), // Bold deep blue seperti di screenshot
            ),
          ),
        ),

        // List Kendaraan di dalam rentang waktu ini
        ...section.vehicleGroups.map((vehicleGroup) {
          return _buildVehicleGroup(vehicleGroup);
        }),
      ],
    );
  }

  /// Kelompok Notifikasi per Kendaraan (dengan expand/collapse Up & Down)
  Widget _buildVehicleGroup(VehicleNotifGroup vehicleGroup) {
    return Obx(() {
      final isExpanded = controller.isVehicleExpanded(vehicleGroup.vehicleId);

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Group Header (Up/Down toggleable)
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () =>
                  controller.toggleVehicleExpanded(vehicleGroup.vehicleId),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2583FD).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.two_wheeler_rounded,
                        color: Color(0xFF2583FD),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicleGroup.vehicleName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            vehicleGroup.vehiclePlate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge jumlah notifikasi
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        "${vehicleGroup.totalCount} notifikasi",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tombol chevron up / down
                    Image.asset(
                      isExpanded
                          ? 'assets/icons/up.png'
                          : 'assets/icons/down.png',
                      width: 16,
                      height: 16,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade700,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content jika di-expand
            if (isExpanded) ...[
              const Divider(height: 1, thickness: 0.8),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // 1. TIPE: PENGINGAT JADWAL SERVIS (H-1)
                    // Dipisahkan tersendiri & tidak digabung
                    // ==========================================
                    if (vehicleGroup.scheduleReminders.isNotEmpty) ...[
                      _buildTypeHeader(
                        icon: Icons.event_available_rounded,
                        title: "Pengingat Jadwal Servis (H-1)",
                        color: const Color(0xFF0066FF),
                        bgColor: const Color(0xFFE8F1FD),
                      ),
                      const SizedBox(height: 8),
                      ...vehicleGroup.scheduleReminders.map(
                        (item) => _buildScheduleReminderCard(item),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ==========================================
                    // 2. TIPE: PERINGATAN CEK/TAMBAH SERVIS HARIAN
                    // Dipisahkan tersendiri & tidak digabung
                    // ==========================================
                    if (vehicleGroup.dailyWarnings.isNotEmpty) ...[
                      _buildTypeHeader(
                        icon: Icons.warning_amber_rounded,
                        title: "Peringatan Cek Servis Harian",
                        color: const Color(0xFFFA541C),
                        bgColor: const Color(0xFFFFF2E8),
                      ),
                      const SizedBox(height: 8),
                      ...vehicleGroup.dailyWarnings.map(
                        (item) => _buildDailyWarningCard(item),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  /// Header pembeda tipe notifikasi
  Widget _buildTypeHeader({
    required IconData icon,
    required String title,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Card untuk "Pengingat Jadwal Servis (H-1)"
  Widget _buildScheduleReminderCard(NotifModel data) {
    final isUnread = !data.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFF0F8FF) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnread ? const Color(0xFF2583FD) : Colors.grey.shade300,
          width: isUnread ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => controller.markAsRead(data),
        borderRadius: BorderRadius.circular(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Pengingat Servis
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icons/service.png',
                  width: 28,
                  height: 28,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFF2583FD),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Konten
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2583FD).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "Jadwal Servis (H-1)",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2583FD),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        data.time,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.desc,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: Colors.grey.shade700,
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

  /// Card untuk "Peringatan Cek/Tambah Servis Harian" (Disertai tombol "Jadwalkan Servis")
  Widget _buildDailyWarningCard(NotifModel data) {
    final isUnread = !data.isRead;

    Color getStatusColor() {
      switch (data.status) {
        case "Darurat":
          return const Color(0xFFFF0000);
        case "Mendesak":
          return const Color(0xFFFF6200);
        case "Segera":
          return const Color(0xFFFFC107);
        default:
          return const Color(0xFFFF6200);
      }
    }

    final statusColor = getStatusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFFFF9F5) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnread ? statusColor : Colors.grey.shade300,
          width: isUnread ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Komponen
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Image.asset(
                    data.image,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.build_rounded,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Detail
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            data.status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          data.time,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.desc,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Tombol Aksi "Jadwalkan Servis"
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => controller.onJadwalkanServis(data),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2583FD),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(
                Icons.calendar_month_rounded,
                size: 15,
                color: Colors.white,
              ),
              label: const Text(
                "Jadwalkan Servis",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    String titleText = "Belum Ada Notifikasi";
    String descText =
        "Notifikasi akan muncul di sini jika ada pembaruan terbaru.";

    if (controller.selectedFilter.value == 'Belum di Baca') {
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
                      style: const TextStyle(
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
}
