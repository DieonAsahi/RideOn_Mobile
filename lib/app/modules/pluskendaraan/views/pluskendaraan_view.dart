import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../controllers/pluskendaraan_controller.dart';
import 'package:camera/camera.dart';

class PluskendaraanView extends GetView<PluskendaraanController> {
  const PluskendaraanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          double progress = controller.step.value / 8;
          bool isCameraFullScreen =
              controller.step.value == 7 && controller.odometerStep.value == 1;

          return Stack(
            children: [
              // KONTEN UTAMA MULTI-STEP
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    const Center(
                      child: Text(
                        "Tambah Kendaraan Baru",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Langkah ${controller.step.value} dari 8",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF006BFF),
                      ),
                    ),
                    if (!isCameraFullScreen) const SizedBox(height: 50),
                    Expanded(
                      child: isCameraFullScreen
                          ? _buildStepContent(controller.step.value)
                          : SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: _buildStepContent(controller.step.value),
                            ),
                    ),
                    if (!isCameraFullScreen)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildButtonsDynamic(),
                      ),
                  ],
                ),
              ),

              // LAYER FULL SCREEN KHUSUS PREVIEW SCAN KAMERA STEP 7
              if (isCameraFullScreen) _step7Camera(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 1:
        return _step1();
      case 2:
        return _step2();
      case 3:
        return _step3();
      case 4:
        return _step4();
      case 5:
        return _step5();
      case 6:
        return _step6();
      case 7:
        return _step7();
      case 8:
        return _step8();
      default:
        return const Center(child: Text("Step berikutnya..."));
    }
  }

  Widget _step7() {
    return Obx(() {
      switch (controller.odometerStep.value) {
        case 0:
          return _step7Main();
        case 1:
          return const SizedBox(); // Di-handle oleh layer Stack utama di atas
        case 2:
          return _step7Result();
        default:
          return Container();
      }
    });
  }

  Widget _step5() {
    return Obx(() {
      if (controller.imageStep.value == 0) {
        return _step5Upload();
      } else {
        return _step5Preview();
      }
    });
  }

  Widget _step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            "Masukkan merek kendaraan",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 35),

        PopupMenuButton<String>(
          color: Colors.white,
          offset: const Offset(0, 55),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          onSelected: (value) {
            controller.selectedBrand.value = value;
            controller.selectedModel.value = "";
          },

          itemBuilder: (context) {
            final brands = controller.vehicleData.keys.toList();

            return [
              for (int i = 0; i < brands.length; i++) ...[
                PopupMenuItem<String>(
                  value: brands[i],
                  height: 35,
                  child: Text(
                    brands[i],
                    style: TextStyle(
                      fontSize: 15,
                      color: controller.selectedBrand.value == brands[i]
                          ? Colors.blue
                          : Colors.black,
                      fontWeight: controller.selectedBrand.value == brands[i]
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),

                if (i < brands.length - 1) const PopupMenuDivider(),
              ],
            ];
          },

          child: Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => Text(
                      controller.selectedBrand.value.isEmpty
                          ? "Pilih Merek"
                          : controller.selectedBrand.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: controller.selectedBrand.value.isEmpty
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _step2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            "Masukkan model kendaraan",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),

        const SizedBox(height: 35),

        PopupMenuButton<String>(
          color: Colors.white,
          offset: const Offset(0, 55),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          onSelected: (value) {
            controller.selectedModel.value = value;
          },

          itemBuilder: (context) {
            final models =
                controller.vehicleData[controller.selectedBrand.value] ?? [];

            return [
              for (int i = 0; i < models.length; i++) ...[
                PopupMenuItem<String>(
                  value: models[i],
                  height: 35,
                  child: Text(
                    models[i],
                    style: TextStyle(
                      fontSize: 15,
                      color: controller.selectedModel.value == models[i]
                          ? Colors.blue
                          : Colors.black,
                      fontWeight: controller.selectedModel.value == models[i]
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (i < models.length - 1) const PopupMenuDivider(),
              ],
            ];
          },
          child: Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.selectedModel.value.isEmpty
                        ? "Pilih Model"
                        : controller.selectedModel.value,
                    style: TextStyle(
                      fontSize: 14,
                      color: controller.selectedModel.value.isEmpty
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _step3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            "Masukkan tahun kendaraan",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),

        const SizedBox(height: 35),

        PopupMenuButton<String>(
          color: Colors.white,
          offset: const Offset(0, 55),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          onSelected: (value) {
            controller.selectedYear.value = value;
          },

          itemBuilder: (context) {
            final years = ["2026", "2025", "2024"];

            return [
              for (int i = 0; i < years.length; i++) ...[
                PopupMenuItem<String>(
                  value: years[i],
                  height: 35,
                  child: Text(
                    years[i],
                    style: TextStyle(
                      fontSize: 15,
                      color: controller.selectedYear.value == years[i]
                          ? Colors.blue
                          : Colors.black,
                      fontWeight: controller.selectedYear.value == years[i]
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),

                if (i < years.length - 1) const PopupMenuDivider(),
              ],
            ];
          },

          child: Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.selectedYear.value.isEmpty
                        ? "Pilih Tahun"
                        : controller.selectedYear.value,
                    style: TextStyle(
                      fontSize: 14,
                      color: controller.selectedYear.value.isEmpty
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ),

                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _step4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            "Masukkan kode plat nomor kendaraan",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 35),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: TextField(
            controller: controller.platController,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              hintText: "contoh : A 1234 BC",
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _step5Upload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Center(
          child: Text(
            "Tambahkan Gambar Kendaraan",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        const SizedBox(height: 30),
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.upload_outlined,
                size: 70,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (controller.isUploading.value) {
                  return const CircularProgressIndicator();
                }
                return ElevatedButton(
                  onPressed: () {
                    Get.bottomSheet(
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text("Kamera"),
                              onTap: () {
                                Get.back();
                                controller.pickVehicleImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo),
                              title: const Text("Galeri"),
                              onTap: () {
                                Get.back();
                                controller.pickVehicleImage(
                                  ImageSource.gallery,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006BFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Unggah",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _step5Preview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Center(
          child: Text(
            "Tambahkan Gambar Kendaraan",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        const SizedBox(height: 30),
        Stack(
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: ClipRRect(
                child: controller.selectedVehicleImage != null
                    ? Image.file(
                        controller.selectedVehicleImage!,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox(),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  controller.selectedVehicleImage = null;
                  controller.vehicleImageUrl.value = '';
                  controller.imageStep.value = 0;
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.refresh, color: Color(0xFF006BFF)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _step6() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            "Estimasi pengguna harian",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          "Anda tetap dapat memperbaharui odometer secara manual untuk mendapatkan angka yang akurat.",
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.estimasiHarianController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "contoh : 15",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Text(
                "km/hari",
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _step7Main() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Center(
          child: Text(
            "Ambil gambar angka odometer",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  // DIUBAH MENJADI FULLSCREEN OVERLAY DENGAN MENGGUNAKAN INDIKATOR RADAR SCAN REALTIME
  Widget _step7Camera() {
    return Obx(() {
      if (!controller.isCameraInitialized.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Positioned.fill(
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              SizedBox.expand(
                child: CameraPreview(controller.cameraController!),
              ),
              IgnorePointer(
                child: Container(color: Colors.black.withOpacity(0.45)),
              ),
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
                    onTap: () async {
                      await controller.disposeCamera();
                      controller.odometerStep.value = 0;
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "Sejajarkan angka odometer tepat di dalam kotak hijau",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _step7Result() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            "Angka odometer",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 35),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: TextField(
            controller: controller.odometerController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Sesuaikan angka apabila tidak tepat",
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _step8() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            "Waktu terakhir ganti komponen kendaraan",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        const SizedBox(height: 30),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.komponen.length,
          itemBuilder: (context, index) {
            final item = controller.komponen[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _inputKomponen(item),
            );
          },
        ),
      ],
    );
  }

  Widget _inputKomponen(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.komponenControllers[title],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Contoh: 28",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Text(
                "hari yang lalu",
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    final step = controller.step.value;
    bool isLastStep = step == 8;

    return Row(
      children: [
        if (!(controller.isFromLogin.value && step == 1))
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  if (step == 1) {
                    Get.back();
                  } else {
                    controller.prevStep();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: step == 1 ? Colors.red : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  step == 1 ? "Batal" : "Kembali",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        if (!(controller.isFromLogin.value && step == 1))
          const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: controller.nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006BFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                isLastStep
                    ? (controller.isFromLogin.value ? "Simpan" : "Lanjut")
                    : "Lanjut",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonsDynamic() {
    final step = controller.step.value;
    final sub = controller.odometerStep.value;

    if (step == 7 && sub == 0) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: controller.prevStep,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text(
                  "Kembali",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: () async {
                  controller.isManualOdometer.value = false;
                  await controller.initCamera();
                  controller.odometerStep.value =
                      1; // Mengaktifkan kamera stream
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006BFF),
                ),
                child: const Text(
                  "Ambil Gambar",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () async {
                  controller.isManualOdometer.value = true;
                  controller.odometerStep.value = 2;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006BFF),
                ),
                child: const Text(
                  "Masukan Angka Odometer",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (step == 7 && sub == 1) {
      return const SizedBox();
    }

    if (step == 7 && sub == 2) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: () async {
                  controller.odometerStep.value = 0;
                  await controller.disposeCamera();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text(
                  "Kembali",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  controller.nextStep();
                  controller.odometerStep.value = 0;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006BFF),
                ),
                child: const Text(
                  "Lanjut",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (step == 8) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: controller.prevStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                ),
                child: const Text(
                  "Kembali",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006BFF),
                ),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
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
          ),
        ],
      );
    }

    return _buildButtons();
  }
}
