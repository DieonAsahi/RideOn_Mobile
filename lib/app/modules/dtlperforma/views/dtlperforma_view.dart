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
            final data = controller.performa;
            final dates = controller.tanggal;

            final dataCount = data.length;

            const maxChartHeight = 210.0;
            const bottomAreaHeight = 30.0;

            final isFewData = dataCount < 8;

            return SingleChildScrollView(
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
                              CircularPercentIndicator(
                                radius: 85,
                                lineWidth: 18,
                                percent: 0.89,

                                animation: true,
                                animationDuration: 1000,

                                arcType: ArcType.HALF,
                                circularStrokeCap: CircularStrokeCap.round,

                                backgroundColor: Colors.transparent,

                                arcBackgroundColor: Colors.grey.shade300,

                                progressColor: Colors.green,
                              ),

                              const Positioned(
                                top: 78,

                                child: Text(
                                  "89%",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          "Kendaraan Anda dalam kondisi baik",
                          style: TextStyle(fontSize: 12, color: Colors.black),
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

                      DropdownButton<String>(
                        value: controller.selectedFilter.value,

                        underline: const SizedBox(),

                        items: ['Minggu', 'Bulan', 'Tahun']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),

                        onChanged: (value) {
                          if (value != null) {
                            controller.changeFilter(value);
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

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
                                Text("100"),
                                Text("80"),
                                Text("60"),
                                Text("40"),
                                Text("20"),
                                Text("0"),
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
                              double itemWidth = 35;

                              double totalWidth = dataCount * itemWidth;

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,

                                child: SizedBox(
                                  width: isFewData
                                      ? constraints.maxWidth
                                      : totalWidth,

                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,

                                    children: [
                                      SizedBox(
                                        height: maxChartHeight,

                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,

                                          children: List.generate(dataCount, (
                                            index,
                                          ) {
                                            final value = data[index];

                                            final barHeight =
                                                (value / 100) * maxChartHeight;

                                            if (isFewData) {
                                              return SizedBox(
                                                width:
                                                    constraints.maxWidth /
                                                    dataCount,

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
                                                              20,
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
                                                  alignment:
                                                      Alignment.bottomCenter,

                                                  child: Container(
                                                    width: 12,

                                                    height: barHeight,

                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF006BFF,
                                                      ),

                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
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
                                          children: List.generate(dataCount, (
                                            index,
                                          ) {
                                            if (isFewData) {
                                              return SizedBox(
                                                width:
                                                    constraints.maxWidth /
                                                    dataCount,

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
            );
          }),
        ),
      ),
    );
  }
}