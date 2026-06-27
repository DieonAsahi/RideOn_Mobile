import 'package:capbatu/app/modules/Feature/edukasi/views/edukasi_view.dart';
import 'package:capbatu/app/modules/Feature/kendaraan/views/kendaraan_view.dart';
import 'package:capbatu/app/modules/Feature/profil/views/profil_view.dart';
import 'package:capbatu/app/modules/Feature/home/views/home_view.dart';
import 'package:capbatu/app/modules/Feature/service/views/service_view.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

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
    return Scaffold(
      body: Obx(
        () =>
            IndexedStack(index: controller.currentIndex.value, children: pages),
      ),

      // Menggunakan Container untuk membungkus BottomNavigationBar agar bisa custom warna/radius
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
    );
  }
}
