import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/rwtservis_controller.dart';

class RwtservisView extends GetView<RwtservisController> {
  const RwtservisView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF006BFF),
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Obx(
                    () => Row(
                      children: [
                        _filterButton(
                          title: "Semua",
                          selected: controller.selectedFilter.value == 'Semua',
                          onTap: () => controller.changeFilter('Semua'),
                        ),
                        const SizedBox(width: 10),
                        _filterButton(
                          title: "Servis Rutin",
                          selected:
                              controller.selectedFilter.value == 'Servis Rutin',
                          onTap: () => controller.changeFilter('Servis Rutin'),
                        ),
                        const SizedBox(width: 10),
                        _filterButton(
                          title: "Perbaikan",
                          selected:
                              controller.selectedFilter.value == 'Perbaikan',
                          onTap: () => controller.changeFilter('Perbaikan'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: Obx(
                      () => ListView.builder(
                        itemCount: controller.filteredData.length,
                        itemBuilder: (context, index) {
                          final item = controller.filteredData[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// KIRI
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 15),
                                          Text(
                                            item['jenis'],
                                            style: const TextStyle(
                                              color: Color(0xFF006BFF),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 15,
                                        right: 0,
                                      ),

                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),

                                        decoration: BoxDecoration(
                                          color: item['statusColor']
                                              .withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),

                                        child: Text(
                                          item['status'],
                                          style: TextStyle(
                                            color: item['statusColor'],
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// TITIK 3
                                    Transform.translate(
                                      offset: const Offset(10, -5),

                                      child: PopupMenuButton<String>(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.more_vert),

                                        color: Colors.white,
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),

                                        onSelected: (value) {
                                          /// EDIT
                                          if (value == 'edit') {
                                            Get.toNamed(
                                              '/rwttambah',
                                              arguments: {
                                                'isEdit': true,
                                                'data': item,
                                              },
                                            );
                                          }

                                          /// HAPUS
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
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),

                                                content: const Text(
                                                  "Apakah Anda yakin ingin menghapus?",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),

                                                actions: [
                                                  OutlinedButton(
                                                    onPressed: () {
                                                      Get.back();
                                                    },

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

                                        itemBuilder: (context) => [
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
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                Text(
                                  item['detail'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),

                                const SizedBox(height: 15),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "TANGGAL",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Image.asset(
                                                'assets/icon/calender_grey.png',
                                                width: 14,
                                                height: 14,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                item['tanggal'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 0,
                                        right: 50,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "ODOMETER",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),

                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Image.asset(
                                                'assets/icon/odometer_grey.png',
                                                width: 14,
                                                height: 14,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                item['odometer'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 15),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "BENGKEL",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/icon/service_grey.png',
                                          width: 14,
                                          height: 14,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          item['bengkel'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 15),

                                Divider(color: Colors.grey.shade300),

                                const SizedBox(height: 10),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Total Biaya",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      item['biaya'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF006BFF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}
