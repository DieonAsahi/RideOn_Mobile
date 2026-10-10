import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import '../controllers/petabengkel_controller.dart';

class PetabengkelView extends GetView<PetabengkelController> {
  const PetabengkelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          Obx(() {
            // 1. Izin lokasi belum diberikan
            if (!controller.isPermissionGranted.value) {
              return Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/logo/izin_lokasi.png',
                          width: 160,
                          height: 160,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Izin Lokasi Diperlukan",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Izinkan akses lokasi agar kami dapat menemukan bengkel terdekat dari lokasi Anda.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () =>
                              controller.requestLocationPermission(),
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
                            "Aktifkan Perizinan Lokasi",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // 2. GPS / Layanan lokasi mati
            if (!controller.isGpsEnabled.value) {
              return Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.gps_off_rounded,
                          size: 64,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Tidak ada akses koneksi, nyalakan maps",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "GPS / Layanan lokasi perangkat Anda sedang mati. Nyalakan lokasi untuk memuat peta bengkel.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => controller.openGpsSettings(),
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
                            "Nyalakan Lokasi",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (controller.userLocation.value == null ||
                controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return FlutterMap(
              options: MapOptions(
                initialCenter: controller.userLocation.value!,
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.bs.rideon',
                ),

                MarkerLayer(markers: controller.markers.toList()),

                MarkerLayer(
                  markers: [
                    if (controller.userLocation.value != null)
                      Marker(
                        point: controller.userLocation.value!,
                        width: 30,
                        height: 30,
                        child: Image.asset(
                          "assets/icon/lokasi_saya.png",
                          width: 30,
                          height: 30,
                        ),
                      ),
                  ],
                ),
              ],
            );
          }),

          // SEARCH
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios),
                  ),

                  Expanded(
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.searchWorkshop,

                      decoration: InputDecoration(
                        hintText: "Cari bengkel...",
                        suffixIcon: SizedBox(
                          width: 20,
                          height: 20,
                          child: Center(
                            child: Image.asset(
                              "assets/icon/search.png",
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Obx(() {
            if (!controller.showBottomSheet.value) {
              return const SizedBox();
            }

            return NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                if (notification.extent <= 0.20) {
                  controller.showBottomSheet.value = false;
                }

                return true;
              },
              child: DraggableScrollableSheet(
                initialChildSize: 0.23,
                minChildSize: 0.20,
                maxChildSize: 1.0,
                snap: true,
                snapSizes: const [0.23, 0.80, 1.0],

                builder: (context, scrollController) {
                  return Container(
                    // isi UI kamu tetap
                    decoration: const BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),

                    child: SingleChildScrollView(
                      controller: scrollController,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const SizedBox(height: 12),

                          Center(
                            child: Container(
                              width: 50,
                              height: 5,

                              decoration: BoxDecoration(
                                color: Colors.blue,

                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),

                            child: Obx(() {
                              final workshop =
                                  controller.selectedWorkshop.value;

                              if (workshop == null) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text("Pilih bengkel pada peta"),
                                  ),
                                );
                              }

                              final openingHours = workshop.openingHours;
                              final hoursList = openingHours.split('|');

                              final firstDay = hoursList.isNotEmpty
                                  ? hoursList.first.trim()
                                  : "-";

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Obx(
                                    () => Text(
                                      controller
                                              .selectedWorkshop
                                              .value
                                              ?.title ??
                                          "-",
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Obx(
                                    () => Text(
                                      controller
                                              .selectedWorkshop
                                              .value
                                              ?.category ??
                                          "-",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 18,
                                      ),

                                      const SizedBox(width: 4),

                                      Obx(
                                        () => Text(
                                          "${controller.selectedWorkshop.value?.rating ?? 0}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 4),

                                      Obx(
                                        () => Text(
                                          "(${controller.selectedWorkshop.value?.reviewCount ?? 0} Ulasan)",
                                        ),
                                      ),

                                      const Spacer(),

                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 18,
                                      ),

                                      const SizedBox(width: 4),

                                      Obx(
                                        () => Text(
                                          "${controller.selectedWorkshop.value?.distanceKm.toStringAsFixed(1) ?? '0.0'} km dari lokasi anda",
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 18),

                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Obx(
                                      () => Image.network(
                                        controller
                                                .selectedWorkshop
                                                .value
                                                ?.imageUrl ??
                                            "",
                                        height: 220,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                        "assets/icon/lokasi_bengkel.png",
                                        width: 22,
                                        height: 22,
                                      ),

                                      const SizedBox(width: 10),

                                      Expanded(
                                        child: Obx(
                                          () => Text(
                                            controller
                                                    .selectedWorkshop
                                                    .value
                                                    ?.address ??
                                                "-",
                                            style: const TextStyle(height: 1.5),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      tilePadding: EdgeInsets.zero,
                                      childrenPadding: EdgeInsets.zero,
                                      leading: Image.asset(
                                        "assets/icon/jam.png",
                                        width: 22,
                                        height: 22,
                                      ),
                                      title: Text(
                                        firstDay,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: hoursList.skip(1).map((
                                              e,
                                            ) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 4,
                                                ),
                                                child: Text(
                                                  e.trim(),
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Row(
                                    children: [
                                      Image.asset(
                                        "assets/icon/phone.png",
                                        width: 22,
                                        height: 22,
                                      ),

                                      const SizedBox(width: 10),

                                      Obx(() {
                                        final phone =
                                            controller
                                                .selectedWorkshop
                                                .value
                                                ?.phone ??
                                            '';

                                        return Text(
                                          phone.isEmpty ? '-' : phone,
                                          style: const TextStyle(fontSize: 15),
                                        );
                                      }),
                                    ],
                                  ),

                                  const SizedBox(height: 25),

                                  const Divider(),

                                  const SizedBox(height: 20),

                                  const Text(
                                    "Bengkel Lainnya",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  Obx(
                                    () => Column(
                                      children: controller.otherWorkshops.map((
                                        item,
                                      ) {
                                        return GestureDetector(
                                          onTap: () {
                                            controller.getWorkshopDetail(
                                              item.id!,
                                            );
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(18),
                                                        topRight:
                                                            Radius.circular(18),
                                                      ),
                                                  child: Image.network(
                                                    item.imageUrl,
                                                    height: 140,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),

                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.title,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 17,
                                                        ),
                                                      ),

                                                      const SizedBox(height: 4),

                                                      Text(item.category),

                                                      const SizedBox(height: 8),

                                                      Row(
                                                        children: [
                                                          Text(
                                                            "${item.distanceKm.toStringAsFixed(0)} m",
                                                          ),

                                                          const SizedBox(
                                                            width: 12,
                                                          ),

                                                          const Icon(
                                                            Icons.star,
                                                            color: Colors.amber,
                                                            size: 16,
                                                          ),

                                                          Text(
                                                            " ${item.rating} (${item.reviewCount} Ulasan)",
                                                          ),

                                                          const Spacer(),

                                                          GestureDetector(
                                                            onTap: () {
                                                              Get.toNamed(
                                                                '/rwttambah',
                                                                arguments: {
                                                                  "nama_bengkel":
                                                                      item.title,
                                                                },
                                                              );
                                                            },
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    7,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                border: Border.all(
                                                                  color: const Color(
                                                                    0xFF2196F3,
                                                                  ),
                                                                ),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Image.asset(
                                                                "assets/icon/bagikan.png",
                                                                width: 18,
                                                                height: 18,
                                                              ),
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
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
