import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/kerusakanhasil_controller.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';

class KerusakanhasilView extends GetView<KerusakanhasilController> {
  const KerusakanhasilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.offNamed('/service'),
                    icon: const Icon(Icons.arrow_back_ios),
                  ),

                  const Expanded(
                    child: Text(
                      "Hasil Prediksi Kerusakan",
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

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cardBorder, width: 1.0),
                  boxShadow: [
                    AppColors.cardShadow,
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Kemungkinan besar Anda mengalami:",
                      style: TextStyle(fontSize: 14),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      controller.hasil["nama"] ?? "-",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      controller.hasil["penjelasan"] ?? "-",
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            value: (controller.hasil["confidence"] ?? 0) / 100,
                            strokeWidth: 3,
                            color: const Color(0xFF2196F3),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Text(
                          "Confidence ${controller.hasil["confidence"] ?? 0}%",
                          style: const TextStyle(fontSize: 14),
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

              Text(
                controller.hasil["solusi"] ?? "-",
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),

              const SizedBox(height: 35),

              Padding(
                padding: const EdgeInsets.only(bottom: 25),

                child: SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton(
                    onPressed: controller.jadwalkanServis,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),

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
    ),
  );
}
}
