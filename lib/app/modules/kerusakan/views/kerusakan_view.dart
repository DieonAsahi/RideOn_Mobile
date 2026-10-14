import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/kerusakan_controller.dart';

class KerusakanView extends GetView<KerusakanController> {
  const KerusakanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          double progress = controller.step.value / 4;

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 25),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Center(
                  child: Text(
                    "Cek Kerusakan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,

                  children: [
                    Text(
                      "Langkah ${controller.step.value} dari 4",
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF2196F3)),
                ),

                const SizedBox(height: 40),

                Expanded(
                  child: SingleChildScrollView(
                    child: _buildStepContent(controller.step.value),
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.only(bottom: 20),

                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 42,

                          child: ElevatedButton(
                            onPressed: controller.prevStep,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),

                            child: Text(
                              controller.step.value == 1 ? "Batal" : "Kembali",

                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: SizedBox(
                          height: 42,

                          child: ElevatedButton(
                            onPressed: controller.nextStep,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),

                            child: Text(
                              controller.step.value == 4 ? "Periksa" : "Lanjut",

                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
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
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 1:
        return _stepMesin();

      case 2:
        return _stepKelistrikan();

      case 3:
        return _stepTransmisi();

      case 4:
        return _stepRem();

      // case 5:
      //   return _stepPenggunaan();

      default:
        return const Center(child: Text("Step berikutnya..."));
    }
  }

  Widget gejalaItem(String kode, String label) {
    return Obx(
      () => CheckboxListTile(
        value: controller.isSelected(kode),
        onChanged: (_) => controller.toggleGejala(kode),
        title: Text(label),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _stepMesin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            "Mesin & Performa",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          "Pilih sesuai keluhan yang Anda rasakan ketika berkendara",
          style: TextStyle(fontSize: 14),
        ),

        const SizedBox(height: 20),

        gejalaItem("G01", "Motor susah dihidupkan saat mesin dingin"),
        gejalaItem("G02", "Tarikan motor terasa berat / ngempos"),
        gejalaItem("G03", "Keluar asap putih tebal dari knalpot"),
        gejalaItem(
          "G04",
          "Mesin sering mati mendadak saat posisi idle/langsam",
        ),
        gejalaItem("G05", "Terdengar suara letupan (nembak) dari knalpot"),
        gejalaItem("G06", "Mesin cepat sangat panas (overheat)"),
        gejalaItem("G07", "Konsumsi bensin terasa jauh lebih boros"),
      ],
    );
  }

  Widget _stepKelistrikan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            "Kelistrikan",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          "Pilih sesuai keluhan yang Anda rasakan ketika berkendara",
          style: TextStyle(fontSize: 14),
        ),

        const SizedBox(height: 20),

        gejalaItem("G08", "Lampu utama/speedometer redup saat mesin idle"),
        gejalaItem("G09", "Klakson suaranya lemah atau mati total"),
        gejalaItem("G10", "Starter tangan tidak merespon"),
        gejalaItem("G11", "Lampu indikator mesin menyala terus"),
      ],
    );
  }

  Widget _stepTransmisi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            "Transmisi",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          "Pilih sesuai keluhan yang Anda rasakan ketika berkendara",
          style: TextStyle(fontSize: 14),
        ),

        const SizedBox(height: 20),

        gejalaItem("G12", "Motor matic bergetar hebat (gredek)"),
        gejalaItem("G13", "RPM mesin tinggi tapi laju motor lambat"),
        gejalaItem("G14", "Oper gigi terasa keras"),
        gejalaItem("G15", "Suara kasar dari CVT atau rantai"),
      ],
    );
  }

  Widget _stepRem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            "Pengereman dan Ban",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          "Pilih sesuai keluhan yang Anda rasakan ketika berkendara",
          style: TextStyle(fontSize: 14),
        ),

        const SizedBox(height: 20),

        gejalaItem("G16", "Rem terasa kurang pakem / blong"),
        gejalaItem("G17", "Terdengar suara mendecit saat mengerem"),
        gejalaItem("G18", "Stang terasa tidak stabil atau oleng"),
      ],
    );
  }

  // Widget _stepPenggunaan() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,

  //     children: [
  //       const Center(
  //         child: Text(
  //           "Riwayat Penggunaan",
  //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //         ),
  //       ),

  //       const SizedBox(height: 25),

  //       const Text(
  //         "Pilih kondisi sesuai dengan yang Anda alami",
  //         style: TextStyle(fontSize: 14),
  //       ),

  //       const SizedBox(height: 15),

  //       const Padding(
  //         padding: EdgeInsets.only(left: 16),

  //         child: Text(
  //           "Intensitas Pemakaian",
  //           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
  //         ),
  //       ),
  //       const SizedBox(height: 15),

  //       ...["Jarang dipakai", "Dipakai harian", "Rutin dipakai jarak jauh"].map(
  //         (item) => Padding(
  //           padding: const EdgeInsets.only(left: 16, bottom: 14),

  //           child: Row(
  //             children: [
  //               Icon(
  //                 Icons.radio_button_unchecked,
  //                 size: 18,
  //                 color: Colors.grey.shade600,
  //               ),

  //               const SizedBox(width: 10),

  //               Expanded(
  //                 child: Text(item, style: const TextStyle(fontSize: 14)),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),

  //       const SizedBox(height: 10),

  //       const Padding(
  //         padding: EdgeInsets.only(left: 16),
  //         child: Text(
  //           "Kondisi Jalan",
  //           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
  //         ),
  //       ),

  //       const SizedBox(height: 15),

  //       ...[
  //         "Jalan mulus",
  //         "Jalan berlubang atau rusak",
  //         "Sering melalui tanjakan dan turunan",
  //       ].map(
  //         (item) => Padding(
  //           padding: const EdgeInsets.only(left: 16, bottom: 14),

  //           child: Row(
  //             children: [
  //               Icon(
  //                 Icons.radio_button_unchecked,
  //                 size: 18,
  //                 color: Colors.grey.shade600,
  //               ),

  //               const SizedBox(width: 10),

  //               Expanded(
  //                 child: Text(item, style: const TextStyle(fontSize: 14)),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
