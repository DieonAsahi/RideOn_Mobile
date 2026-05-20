import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/pluskendaraan_controller.dart';

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

          return Padding(
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
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF006BFF)),
                ),

                if (!(controller.step.value == 7 &&
                    controller.subStep.value == 1))
                  const SizedBox(height: 50),

                Expanded(
                  child:
                      controller.step.value == 7 &&
                          controller.subStep.value == 1
                      ? _buildStepContent(controller.step.value)
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: _buildStepContent(controller.step.value),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildButtonsDynamic(),
                ),
              ],
            ),
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
      switch (controller.subStep.value) {
        case 0:
          return _step7Main();
        case 1:
          return _step7Camera();
        case 2:
          return _step7Result();
        default:
          return Container();
      }
    });
  }

  Widget _step5() {
    return Obx(() {
      if (controller.subStep.value == 0) {
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
        Center(
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

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              hint: const Text(
                "Merek",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
              isExpanded: true,
              items: [
                "Honda",
                "Yamaha",
                "Suzuki",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) {},
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
        Center(
          child: Text(
            "Masukkan model kendaraan",
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              hint: const Text(
                "Model",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
              isExpanded: true,
              items: [
                "Vario",
                "Beat",
                "Supra X",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) {},
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
        Center(
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

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              hint: const Text(
                "Tahun",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
              isExpanded: true,
              items: [
                "2026",
                "2025",
                "2024",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) {},
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
        Center(
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

          child: const TextField(
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,

            decoration: InputDecoration(
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

              ElevatedButton(
                onPressed: () {
                  controller.subStep.value = 1;
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
              ),
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
                child: Image.asset(
                  "assets/images/motor.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  controller.subStep.value = 0;
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
        Center(
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Center(
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

  Widget _step7Camera() {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
        ),

        Positioned(
          top: 40,
          left: 20,
          child: GestureDetector(
            onTap: () {
              controller.subStep.value = 0;
            },
            child: const Icon(Icons.close, color: Colors.white, size: 30),
          ),
        ),

        Center(
          child: Container(
            width: 250,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),

        const Positioned(
          bottom: 140,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              "Posisikan angka odometer sesuai kotak",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),

        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () {
                controller.subStep.value = 2;
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
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
            decoration: const InputDecoration(border: InputBorder.none),
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
        // 🔥 TOMBOL KIRI (BATAL / KEMBALI)
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

        // 🔥 SPACING (hanya kalau tombol kiri ada)
        if (!(controller.isFromLogin.value && step == 1))
          const SizedBox(width: 10),

        // 🔥 TOMBOL KANAN (LANJUT / SIMPAN)
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
    final sub = controller.subStep.value;

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
                onPressed: () {
                  controller.subStep.value = 1;
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
                onPressed: () {
                  controller.subStep.value = 1;
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
                  controller.subStep.value = 0;
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
                onPressed: controller.nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006BFF),
                ),
                child: const Text(
                  "Simpan",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return _buildButtons();
  }
}
