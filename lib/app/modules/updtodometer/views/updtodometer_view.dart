import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Dibutuhkan untuk FilteringTextInputFormatter
import 'package:get/get.dart';
import '../controllers/updtodometer_controller.dart';

class UpdtodometerView extends GetView<UpdtodometerController> {
  const UpdtodometerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mencegah layout ketarik/rusak saat keyboard muncul di form hasil
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.pageState.value == 0) {
          return _cameraView();
        }
        return _resultView();
      }),
    );
  }

  // Widget _cameraView() {
  //   return Obx(() {
  //     if (!controller.isCameraInitialized.value) {
  //       return const Center(child: CircularProgressIndicator());
  //     }

  //     return Stack(
  //       children: [
  //         // Pratinjau kamera memenuhi seluruh area sensitif layar
  //         SizedBox.expand(child: CameraPreview(controller.cameraController!)),

  //         // Lapisan overlay transparan gelap luar kotak target
  //         IgnorePointer(
  //           child: Container(color: Colors.black.withOpacity(0.45)),
  //         ),

  Widget _cameraView() {
    return Obx(() {
      if (!controller.isCameraInitialized.value ||
          controller.cameraController == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return Stack(
        children: [
          SizedBox.expand(child: CameraPreview(controller.cameraController!)),

          // Lapisan overlay transparan gelap luar kotak target
          IgnorePointer(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),

          // Area Kotak Scan Pemindai Odometer
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 280,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: controller.isScanning.value
                          ? Colors.greenAccent
                          : Colors.white,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (controller.isScanning.value)
                        BoxShadow(
                          color: Colors.greenAccent.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Keterangan status scan computer vision
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
                            Colors.greenAccent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
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

          // Tombol Kembali dibungkus SafeArea agar posisinya pas di bawah poni/notch HP
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
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Text(
                  "Sejajarkan angka odometer tepat di dalam kotak",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: 220,
            height: 42,
            child: ElevatedButton(
              onPressed: () async {
                // Hentikan dan bersihkan kamera
                await controller.disposeCamera();

                // Masuk ke halaman result/manual input
                controller.pageState.value = 1;
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
                style: TextStyle(fontWeight: FontWeight.w500),
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
              "Hasil Deteksi Odometer",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
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
                // PENYEMPURNAAN: Memaksa input hanya menerima angka bulat murni
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                      await controller
                          .disposeCamera(); // Bersihkan instance lama
                      await controller
                          .initCamera(); // Jalankan ulang kamera baru & timernya
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
                      backgroundColor: Colors.blue,
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
    );
  }
}
