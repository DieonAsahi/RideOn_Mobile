import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../controllers/dtlperforma_controller.dart';

class DtlperformaView extends GetView<DtlperformaController> {
  const DtlperformaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Obx(() {
            final dates = controller.tanggal;
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return RefreshIndicator(
              onRefresh: () async {
                await controller.fetchPerformanceHistory();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back_ios),
                        ),

                        const Expanded(
                          child: Text(
                            "Detail Performa",
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

                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 180,
                            width: 220,

                            child: Stack(
                              alignment: Alignment.center,

                              children: [
                                Obx(
                                  () => CircularPercentIndicator(
                                    radius: 85,
                                    lineWidth: 18,
                                    percent:
                                        controller.averagePerformance / 100,
                                    animation: true,
                                    animationDuration: 1000,
                                    arcType: ArcType.HALF,
                                    circularStrokeCap: CircularStrokeCap.round,
                                    backgroundColor: Colors.transparent,
                                    arcBackgroundColor: Colors.grey.shade300,
                                    progressColor: Colors.green,
                                  ),
                                ),

                                Obx(
                                  () => Positioned(
                                    top: 78,
                                    child: Text(
                                      controller.performanceText,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 5),

                          Obx(
                            () => Text(
                              controller.performanceStatus,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          "Performa",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        PopupMenuButton<String>(
                          icon: Image.asset(
                            "assets/icon/filters.png",
                            width: 24,
                            height: 24,
                          ),
                          offset: const Offset(0, 40),
                          elevation: 4,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),

                          onSelected: (value) {
                            controller.changeFilter(value);
                          },

                          itemBuilder: (context) => [
                            PopupMenuItem<String>(
                              value: 'Minggu',
                              height: 35,
                              child: Text(
                                'Minggu',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      controller.selectedFilter.value ==
                                          'Minggu'
                                      ? Colors.blue
                                      : Colors.black,
                                  fontWeight:
                                      controller.selectedFilter.value ==
                                          'Minggu'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            const PopupMenuDivider(height: 1),
                            PopupMenuItem<String>(
                              value: 'Bulan',
                              height: 35,
                              child: Text(
                                'Bulan',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      controller.selectedFilter.value == 'Bulan'
                                      ? Colors.blue
                                      : Colors.black,
                                  fontWeight:
                                      controller.selectedFilter.value == 'Bulan'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            const PopupMenuDivider(height: 1),
                            PopupMenuItem<String>(
                              value: 'Tahun',
                              height: 35,
                              child: Text(
                                'Tahun',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      controller.selectedFilter.value == 'Tahun'
                                      ? Colors.blue
                                      : Colors.black,
                                  fontWeight:
                                      controller.selectedFilter.value == 'Tahun'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height:
                          controller.maxChartHeight +
                          controller.bottomAreaHeight,

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,

                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: SizedBox(
                              height: controller.maxChartHeight,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                              height: controller.maxChartHeight,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(width: 1),

                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                double itemWidth = 35;
                                double totalWidth =
                                    controller.performa.length * itemWidth;

                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: controller.isFewData
                                        ? constraints.maxWidth
                                        : totalWidth,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,

                                      children: [
                                        SizedBox(
                                          height: controller.maxChartHeight,

                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,

                                            children: List.generate(
                                              controller.performa.length,
                                              (index) {
                                                final value =
                                                    controller.performa[index];

                                                final barHeight =
                                                    (value / 100) *
                                                    controller.maxChartHeight;

                                                if (controller.isFewData) {
                                                  return SizedBox(
                                                    width:
                                                        constraints.maxWidth /
                                                        controller
                                                            .performa
                                                            .length,

                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Container(
                                                          width: 12,
                                                          height: barHeight,
                                                          decoration: BoxDecoration(
                                                            color: const Color(
                                                              0xFF006BFF,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                } else {
                                                  return SizedBox(
                                                    width: itemWidth,
                                                    child: Align(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: Container(
                                                        width: 12,
                                                        height: barHeight,
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFF006BFF,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),

                                        Container(
                                          width: controller.isFewData
                                              ? constraints.maxWidth
                                              : totalWidth,

                                          height: 1,
                                          color: Colors.grey,
                                        ),

                                        SizedBox(
                                          height: 20,
                                          child: Row(
                                            children: [
                                              ...List.generate(
                                                controller.performa.length,
                                                (index) {
                                                  if (controller.isFewData) {
                                                    return SizedBox(
                                                      width:
                                                          constraints.maxWidth /
                                                          controller
                                                              .performa
                                                              .length,
                                                      child: Text(
                                                        dates[index],
                                                        textAlign:
                                                            TextAlign.center,
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
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
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
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
