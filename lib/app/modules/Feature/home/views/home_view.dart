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
        child: SingleChildScrollView(
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
                          icon: const Icon(
                            Icons.notifications,
                            color: Colors.white,
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        child: Image.asset(
                          'assets/images/motor.png',
                          fit: BoxFit.cover,
                        ),
                      ),
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

                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 700 ? 3 : 2;

                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),

                          crossAxisCount: crossAxisCount,

                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,

                          childAspectRatio: constraints.maxWidth > 700
                              ? 0.82
                              : 0.68,

                          children: [
                            FeatureCard(
                              title: 'Oli Mesin',
                              imagePath: 'assets/icons/Oli Mesin.png',
                              currentKm: 4600,
                              maxKm: 5000,
                              currentDays: 30,
                              maxDays: 60,
                              onTap: () {},
                            ),

                            FeatureCard(
                              title: 'Oli Gardan',
                              imagePath: 'assets/icons/Oli Gardan.png',
                              currentKm: 4600,
                              maxKm: 5000,
                              currentDays: 30,
                              maxDays: 60,
                              onTap: () {},
                            ),

                            FeatureCard(
                              title: 'CVT',
                              imagePath: 'assets/icons/CVT.png',
                              currentKm: 4600,
                              maxKm: 5000,
                              currentDays: 30,
                              maxDays: 60,
                              onTap: () {},
                            ),

                            FeatureCard(
                              title: 'Busi',
                              imagePath: 'assets/icons/Busi.png',
                              currentKm: 4600,
                              maxKm: 5000,
                              currentDays: 30,
                              maxDays: 60,
                              onTap: () {},
                            ),

                            FeatureCard(
                              title: 'Kampas Rem',
                              imagePath: 'assets/icons/Kampas Rem.png',
                              currentKm: 4600,
                              maxKm: 5000,
                              currentDays: 30,
                              maxDays: 60,
                              onTap: () {},
                            ),

                            FeatureCard(
                              title: 'Filter Udara',
                              imagePath: 'assets/icons/Filter Udara.png',
                              currentKm: 4600,
                              maxKm: 5000,
                              currentDays: 30,
                              maxDays: 60,
                              onTap: () {},
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
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
    if (progress < 0.5) {
      return Colors.red;
    } else if (progress < 0.8) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFA79277);

    double kmProgress = currentKm / maxKm;
    double dayProgress = currentDays / maxDays;

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
                      const Icon(Icons.speed, size: 30),
                      const SizedBox(width: 10),
                      Obx(
                        () => Text(
                          "${controller.odometer.value.toStringAsFixed(0)} km",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              ElevatedButton(
                onPressed: () {},
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
      const maxChartHeight = 150.0;
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("100", style: TextStyle(fontSize: 10)),
                        Text("80", style: TextStyle(fontSize: 10)),
                        Text("60", style: TextStyle(fontSize: 10)),
                        Text("40", style: TextStyle(fontSize: 10)),
                        Text("20", style: TextStyle(fontSize: 10)),
                        Text("0", style: TextStyle(fontSize: 10)),
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

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: isFewData ? constraints.maxWidth : totalWidth,
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
                                              width: 8,
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
                                            width: 6,
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
                                  children: List.generate(dataCount, (index) {
                                    if (isFewData) {
                                      return SizedBox(
                                        width: constraints.maxWidth / dataCount,
                                        child: Text(
                                          dates[index],
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      );
                                    } else {
                                      return SizedBox(
                                        width: itemWidth,
                                        child: Text(
                                          dates[index],
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      );
                                    }
                                  }),
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
