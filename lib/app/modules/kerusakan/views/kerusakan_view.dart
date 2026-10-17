import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';
import '../controllers/kerusakan_controller.dart';

class KerusakanView extends GetView<KerusakanController> {
  const KerusakanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 30, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Back Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: controller.prevStep,
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    "Cek Kerusakan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 20,
                  ), // Placeholder agar text center sempurna
                ],
              ),
              const SizedBox(height: 24),

              // Progress Bar
              Obx(
                () => Row(
                  children: List.generate(4, (index) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                        height: 4,
                        decoration: BoxDecoration(
                          color: controller.step.value > index
                              ? AppColors.primaryBlue
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 30),

              // Konten Step
              Expanded(
                child: Obx(() {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: _buildStepContent(controller.step.value),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Tombol Bawah (Berubah sesuai step terakhir)
              Obx(() {
                bool isLastStep = controller.step.value == 4;
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: isLastStep
                      ? ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Cek Kerusakan",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        )
                      : OutlinedButton(
                          onPressed: controller.nextStep,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primaryBlue,
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Lanjut",
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 1:
        return _stepKelistrikan();
      case 2:
        return _stepTransmisi();
      case 3:
        return _stepRem();
      case 4:
        return _stepRiwayat();
      default:
        return const Center(child: Text("Memuat..."));
    }
  }

  // Komponen Item Gejala (Multi-select)
  Widget _buildGejalaItem(String kode, String label) {
    return Obx(() {
      bool isSel = controller.isSelected(kode);
      return GestureDetector(
        onTap: () => controller.toggleGejala(kode),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSel ? AppColors.primaryBlue : Colors.grey.shade200,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Image.asset(
                isSel
                    ? 'assets/image/circle_fill.png'
                    : 'assets/image/circle.png',
                width: 14,
                height: 14,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSel ? Colors.black : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Komponen Item Radio (Single-select untuk Step 4)
  Widget _buildRadioItem(String value, String label, RxString groupValue) {
    return Obx(() {
      bool isSel = groupValue.value == value;
      return GestureDetector(
        onTap: () => groupValue.value = value,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSel ? AppColors.primaryBlue : Colors.grey.shade200,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Icon(
                isSel
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSel ? AppColors.primaryBlue : Colors.grey.shade400,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSel ? Colors.black : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _stepKelistrikan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Kelistrikan",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Pilih sesuai keluhan yang Anda rasakan ketika berkendara",
          style: TextStyle(fontSize: 12, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildGejalaItem("K01", "Starter tidak berfungsi"),
        _buildGejalaItem("K02", "Lampu indikator mesin terus menyala"),
        _buildGejalaItem("K03", "Lampu motor redup"),
        _buildGejalaItem("K04", "Klakson lemah"),
        _buildGejalaItem("K05", "Indikator speedometer tidak normal"),
      ],
    );
  }

  Widget _stepTransmisi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Transmisi",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Pilih sesuai keluhan yang Anda rasakan ketika berkendara",
          style: TextStyle(fontSize: 12, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildGejalaItem("T01", "RPM tinggi tapi laju lambat"),
        _buildGejalaItem("T02", "Motor menyentak saat digas"),
      ],
    );
  }

  Widget _stepRem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Pengereman & Ban",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Pilih sesuai keluhan yang Anda rasakan ketika berkendara",
          style: TextStyle(fontSize: 12, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildGejalaItem("P01", "Rem kurang pakem"),
        _buildGejalaItem("P02", "Rem berbunyi"),
        _buildGejalaItem("P03", "Motor oleng saat dikendarai"),
        _buildGejalaItem("P04", "Setang bergetar"),
      ],
    );
  }

  Widget _stepRiwayat() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Riwayat Penggunaan",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Pilih kondisi sesuai dengan yang Anda alami",
          style: TextStyle(fontSize: 12, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Intensitas Pemakaian",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 12),
        _buildRadioItem("I01", "Jarang dipakai", controller.intensitas),
        _buildRadioItem("I02", "Dipakai harian", controller.intensitas),
        _buildRadioItem(
          "I03",
          "Rutin dipakai jarak jauh",
          controller.intensitas,
        ),

        const SizedBox(height: 16),

        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Kondisi Jalan",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 12),
        _buildRadioItem("J01", "Jalan mulus", controller.kondisiJalan),
        _buildRadioItem(
          "J02",
          "Jalan berlubang atau rusak",
          controller.kondisiJalan,
        ),
        _buildRadioItem(
          "J03",
          "Sering melalui tanjakan dan turunan",
          controller.kondisiJalan,
        ),
      ],
    );
  }
}
