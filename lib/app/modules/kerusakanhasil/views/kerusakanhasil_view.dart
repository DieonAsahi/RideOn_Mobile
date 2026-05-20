import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/kerusakanhasil_controller.dart';

class KerusakanhasilView extends GetView<KerusakanhasilController> {
  const KerusakanhasilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              SizedBox(height: 30),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios),
                  ),

                  const Expanded(
                    child: Text(
                      "Hasil Prediksi Kerusakan",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade300),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Kemungkinan besar Anda mengalami:",
                      style: TextStyle(fontSize: 14),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Busi Bermasalah",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Masalah pada busi mengakibatkan mesin susah dihidupkan (starter/kickstarter), tarikan motor terasa berat, konsumsi bahan bakar boros, serta muncul suara letupan pada knalpot.",
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,

                          child: CircularProgressIndicator(
                            value: 0.86,
                            strokeWidth: 3,
                            color: Color(0xFF006BFF),
                          ),
                        ),

                        const SizedBox(width: 10),

                        const Text(
                          "Confidence 86%",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Rekomendasi Tindakan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              const Text(
                "Bersihkan busi dan cek celah elektroda, atau lakukan servis sistem pembakaran dan periksa kabel busi. Jika kondisi parah, ganti busi dengan yang baru agar performa mesin kembali normal.",
                style: TextStyle(fontSize: 14, height: 1.5),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: 20),

                child: SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton(
                    onPressed: controller.jadwalkanServis,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006BFF),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),

                    child: const Text(
                      "Jadwalkan Servis",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
