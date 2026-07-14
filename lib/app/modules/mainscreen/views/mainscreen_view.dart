import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';

import 'package:capbatu/app/modules/Feature/edukasi/views/edukasi_view.dart';
import 'package:capbatu/app/modules/Feature/kendaraan/views/kendaraan_view.dart';
import 'package:capbatu/app/modules/Feature/profil/views/profil_view.dart';
import 'package:capbatu/app/modules/Feature/home/views/home_view.dart';
import 'package:capbatu/app/modules/Feature/service/views/service_view.dart';

import '../controllers/mainscreen_controller.dart';

class MainscreenView extends GetView<MainscreenController> {
  const MainscreenView({super.key});
  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeView(),
      const KendaraanView(),
      const ServiceView(),
      const EdukasiView(),
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
        body: Obx(
          () => IndexedStack(
            index: controller.currentIndex.value,
            children: pages,
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFDEFF4), // Warna pink pucat sesuai gambar
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ), // Opsional: jika ingin melengkung
          ),
          child: Obx(
            () => BottomNavigationBar(
              currentIndex: controller.currentIndex.value,
              onTap: controller.changePage,
              elevation: 0, // Menghilangkan bayangan agar terlihat flat
              backgroundColor: Colors.transparent, // Mengikuti warna Container
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(
                0xFF9E7761,
              ), // Warna cokelat ikon aktif
              unselectedItemColor: Colors.grey.withOpacity(0.6),
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              items: const [
                BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage('assets/icon/dashboard.png')),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage('assets/icon/kendaraan.png')),
                  label: 'Kendaraan',
                ),
                BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage('assets/icon/service.png')),
                  label: 'Servis',
                ),
                BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage('assets/icon/edukasi.png')),
                  label: 'Edukasi',
                ),
                BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage('assets/icon/profil.png')),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
