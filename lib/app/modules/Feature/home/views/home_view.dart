import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

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
            await controller.fetchHome();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Stack(
                  children: [
                    Image.asset(
                      'assets/images/kotak.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 175,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              const Text(
                                "MotoCare",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Obx(
                                () => Text(
                                  'Halo, ${controller.namaController.value}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Image.asset(
                              'assets/icon/notif.png',
                              width: 24,
                              height: 24,
                            ),
                            onPressed: () {
                              Get.toNamed('/notif');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Transform.translate(
                  offset: const Offset(0, -60),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OdometerCard(),
                  ),
                ),

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
                      Row(
                        children: [
                          Obx(
                            () => IconButton(
                              onPressed: controller.isFirstVehicle
                                  ? null
                                  : controller.previousVehicle,
                              icon: Image.asset(
                                controller.isFirstVehicle
                                    ? "assets/icon/prev_grey.png"
                                    : "assets/icon/prev_blue.png",
                                width: 40,
                              ),
                            ),
                          ),

                          Expanded(
                            child: Container(
                              height: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Obx(
                                () => ClipRRect(
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
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Obx(
                            () => IconButton(
                              onPressed: controller.isLastVehicle
                                  ? null
                                  : controller.nextVehicle,
                              icon: Image.asset(
                                controller.isLastVehicle
                                    ? "assets/icon/next_grey.png"
                                    : "assets/icon/next_blue.png",
                                width: 40,
                              ),
                            ),
                          ),
                        ],
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
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
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
                                        : 0.68,
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
    const Color primaryColor = Color(0xFFA79277);

    double kmProgress = (currentKm / maxKm).clamp(0.0, 1.0);
    double dayProgress = (currentDays / maxDays).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 0.5),
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
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${currentKm.toInt()}/${maxKm.toInt()} km",
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: kmProgress,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade300,
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
                        "${currentDays.toInt()}/${maxDays.toInt()} hari",
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: dayProgress,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade300,
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
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 5),
          const Text(
            "Odometer",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.black, width: 0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icon/odometer.png',
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 10),
                      Obx(() {
                        if (controller.isLoadingOdometer.value) {
                          return const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }

                        return Text(
                          "${controller.odometer.value} km",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              ElevatedButton(
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
                  backgroundColor: const Color(0xFF006BFF),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Update",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PerformaSection extends GetView<HomeController> {
  const PerformaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.performa;
      final dates = controller.tanggal;

      final dataCount = data.length;
      const maxChartHeight = 210.0;
      const bottomAreaHeight = 30.0;

      final isFewData = dataCount < 8;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Performa",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed('/dtlperforma');
                },

                child: const Text(
                  "Lihat Detail",
                  style: TextStyle(color: Color(0xFF006BFF), fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: maxChartHeight + bottomAreaHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    height: maxChartHeight,
                    child: Column(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("100"),
                              Text("80"),
                              Text("60"),
                              Text("40"),
                              Text("20"),
                              Text("0"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 5),

                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    width: 1,
                    height: maxChartHeight,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 1),

                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double itemWidth = 30;
                      double totalWidth = dataCount * itemWidth;
                      double chartWidth =
                          (isFewData ? constraints.maxWidth : totalWidth) + 5;

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: chartWidth,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: maxChartHeight,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: List.generate(dataCount, (index) {
                                    final value = data[index];
                                    final barHeight =
                                        (value / 100) * maxChartHeight;

                                    if (isFewData) {
                                      return SizedBox(
                                        width: constraints.maxWidth / dataCount,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: 12,
                                              height: barHeight,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF006BFF),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return SizedBox(
                                        width: itemWidth,
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            width: 12,
                                            height: barHeight,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF006BFF),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }),
                                ),
                              ),

                              Container(
                                width: isFewData
                                    ? constraints.maxWidth
                                    : totalWidth,
                                height: 1,
                                color: Colors.grey,
                              ),

                              SizedBox(
                                height: 20,
                                child: Row(
                                  children: [
                                    ...List.generate(dataCount, (index) {
                                      if (isFewData) {
                                        return SizedBox(
                                          width:
                                              constraints.maxWidth / dataCount,
                                          child: Text(
                                            dates[index],
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                        );
                                      } else {
                                        return SizedBox(
                                          width: itemWidth,
                                          child: Text(
                                            dates[index],
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                        );
                                      }
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
