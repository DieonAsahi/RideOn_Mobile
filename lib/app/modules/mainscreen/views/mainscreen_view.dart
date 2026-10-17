import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';

import 'package:capbatu/app/modules/Feature/edukasi/views/edukasi_view.dart';
import 'package:capbatu/app/modules/Feature/kendaraan/views/kendaraan_view.dart';
import 'package:capbatu/app/modules/Feature/profil/views/profil_view.dart';
import 'package:capbatu/app/modules/Feature/home/views/home_view.dart';
import 'package:capbatu/app/modules/Feature/service/views/service_view.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../controllers/mainscreen_controller.dart';

class MainscreenView extends GetView<MainscreenController> {
  const MainscreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeView(),
      const KendaraanView(),
      const ServiceView(),
      // const EdukasiView(),
      const ProfilView(),
    ];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.white,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: MediaQuery.sizeOf(context).height * 0.9,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/icons/warning.png',
                        width: 90,
                        height: 90,
                      ), // Ikon peringatan[cite: 8]
                      const SizedBox(height: 20),

                      const Text(
                        "Keluar dari Akun?", // Judul disesuaikan[cite: 8]
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text(
                        "Anda perlu masuk lagi untuk memantau kondisi motormu.", // Subjudul disesuaikan[cite: 8]
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5C5C5C),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 30),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 42,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    side: const BorderSide(
                                      color: Colors.grey,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => Get.back(),
                                  child: const Text(
                                    "Batal",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Tombol Keluar[cite: 8]
                            Expanded(
                              child: SizedBox(
                                height: 42,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    backgroundColor: AppColors.red,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    // ====== LOGIKA SIGN OUT ANDA TETAP DIPERTAHANKAN ======
                                    final box = GetStorage();
                                    final serverClientId =
                                        dotenv.env['GOOGLE_SERVER_CLIENT_ID'];

                                    if (serverClientId != null) {
                                      final googleSignIn = GoogleSignIn(
                                        serverClientId: serverClientId,
                                      );
                                      try {
                                        await googleSignIn.signOut();
                                      } catch (_) {}
                                    }

                                    try {
                                      await Supabase.instance.client.auth
                                          .signOut();
                                    } catch (_) {}

                                    await box.remove("token");
                                    await box.remove("user");
                                    await box.remove("vehicle_id");

                                    Get.back();
                                    SystemNavigator.pop();
                                  },
                                  child: const Text(
                                    "Keluar",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          barrierDismissible: false,
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,

        body: Stack(
          children: [
            Positioned.fill(
              child: Obx(
                () => IndexedStack(
                  index: controller.currentIndex.value,
                  children: pages,
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Container(
                    height: 55,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double tabWidth =
                            constraints.maxWidth / controller.navItems.length;

                        return Obx(() {
                          final currentIndex = controller.currentIndex.value;

                          return Stack(
                            children: [
                              // ==========================================
                              // ANIMASI PILL HIGHLIGHT YANG DIPERBAIKI
                              // ==========================================
                              AnimatedPositioned(
                                duration: const Duration(
                                  milliseconds: 350,
                                ), // Waktu transisi
                                curve: Curves
                                    .easeOutQuart, // Animasi sliding yang lebih smooth
                                // Tambahkan margin agar bentuk pill lebih terlihat
                                left: (currentIndex * tabWidth) + 6,
                                top: 4,
                                bottom: 4,
                                width:
                                    tabWidth -
                                    12, // Kurangi width sesuai margin kiri-kanan
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              ),

                              // ==========================================
                              Row(
                                children: List.generate(
                                  controller.navItems.length,
                                  (index) {
                                    final bool isSelected =
                                        currentIndex == index;
                                    final item = controller.navItems[index];

                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () =>
                                            controller.changePage(index),
                                        behavior: HitTestBehavior.opaque,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AnimatedTheme(
                                              data: ThemeData(
                                                iconTheme: IconThemeData(
                                                  color: isSelected
                                                      ? AppColors.primaryBlue
                                                      : Colors.black,
                                                ),
                                              ),
                                              child: ImageIcon(
                                                AssetImage(
                                                  isSelected
                                                      ? item['icon']!
                                                            .replaceAll(
                                                              '.png',
                                                              '_fill.png',
                                                            )
                                                      : item['icon']!,
                                                ),
                                                size: 24,
                                                color: isSelected
                                                    ? AppColors.primaryBlue
                                                    : Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            AnimatedDefaultTextStyle(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall!
                                                  .copyWith(
                                                    fontSize: 12,
                                                    color: isSelected
                                                        ? AppColors.primaryBlue
                                                        : Colors.black,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.w400,
                                                  ),
                                              child: Text(item['label']!),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
