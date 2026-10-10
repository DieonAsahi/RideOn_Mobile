import 'dart:ui'; // PENTING: Wajib di-import untuk fitur ImageFilter (Blur)
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/welcome_controller.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2196F3),
      body: Center(
        // SlideTransition membungkus semuanya, sehingga asap ikut terbawa masuk
        child: SlideTransition(
          position: controller.slideAnimation,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none, // Agar asap bebas menyebar keluar batas
            children: [
              // 1. LAPISAN BELAKANG: EFEK ASAP REALISTIS (Di belakang huruf R)
              Positioned(
                left: -20, // Sedikit digeser agar lebih pas di bawah R
                bottom: 25, // Posisi vertikal di area bawah (knalpot)
                child: AnimatedBuilder(
                  animation: controller.animController,
                  builder: (context, child) {
                    return Transform.translate(
                      // Asap mengembang dan terdorong ke arah belakang saat motor melaju
                      offset: Offset(controller.animController.value * -180, 0),
                      child: Opacity(
                        opacity: controller.smokeOpacity.value,
                        child: Transform.scale(
                          scale: controller.smokeScale.value,
                          child: child,
                        ),
                      ),
                    );
                  },
                  // Membuat bentuk asap awan yang lebih realistis dengan beberapa partikel
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Partikel Asap 1: Besar, Paling Kabur, Lebih Terang (Dasar)
                      Transform.translate(
                        offset: const Offset(-5, -5), // Variasi posisi
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Container(
                            width: 70,
                            height: 40,
                            decoration: BoxDecoration(
                              // Warna abu-abu terang dengan opacity
                              color: Colors.grey[400]!.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(35),
                            ),
                          ),
                        ),
                      ),
                      // Partikel Asap 2: Sedang, Sedang Kabur, Lebih Padat (Tengah)
                      Transform.translate(
                        offset: const Offset(5, 5), // Variasi posisi
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            width: 50,
                            height: 30,
                            decoration: BoxDecoration(
                              // Warna abu-abu sedang dengan opacity
                              color: Colors.grey[500]!.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                      // Partikel Asap 3: Kecil, Sedikit Kabur, Paling Gelap (Inti)
                      Transform.translate(
                        offset: const Offset(0, 0), // Variasi posisi
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            width: 30,
                            height: 20,
                            decoration: BoxDecoration(
                              // Warna abu-abu lebih gelap dengan opacity
                              color: Colors.grey[600]!.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. LAPISAN DEPAN: LOGO MOTOR JAMPING
              AnimatedBuilder(
                animation: controller.animController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: controller.tiltAnimation.value,
                    // Kita geser titik putar (alignment) sedikit ke belakang
                    // agar jampingnya terasa berpusat di ban belakang
                    alignment: const Alignment(-0.5, 0.5),
                    child: child,
                  );
                },
                child: Image.asset("assets/logo/rideon.png", width: 250),
              ),
            ],
          ),
        ),
      ),
    );
  }
}