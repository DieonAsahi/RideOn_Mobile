import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/petabengkel_controller.dart';

class PetabengkelView extends GetView<PetabengkelController> {
  const PetabengkelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          // MAP
          Obx(() {
            if (controller.userLocation.value == null) {
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
                  userAgentPackageName: 'motocare.com.workshop_map',
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

          // BOTTOM SHEET
          Obx(() {
            if (!controller.showBottomSheet.value) {
              return const SizedBox();
            }

            return NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                // jika ditarik hampir habis ke bawah
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
                                    "Ringkasan Ulasan",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: List.generate(5, (index) {
                                            int star = 5 - index;

                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 8,
                                              ),

                                              child: Row(
                                                children: [
                                                  Text("$star"),

                                                  const SizedBox(width: 8),

                                                  Expanded(
                                                    child: LinearProgressIndicator(
                                                      value: star == 5
                                                          ? 0.95
                                                          : 0.05,

                                                      minHeight: 6,

                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),

                                                      backgroundColor:
                                                          Colors.grey.shade200,

                                                      valueColor:
                                                          const AlwaysStoppedAnimation(
                                                            Colors.amber,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ),
                                      ),

                                      const SizedBox(width: 20),

                                      Column(
                                        children: [
                                          Obx(
                                            () => Text(
                                              controller
                                                      .selectedWorkshop
                                                      .value
                                                      ?.rating
                                                      .toStringAsFixed(1) ??
                                                  "0.0",
                                              style: const TextStyle(
                                                fontSize: 48,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),

                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 18,
                                              ),
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 18,
                                              ),
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 18,
                                              ),
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 18,
                                              ),
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 18,
                                              ),
                                            ],
                                          ),

                                          SizedBox(height: 6),

                                          Obx(
                                            () => Text(
                                              "${controller.selectedWorkshop.value?.reviewCount ?? 0} ulasan",
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 25),

                                  _reviewItem(
                                    "“Service nya bagus, pelayanan memuaskan”",
                                  ),

                                  const SizedBox(height: 16),

                                  _reviewItem(
                                    "“Cepat tanggap solusi terbaik pas motor trouble tapi ngga ada bengkel di sekitar”",
                                  ),

                                  const SizedBox(height: 40),
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

  static Widget _reviewItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey,

          child: Icon(Icons.person, color: Colors.white, size: 18),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14, height: 1.5)),
        ),
      ],
    );
  }
}
