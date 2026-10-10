import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: [
                  _buildPage(
                    context: context,
                    isLandscape: isLandscape,
                    imagePath: 'assets/logo/obp1.png',
                    title: 'Kelola Perawatan Kendaraan',
                    subtitle:
                        'Catat riwayat servis dan dapatkan pengingat perawatan kendaraan secara berkala.',
                  ),
                  _buildPage(
                    context: context,
                    isLandscape: isLandscape,
                    imagePath: 'assets/logo/obp2.png',
                    title: 'Temukan Bengkel Terdekat',
                    subtitle:
                        'Temukan lokasi bengkel terdekat untuk memenuhi kebutuhan perawatan kendaraan Anda.',
                  ),
                ],
              ),
            ),

            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.currentPage.value == 0
                          ? const Color(0xFF0085FF)
                          : const Color(0xFFBDBDBD),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.currentPage.value == 1
                          ? const Color(0xFF0085FF)
                          : const Color(0xFFBDBDBD),
                    ),
                  ),
                ],
              ),
            ),

            // Tombol Mulai (Hanya di halaman kedua, atau placeholder space jika halaman pertama)
            Obx(() {
              if (controller.currentPage.value == 1) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLandscape ? 60 : 24,
                    vertical: isLandscape ? 8 : 20,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: SizedBox(
                        width: double.infinity,
                        height: isLandscape ? 44 : 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0085FF),
                            elevation: 4,
                            shadowColor: const Color(
                              0xFF0085FF,
                            ).withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: controller.completeOnboarding,
                          child: const Text(
                            "Mulai",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return SizedBox(height: isLandscape ? 60 : 92);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required BuildContext context,
    required bool isLandscape,
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    if (isLandscape) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Center(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/logo/rideon.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: isLandscape ? 8 : 24),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Image.asset('assets/logo/rideon.png', fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            flex: 3,
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: isLandscape ? 8 : 24),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
