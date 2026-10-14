import "package:capbatu/app/widgets/skeleton_widget.dart";
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.getVehicles();
            await controller.fetchHome(force: true);
            await controller.fetchKomponenFilter();
            await controller.fetchDashboardArtikel();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 10,
                        left: 10,
                        top: 20,
                        bottom: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/logo/rideon_title.png',
                                height: 45,
                                fit: BoxFit.contain,
                                alignment: Alignment.centerLeft,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Obx(() {
                                  if (controller.namaController.value.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: SkeletonBox(
                                        width: 120,
                                        height: 16,
                                        borderRadius: 4,
                                      ),
                                    );
                                  }

                                  return Text(
                                    'Halo, ${controller.namaController.value}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Obx(() {
                              final count = controller.unreadNotifCount.value;

                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  IconButton(
                                    icon: Image.asset(
                                      'assets/icons/notif.png',
                                      width: 24,
                                      height: 24,
                                    ),
                                    onPressed: () async {
                                      await Get.toNamed('/notif');
                                      controller.fetchUnreadNotifications();
                                    },
                                  ),
                                  if (count > 0)
                                    Positioned(
                                      right: 6,
                                      top: 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 18,
                                          minHeight: 18,
                                        ),
                                        child: Center(
                                          child: Text(
                                            count > 99
                                                ? '99+'
                                                : count.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const OdometerCard(),
                ),

                const SizedBox(height: 30),

                // Transform.translate(
                //   offset: const Offset(0, -60),
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 20),
                //     child: OdometerCard(),
                //   ),
                // ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Obx(() {
                          if (controller.isLoading.value ||
                              controller.vehicleImage.value.isEmpty) {
                            return const HomeVehicleSkeleton();
                          }

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              controller.vehicleImage.value,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;

                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),

                      const PerformaSection(),

                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Komponen",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      Obx(() {
                        if (controller.isLoading.value) {
                          return const HomeComponentsSkeleton();
                        }

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = constraints.maxWidth > 700
                                ? 3
                                : 2;

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),

                              itemCount: controller.components.length,

                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: constraints.maxWidth > 700
                                        ? 0.82
                                        : 0.63,
                                  ),

                              itemBuilder: (context, index) {
                                final item = controller.components[index];

                                return FeatureCard(
                                  title: item.title,
                                  imagePath: item.imagePath,

                                  currentKm: item.currentKm.toDouble(),
                                  maxKm: item.maxKm.toDouble(),

                                  currentDays: item.currentDays.toDouble(),
                                  maxDays: item.maxDays.toDouble(),

                                  onTap: () {},
                                );
                              },
                            );
                          },
                        );
                      }),
                      const SizedBox(height: 100),

                      // const TopikArtikelSection(),

                      // const SizedBox(height: 30),

                      // const TrendTopikSection(),

                      // const SizedBox(height: 30),

                      // const TopikKomponenSection(),

                      // const SizedBox(height: 30),

                      // const TrendServisSection(),
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
}

class FeatureCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  final double currentKm;
  final double maxKm;
  final double currentDays;
  final double maxDays;

  const FeatureCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.onTap,
    required this.currentKm,
    required this.maxKm,
    required this.currentDays,
    required this.maxDays,
  });

  Color getProgressColor(double progress) {
    if (progress <= 0.3) {
      return Colors.red;
    } else if (progress <= 0.65) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    double kmProgress = (currentKm / maxKm).clamp(0.0, 1.0);
    double dayProgress = (currentDays / maxDays).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorder, width: 1.0),
        boxShadow: [AppColors.cardShadow],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            Flexible(
              child: Image.asset(
                imagePath,
                width: 95,
                height: 95,
                fit: BoxFit.contain,
              ),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${currentKm < 0 ? 0 : currentKm.toInt()}/${maxKm.toInt()} km",
                        style: const TextStyle(fontSize: 9),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: kmProgress,
                          minHeight: 6,
                          backgroundColor: AppColors.bar,
                          valueColor: AlwaysStoppedAnimation(
                            getProgressColor(kmProgress),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${currentDays < 0 ? 0 : currentDays.toInt()}/${maxDays.toInt()} hari",
                        style: const TextStyle(fontSize: 9),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: dayProgress,
                          minHeight: 6,
                          backgroundColor: AppColors.bar,
                          valueColor: AlwaysStoppedAnimation(
                            getProgressColor(dayProgress),
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
  }
}

class OdometerCard extends GetView<HomeController> {
  const OdometerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading =
          controller.vehicles.isEmpty || controller.isLoadingOdometer.value;

      if (isLoading) {
        return const OdometerCardSkeleton();
      }

      return Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF90CAF9), Color(0xFFEBF6FF)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: PopupMenuButton<String>(
                    offset: const Offset(0, 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    onOpened: () {
                      controller.isDropdownOpen.value = true;
                    },
                    onCanceled: () {
                      controller.isDropdownOpen.value = false;
                    },
                    onSelected: (value) {
                      controller.isDropdownOpen.value = false;
                      controller.changeVehicle(value);
                    },
                    itemBuilder: (context) {
                      return controller.vehicles.map((vehicle) {
                        final String namaMotor =
                            "${vehicle["brand"] ?? ''} ${vehicle["model"] ?? ''}"
                                .trim();

                        final String platNomor = vehicle["plate_number"] ?? '';

                        final bool isSelected =
                            vehicle["id"].toString() ==
                            controller.selectedVehicleId.value;

                        return PopupMenuItem<String>(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          value: vehicle["id"].toString(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        namaMotor.isEmpty
                                            ? "Kendaraan"
                                            : namaMotor,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      platNomor,
                                      style: const TextStyle(
                                        color: Color(
                                          0xFF9E9E9E,
                                        ), // Warna abu-abu plat
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (isSelected)
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Image.asset(
                                    'assets/icons/checklist.png',
                                    width: 18,
                                    height: 18,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Obx(() {
                            final currentVehicle = controller.vehicles
                                .firstWhere(
                                  (e) =>
                                      e["id"].toString() ==
                                      controller.selectedVehicleId.value,
                                  orElse: () => {},
                                );
                            final String namaMotor =
                                "${currentVehicle["brand"] ?? ''} ${currentVehicle["model"] ?? ''}"
                                    .trim();

                            return Text(
                              namaMotor.isEmpty ? "Pilih Kendaraan" : namaMotor,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Obx(
                          () => Image.asset(
                            controller.isDropdownOpen.value
                                ? 'assets/icons/up_home.png'
                                : 'assets/icons/down_home.png',
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  controller.vehiclePlat.value,
                  style: const TextStyle(
                    color: Color(0xFF7A7A7A),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/icons/odometer.png', width: 30, height: 30),
                const SizedBox(width: 10),
                Text(
                  "${controller.odometer.value} Km",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Get.toNamed(
                      '/updtodometer',
                      arguments: controller.vehicleId,
                    );

                    if (result == true) {
                      controller.fetchHome();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Update Odometer",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class PerformaSection extends GetView<HomeController> {
  const PerformaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const PerformaSkeleton();
      }
      final dataPerforma = controller.performa;

      final double latestScoreDouble = dataPerforma.isNotEmpty
          ? dataPerforma.last
          : 0.0;

      final int score = latestScoreDouble.round();

      final double progressValue = score / 100;

      String status;
      Color progressColor;

      if (score >= 75) {
        status = "Baik";
        progressColor = Colors.green;
      } else if (score >= 50) {
        status = "Cukup";
        progressColor = Colors.orange;
      } else if (score > 0) {
        status = "Buruk";
        progressColor = Colors.red;
      } else {
        status = "Belum ada data";
        progressColor = Colors.grey;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: progressColor, width: 1),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progressValue,
                    strokeWidth: 5,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                  Center(
                    child: Text(
                      "$score%",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Kondisi kendaraan",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 14,
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            OutlinedButton(
              onPressed: () {
                Get.toNamed('/dtlperforma');
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              child: const Text(
                "Lihat Detail",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// class PerformaSection extends GetView<HomeController> {
//   const PerformaSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final data = controller.performa;
//       final dates = controller.tanggal;

//       final dataCount = data.length;
//       const maxChartHeight = 210.0;
//       const bottomAreaHeight = 30.0;

//       final isFewData = dataCount < 8;

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 "Performa",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   Get.toNamed('/dtlperforma');
//                 },

//                 child: const Text(
//                   "Lihat Detail",
//                   style: TextStyle(color: Color(0xFF2196F3), fontSize: 12),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 15),

//           SizedBox(
//             height: maxChartHeight + bottomAreaHeight,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 20),
//                   child: SizedBox(
//                     height: maxChartHeight,
//                     child: Column(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: const [
//                               Text("100"),
//                               Text("80"),
//                               Text("60"),
//                               Text("40"),
//                               Text("20"),
//                               Text("0"),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const SizedBox(width: 5),

//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 20),
//                   child: Container(
//                     width: 1,
//                     height: maxChartHeight,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(width: 1),

//                 Expanded(
//                   child: LayoutBuilder(
//                     builder: (context, constraints) {
//                       double itemWidth = 30;
//                       double totalWidth = dataCount * itemWidth;
//                       double chartWidth =
//                           (isFewData ? constraints.maxWidth : totalWidth) + 5;

//                       return SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: SizedBox(
//                           width: chartWidth,
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               SizedBox(
//                                 height: maxChartHeight,
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: List.generate(dataCount, (index) {
//                                     final value = data[index];
//                                     final barHeight =
//                                         (value / 100) * maxChartHeight;

//                                     if (isFewData) {
//                                       return SizedBox(
//                                         width: constraints.maxWidth / dataCount,
//                                         child: Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.end,
//                                           children: [
//                                             Container(
//                                               width: 12,
//                                               height: barHeight,
//                                               decoration: BoxDecoration(
//                                                 color: const Color(0xFF2196F3),
//                                                 borderRadius:
//                                                     BorderRadius.circular(10),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     } else {
//                                       return SizedBox(
//                                         width: itemWidth,
//                                         child: Align(
//                                           alignment: Alignment.bottomCenter,
//                                           child: Container(
//                                             width: 12,
//                                             height: barHeight,
//                                             decoration: BoxDecoration(
//                                               color: const Color(0xFF2196F3),
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     }
//                                   }),
//                                 ),
//                               ),

//                               Container(
//                                 width: isFewData
//                                     ? constraints.maxWidth
//                                     : totalWidth,
//                                 height: 1,
//                                 color: Colors.grey,
//                               ),

//                               SizedBox(
//                                 height: 20,
//                                 child: Row(
//                                   children: [
//                                     ...List.generate(dataCount, (index) {
//                                       if (isFewData) {
//                                         return SizedBox(
//                                           width:
//                                               constraints.maxWidth / dataCount,
//                                           child: Text(
//                                             dates[index],
//                                             textAlign: TextAlign.center,
//                                             style: const TextStyle(
//                                               fontSize: 10,
//                                             ),
//                                           ),
//                                         );
//                                       } else {
//                                         return SizedBox(
//                                           width: itemWidth,
//                                           child: Text(
//                                             dates[index],
//                                             textAlign: TextAlign.center,
//                                             style: const TextStyle(
//                                               fontSize: 10,
//                                             ),
//                                           ),
//                                         );
//                                       }
//                                     }),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       );
//     });
//   }
// }

// class TopikArtikelSection extends GetView<HomeController> {
//   const TopikArtikelSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (controller.isLoadingArtikel.value) {
//         return const Center(child: CircularProgressIndicator());
//       }

//       final maxValue = controller.artikelTopik.isEmpty
//           ? 1
//           : controller.artikelTopik
//                 .map((e) => e.jumlah)
//                 .reduce((a, b) => a > b ? a : b);

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   "Topik Artikel Paling Banyak Dibahas",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 6),

//           Text(
//             "Update terakhir ${controller.formatLastUpdate(controller.lastUpdateArtikel.value)}",
//             style: const TextStyle(fontSize: 11, color: Colors.grey),
//           ),

//           const SizedBox(height: 20),

//           Row(
//             children: [
//               Expanded(
//                 child: DropdownButtonFormField<int>(
//                   value: controller.selectedYearArtikel.value == 0
//                       ? null
//                       : controller.selectedYearArtikel.value,
//                   isExpanded: true,
//                   dropdownColor: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   icon: const Icon(Icons.keyboard_arrow_down),
//                   hint: const Text("Pilih Tahun"),
//                   decoration: InputDecoration(
//                     labelText: "Tahun",
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Color(0xFF2196F3)),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                   ),
//                   items: controller.yearsArtikel
//                       .map(
//                         (e) => DropdownMenuItem(
//                           value: e,
//                           child: Text(e.toString()),
//                         ),
//                       )
//                       .toList(),
//                   onChanged: (value) {
//                     if (value == null) return;
//                     controller.selectYearArtikel(value);
//                   },
//                 ),
//               ),

//               const SizedBox(width: 10),

//               Expanded(
//                 child: DropdownButtonFormField<int>(
//                   value:
//                       controller.monthsArtikel.contains(
//                         controller.selectedMonthArtikel.value,
//                       )
//                       ? controller.selectedMonthArtikel.value
//                       : null,
//                   isExpanded: true,
//                   dropdownColor: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   icon: const Icon(Icons.keyboard_arrow_down),
//                   hint: const Text("Pilih Bulan"),
//                   decoration: InputDecoration(
//                     labelText: "Bulan",
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Color(0xFF2196F3)),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                   ),
//                   items: controller.monthsArtikel
//                       .map(
//                         (e) => DropdownMenuItem(
//                           value: e,
//                           child: Text(controller.namaBulan[e]),
//                         ),
//                       )
//                       .toList(),
//                   onChanged: controller.selectedYearArtikel.value == 0
//                       ? null
//                       : (value) {
//                           if (value == null) return;
//                           controller.selectMonthArtikel(value);
//                         },
//                 ),
//               ),

//               const SizedBox(width: 10),

//               Expanded(
//                 child: DropdownButtonFormField<int>(
//                   value:
//                       controller.weeksArtikel.contains(
//                         controller.selectedWeekArtikel.value,
//                       )
//                       ? controller.selectedWeekArtikel.value
//                       : null,
//                   isExpanded: true,
//                   dropdownColor: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   icon: const Icon(Icons.keyboard_arrow_down),
//                   hint: const Text("Pilih Minggu"),
//                   decoration: InputDecoration(
//                     labelText: "Minggu",
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Color(0xFF2196F3)),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                   ),
//                   items: controller.weeksArtikel
//                       .map(
//                         (e) => DropdownMenuItem(
//                           value: e,
//                           child: Text("Minggu $e"),
//                         ),
//                       )
//                       .toList(),
//                   onChanged: controller.selectedMonthArtikel.value == 0
//                       ? null
//                       : (value) {
//                           if (value == null) return;
//                           controller.selectWeekArtikel(value);
//                         },
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           if (controller.artikelTopik.isEmpty)
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(vertical: 30),
//                 child: Text(
//                   "Tidak ada data pada filter yang dipilih",
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ),
//             )
//           else
//             ...controller.artikelTopik.take(5).map((item) {
//               final progress = item.jumlah / maxValue;

//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             item.kata,
//                             style: const TextStyle(fontWeight: FontWeight.w500),
//                           ),
//                         ),
//                         Text(
//                           "${item.jumlah}",
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 6),

//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: LinearProgressIndicator(
//                         value: progress,
//                         minHeight: 7,
//                         backgroundColor: Colors.grey.shade200,
//                         valueColor: const AlwaysStoppedAnimation(
//                           Color(0xFF2196F3),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//         ],
//       );
//     });
//   }
// }

// class TrendTopikSection extends GetView<HomeController> {
//   const TrendTopikSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (controller.isLoadingTrendTopik.value) {
//         return const Center(child: CircularProgressIndicator());
//       }

//       if (controller.trendTopik.isEmpty) {
//         return const SizedBox();
//       }

//       return _TrendChartCard(
//         title: "Tren Topik Terpopuler",
//         subtitle: "Jumlah artikel edukasi tiap bulan",
//         data: controller.trendTopik
//             .map(
//               (e) => FlSpot(
//                 controller.trendTopik.indexOf(e).toDouble(),
//                 e.jumlah.toDouble(),
//               ),
//             )
//             .toList(),
//         labels: controller.trendTopik
//             .map((e) => e.label)
//             .toList(),
//         lastUpdate: controller.formatLastUpdate(
//           controller.lastUpdateTrendTopik.value,
//         ),
//       );
//     });
//   }
// }

// class TopikKomponenSection extends GetView<HomeController> {
//   const TopikKomponenSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       // print("BUILD HASH = ${controller.hashCode}");
//       // print("BUILD LENGTH = ${controller.komponenServis.length}");

//       if (controller.isLoadingKomponen.value) {
//         return const Center(child: CircularProgressIndicator());
//       }

//       // print("BUILD -> ${controller.komponenServis.length}");
//       // print("BUILD TopikKomponen");
//       // print(controller.komponenServis.length);

//       final maxValue = controller.komponenServis
//           .map((e) => e.totalServis)
//           .reduce((a, b) => a > b ? a : b);

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Expanded(
//                 child: Text(
//                   "Komponen Paling Banyak Diservis",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               const SizedBox(width: 10),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Text(
//             "Update terakhir ${controller.formatLastUpdate(controller.lastUpdateKomponen.value)}",
//             style: const TextStyle(fontSize: 11, color: Colors.grey),
//           ),

//           const SizedBox(height: 20),

//           Row(
//             children: [
//               Expanded(
//                 child: DropdownButtonFormField<int?>(
//                   value: controller.selectedYearKomponen.value == 0
//                       ? null
//                       : controller.selectedYearKomponen.value,
//                   isExpanded: true,
//                   hint: Text("Pilih Tahun"),
//                   decoration: InputDecoration(
//                     labelText: "Tahun",
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Color(0xFF2196F3)),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                   ),
//                   items: controller.yearsKomponen
//                       .map(
//                         (e) => DropdownMenuItem(
//                           value: e,
//                           child: Text(e.toString()),
//                         ),
//                       )
//                       .toList(),
//                   onChanged: (value) {
//                     if (value == null) return;
//                     controller.selectYearKomponen(value);
//                   },
//                 ),
//               ),

//               const SizedBox(width: 10),

//               Expanded(
//                 child: DropdownButtonFormField<int?>(
//                   value:
//                       controller.monthsKomponen.contains(
//                         controller.selectedMonthKomponen.value,
//                       )
//                       ? controller.selectedMonthKomponen.value
//                       : null,
//                   isExpanded: true,
//                   hint: Text("Pilih Bulan"),
//                   decoration: InputDecoration(
//                     labelText: "Bulan",
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Color(0xFF2196F3)),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                   ),
//                   items: controller.monthsKomponen
//                       .map(
//                         (e) => DropdownMenuItem(
//                           value: e,
//                           child: Text(controller.namaBulan[e]),
//                         ),
//                       )
//                       .toList(),
//                   onChanged: controller.selectedYearKomponen.value == 0
//                       ? null
//                       : (value) {
//                           if (value == null) return;
//                           controller.selectMonthKomponen(value);
//                         },
//                 ),
//               ),

//               const SizedBox(width: 10),

//               Expanded(
//                 child: DropdownButtonFormField<int?>(
//                   value:
//                       controller.weeksKomponen.contains(
//                         controller.selectedWeekKomponen.value,
//                       )
//                       ? controller.selectedWeekKomponen.value
//                       : null,
//                   isExpanded: true,
//                   hint: Text("Pilih Minggu"),
//                   decoration: InputDecoration(
//                     labelText: "Minggu",
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Color(0xFF2196F3)),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                   ),
//                   items: controller.weeksKomponen
//                       .map(
//                         (e) => DropdownMenuItem(
//                           value: e,
//                           child: Text("Minggu $e"),
//                         ),
//                       )
//                       .toList(),
//                   onChanged: controller.selectedMonthKomponen.value == 0
//                       ? null
//                       : (value) {
//                           if (value == null) return;
//                           controller.selectWeekKomponen(value);
//                         },
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           if (controller.komponenServis.isEmpty)
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(vertical: 30),
//                 child: Text(
//                   "Tidak ada data pada filter yang dipilih",
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ),
//             )
//           else
//             ...controller.komponenServis.take(5).map((item) {
//               final progress = item.totalServis / maxValue;
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             item.komponen,
//                             style: const TextStyle(fontWeight: FontWeight.w500),
//                           ),
//                         ),
//                         Text(
//                           "${item.totalServis}",
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 6),

//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: LinearProgressIndicator(
//                         value: progress,
//                         minHeight: 7,
//                         backgroundColor: Colors.grey.shade200,
//                         valueColor: const AlwaysStoppedAnimation(
//                           Color(0xFF2196F3),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//         ],
//       );
//     });
//   }
// }

// class _TrendChartCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final List<FlSpot> data;
//   final List<String> labels;
//   final String lastUpdate;

//   const _TrendChartCard({
//     required this.title,
//     required this.subtitle,
//     required this.data,
//     required this.labels,
//     required this.lastUpdate,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(top: 18),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xff1D1D1D),
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             subtitle,
//             style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
//           ),
//           const SizedBox(height: 20),

//           SizedBox(
//             height: 240,
//             child: LineChart(
//               LineChartData(
//                 borderData: FlBorderData(show: false),

//                 gridData: FlGridData(
//                   drawVerticalLine: false,
//                   horizontalInterval: 2,
//                 ),

//                 titlesData: FlTitlesData(
//                   topTitles: const AxisTitles(),
//                   rightTitles: const AxisTitles(),

//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(showTitles: true, reservedSize: 34),
//                   ),

//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       interval: 1,
//                       getTitlesWidget: (value, meta) {
//                         int i = value.toInt();

//                         if (i >= labels.length) {
//                           return const SizedBox();
//                         }

//                         return Padding(
//                           padding: const EdgeInsets.only(top: 8),
//                           child: Text(
//                             labels[i],
//                             style: const TextStyle(
//                               color: Colors.white70,
//                               fontSize: 10,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),

//                 lineBarsData: [
//                   LineChartBarData(
//                     spots: data,
//                     isCurved: true,
//                     color: Colors.blue,
//                     barWidth: 4,
//                     dotData: const FlDotData(show: true),
//                     belowBarData: BarAreaData(show: false),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),

//           Text(
//             "Last Update : $lastUpdate",
//             style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
//           ),
//         ],
//       ),
//     );
//   }
// }
