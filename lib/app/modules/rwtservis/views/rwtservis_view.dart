import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/rwtservis_controller.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';
import 'package:capbatu/app/widgets/skeleton_widget.dart';

class RwtservisView extends GetView<RwtservisController> {
  const RwtservisView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        onPressed: () {
          Get.toNamed('/rwttambah');
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.loadServiceHistory();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            Get.offNamed('mainscreen', arguments: 2),
                        icon: const Icon(Icons.arrow_back_ios),
                      ),
                      const Expanded(
                        child: Text(
                          "Riwayat Servis",
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

                  const SizedBox(height: 20),

                  Obx(() {
                    int selectedIndex = controller.filterOptions.indexOf(
                      controller.selectedFilter.value,
                    );
                    if (selectedIndex == -1) selectedIndex = 0;

                    final screenWidth = Get.width;
                    final screenHeight = Get.height;

                    return Center(
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: 36,
                          maxHeight: screenHeight * 0.05,
                          maxWidth: 450,
                        ),
                        width: screenWidth,
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
                    );
                  }),

                  const SizedBox(height: 20),

                  Obx(() {
                    if (controller.isLoading.value) {
                      return const RwtservisSkeleton();
                    }

                    if (controller.filteredData.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 60,
                        ),
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
                                "Belum Ada Riwayat Servis",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Riwayat servis yang telah dicatat akan ditampilkan di sini.",
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

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.filteredData.length,
                      itemBuilder: (context, index) {
                        final item = controller.filteredData[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.cardBorder,
                              width: 1.0,
                            ),
                            boxShadow: [AppColors.cardShadow],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// KIRI
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        top: 10,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['jenis'] ?? "-",
                                            style: const TextStyle(
                                              color: Color(0xFF2196F3),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            item['detail']?.toString() ?? "-",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  /// TENGAH
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 10,
                                      right: 5,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            (item['statusColor'] as Color?)
                                                ?.withOpacity(0.15) ??
                                            Colors.grey.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item['status'] ?? "-",
                                        style: TextStyle(
                                          color:
                                              item['statusColor'] ??
                                              Colors.grey,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),

                                  /// KANAN
                                  Transform.translate(
                                    offset: const Offset(10, -10),
                                    child: PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.more_vert),
                                      color: Colors.white,
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          Get.toNamed(
                                            '/rwttambah',
                                            arguments: {
                                              'isEdit': true,
                                              'data': item,
                                            },
                                          );
                                        }
                                        if (value == 'batalkan') {
                                          FocusScope.of(context).unfocus();
                                          Get.dialog(
                                            AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                              title: const Text(
                                                "Konfirmasi Pembatalan",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              content: const Text(
                                                "Apakah Anda yakin ingin membatalkan jadwal servis ini?",
                                                style: TextStyle(fontSize: 13),
                                              ),
                                              actions: [
                                                OutlinedButton(
                                                  onPressed: () => Get.back(),
                                                  child: const Text("Tidak"),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    Get.back();
                                                    await controller
                                                        .cancelServiceHistory(
                                                          item['id'],
                                                        );
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.orange,
                                                      ),
                                                  child: const Text(
                                                    "Ya, Batalkan",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                        if (value == 'hapus') {
                                          FocusScope.of(context).unfocus();
                                          Get.dialog(
                                            AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18),
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
                                                  onPressed: () => Get.back(),
                                                  child: const Text("Tidak"),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    Get.back();
                                                    await controller
                                                        .deleteServiceHistory(
                                                          item['id'],
                                                        );
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                  child: const Text(
                                                    "Hapus",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                      itemBuilder: (context) {
                                        final currentStatus =
                                            item['status']?.toString();
                                        final isScheduledOrInProcess =
                                            currentStatus == 'Dijadwalkan' ||
                                            currentStatus == 'Proses' ||
                                            currentStatus == 'Diproses';

                                        if (isScheduledOrInProcess) {
                                          return [
                                            PopupMenuItem(
                                              value: 'edit',
                                              height: 30,
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    "assets/icon/edit.png",
                                                    width: 16,
                                                    height: 16,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  const Text(
                                                    "Edit",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuDivider(height: 1),
                                            PopupMenuItem(
                                              value: 'batalkan',
                                              height: 30,
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.cancel_outlined,
                                                    size: 16,
                                                    color: Colors.orange,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  const Text(
                                                    "Batalkan",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.orange,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ];
                                        } else {
                                          return [
                                            if (currentStatus == 'Selesai') ...[
                                              PopupMenuItem(
                                                value: 'edit',
                                                height: 30,
                                                child: Row(
                                                  children: [
                                                    Image.asset(
                                                      "assets/icon/edit.png",
                                                      width: 16,
                                                      height: 16,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    const Text(
                                                      "Edit",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuDivider(height: 1),
                                            ],
                                            PopupMenuItem(
                                              value: 'hapus',
                                              height: 30,
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
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ];
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 15),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  right: 5,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(left: 28),
                                            child: Text(
                                              "TANGGAL",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Image.asset(
                                                'assets/icon/calender_grey.png',
                                                width: 20,
                                                height: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  item['tanggal'] ?? "-",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    height: 1.0,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(left: 28),
                                            child: Text(
                                              "ODOMETER",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Image.asset(
                                                'assets/icon/odometer_grey.png',
                                                width: 20,
                                                height: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  item['odometer'] ?? "-",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    height: 1.0,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 15),

                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: 28),
                                      child: Text(
                                        "BENGKEL",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Image.asset(
                                          'assets/icon/service_grey.png',
                                          width: 20,
                                          height: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            item['bengkel'] ?? "-",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                              fontSize: 14,
                                              height: 1.0,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 15),
                              Divider(color: Colors.grey.shade300),
                              const SizedBox(height: 10),

                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Total Biaya",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      item['biaya'] ?? "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
