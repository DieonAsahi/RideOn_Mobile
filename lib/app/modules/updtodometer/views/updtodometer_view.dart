import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/updtodometer_controller.dart';

class UpdtodometerView extends GetView<UpdtodometerController> {
  const UpdtodometerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.pageState.value == 0) {
          return _cameraView();
        }

        return _resultView();
      }),
    );
  }

  Widget _cameraView() {
    return Obx(() {
      if (!controller.isCameraInitialized.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Stack(
        children: [
          SizedBox.expand(child: CameraPreview(controller.cameraController!)),

          IgnorePointer(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),

          Center(
            child: Container(
              width: 280,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          Positioned(
            top: 60,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: const Icon(Icons.close, color: Colors.white, size: 32),
            ),
          ),

          const Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Posisikan odometer di dalam kotak",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  if (controller.isLoading.value) return;

                  await controller.captureAndScanOdometer();
                },
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const CircularProgressIndicator(color: Colors.white);
                  }

                  return Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 5),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _resultView() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 30),

            const Text(
              "Angka Odometer",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: TextField(
                controller: controller.odometerController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await controller.disposeCamera();
                      await controller.initCamera();

                      controller.pageState.value = 0;
                    },
                    child: const Text("Scan Ulang"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.updateOdometer,
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        );
                      }

                      return const Text("Simpan");
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
