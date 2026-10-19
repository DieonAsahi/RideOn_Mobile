import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';
import '../controllers/updtodometer_controller.dart';
import '../../../widgets/form_label_with_tooltip.dart';

class UpdtodometerView extends GetView<UpdtodometerController> {
  const UpdtodometerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.pageState.value == 0) {
          return _cameraView(context);
        }
        return _resultView();
      }),
    );
  }

  Widget _cameraView(BuildContext context) {
    return Obx(() {
      final cam = controller.cameraController;
      if (!controller.isCameraInitialized.value ||
          cam == null ||
          !cam.value.isInitialized) {
        return Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      }

      return Stack(
        children: [
          SizedBox.expand(child: CameraPreview(cam)),

          IgnorePointer(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: (MediaQuery.sizeOf(context).width * 0.75)
                      .clamp(180.0, 280.0)
                      .toDouble(),
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: controller.isScanning.value
                          ? AppColors.green
                          : Colors.white,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (controller.isScanning.value)
                        BoxShadow(
                          color: AppColors.green.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.green,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Memindai odometer otomatis...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 40,
            left: 20,
            child: SafeArea(
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: const Icon(Icons.close, color: Colors.white, size: 32),
              ),
            ),
          ),

          Positioned(
            bottom: MediaQuery.of(context).orientation == Orientation.landscape
                ? 24
                : 100,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Sejajarkan angka odometer tepat di dalam kotak",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: 220,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.isManualOdometer.value = true;
                      controller.pageState.value = 1;
                      controller.disposeCamera();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Masukan Angka Odometer",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _resultView() {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 32).clamp(0, double.infinity),
            ),
            child: Column(
              children: [
                const SizedBox(height: 14),
                const Text(
                  "Hasil Deteksi Odometer",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: FormLabelWithTooltip(
                    label: 'Angka Odometer',
                    message:
                        'Masukkan hanya angka kilometer saat ini, tanpa titik atau huruf.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: TextField(
                    controller: controller.odometerController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Ubah angka jika ada kekeliruan",
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          controller.pageState.value = 0;
                          await controller.disposeCamera();
                          await controller.initCamera();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text("Scan Ulang"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
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
                          return const Text(
                            "Simpan",
                            style: TextStyle(color: Colors.white),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
