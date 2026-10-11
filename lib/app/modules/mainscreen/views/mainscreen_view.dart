import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text("Konfirmasi", style: TextStyle(fontSize: 16)),
            content: const Text(
              "Apakah Anda yakin ingin keluar aplikasi?",
              style: TextStyle(fontSize: 13),
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Get.back(),
                child: const Text("Tidak"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  final box = GetStorage();

                  final serverClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID'];
                  if (serverClientId != null) {
                    final googleSignIn = GoogleSignIn(
                      serverClientId: serverClientId,
                    );
                    try {
                      await googleSignIn.signOut();
                    } catch (_) {}
                  }

                  try {
                    await Supabase.instance.client.auth.signOut();
                  } catch (_) {}

                  await box.remove("token");
                  await box.remove("user");
                  await box.remove("vehicle_id");

                  Get.back();
                  SystemNavigator.pop();
                },
                child: const Text("Ya", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
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
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.fastOutSlowIn,
                                left: currentIndex * tabWidth,
                                top: 0,
                                bottom: 0,
                                width: tabWidth,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF5FF),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              ),
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
                                                      ? const Color(0xFF2196F3)
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
                                                    ? const Color(0xFF2196F3)
                                                    : Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            AnimatedDefaultTextStyle(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12,
                                                color: isSelected
                                                    ? const Color(0xFF2196F3)
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
