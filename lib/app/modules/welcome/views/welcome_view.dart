import 'dart:ui'; // PENTING: Wajib di-import untuk fitur ImageFilter (Blur)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';

import '../controllers/welcome_controller.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 50,
              right: -30,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Center(
              child: SlideTransition(
                position: controller.slideAnimation,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: -10,
                      bottom: 25,
                      child: AnimatedBuilder(
                        animation: controller.animController,
                        builder: (context, child) {
                          return Transform.translate(
                            // Asap tertinggal di belakang saat motor melaju
                            offset: Offset(
                              controller.animController.value * -160,
                              0,
                            ),
                            child: Opacity(
                              opacity: controller.smokeOpacity.value,
                              child: Transform.scale(
                                scale: controller.smokeScale.value,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.translate(
                              offset: const Offset(-45, -10),
                              child: Transform.rotate(
                                angle: -0.2,
                                child: ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                    sigmaX: 25,
                                    sigmaY: 15,
                                  ),
                                  child: Container(
                                    width: 130,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(-15, 5),
                              child: Transform.rotate(
                                angle: 0.1,
                                child: ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                    sigmaX: 15,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    width: 80,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100.withOpacity(
                                        0.25,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(5, 0),
                              child: ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX: 8,
                                  sigmaY: 6,
                                ),
                                child: Container(
                                  width: 40,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300.withOpacity(
                                      0.35,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    AnimatedBuilder(
                      animation: controller.animController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: controller.tiltAnimation.value,
                          alignment: const Alignment(-0.5, 0.5),
                          child: child,
                        );
                      },
                      child: Image.asset(
                        "assets/logo/rideon.png",
                        width:
                            MediaQuery.of(context).size.width *
                            (isLandscape ? 0.5 : 0.8),
                        errorBuilder: (context, error, stackTrace) =>
                            const Text(
                              "RideOn",
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
