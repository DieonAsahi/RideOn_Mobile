import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../controllers/profil_controller.dart';
import "package:capbatu/app/widgets/skeleton_widget.dart";
import 'package:capbatu/app/core/theme/app_theme.dart';
import 'package:capbatu/app/services/auth_service.dart';
import 'faq_view.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 30, bottom: 24),
              child: Center(
                child: Text(
                  "Profil",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.getProfile(force: true);
                },
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const ProfileSkeleton();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Profil (Foto, Nama, Bio)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Obx(
                                    () => Container(
                                      // Menambahkan garis pinggir (border) biru
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primary,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.grey.shade200,
                                        backgroundImage:
                                            controller.imageUrl.value.isNotEmpty
                                            ? NetworkImage(
                                                controller.imageUrl.value,
                                              )
                                            : const AssetImage(
                                                    "assets/images/profile.jpg",
                                                  )
                                                  as ImageProvider,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Obx(
                                          () => Text(
                                            controller.name.value,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Obx(
                                          () => Text(
                                            controller.bio.value,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Section: Akun Saya
                            _buildSectionTitle("Akun Saya"),
                            ProfileMenuTile(
                              title: "Edit Profil",
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                await Get.toNamed('/editprofil');
                                controller.getProfile(force: true);
                              },
                            ),
                            ProfileMenuTile(
                              title: "Ganti Password",
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                Get.toNamed(
                                  '/emailver',
                                  arguments: {'from': 'profile'},
                                );
                              },
                            ),

                            const SizedBox(height: 8),

                            // Section: Pengaturan
                            _buildSectionTitle("Pengaturan"),
                            ProfileMenuTile(
                              title: "Pengingat Servis",
                              trailing: Obx(
                                () => CustomSwitch(
                                  value: controller.isReminderEnabled.value,
                                  activeColor: AppColors.primaryBlue,
                                  width: 48,
                                  height: 24,
                                  onChanged: (value) =>
                                      controller.toggleReminder(value),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Section: Lainnya
                            _buildSectionTitle("Lainnya"),
                            ProfileMenuTile(
                              title: "FAQ",
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                Get.to(() => const FaqView());
                              },
                            ),

                            const SizedBox(height: 24),

                            // Tombol Keluar (Logout)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  _showLogoutDialog();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.red,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "Keluar",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            // Versi Aplikasi
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 24,
                                bottom: 40,
                              ),
                              child: Center(
                                child: Text(
                                  "Versi 1.0.0",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                            ),

                            // Ruang bawah agar menu tidak tertutup bottom navigation bar
                            const SizedBox(height: 50),
                          ],
                        );
                      }),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/icons/warning.png', width: 90, height: 90),
              const SizedBox(height: 20),
              const Text(
                "Keluar dari Akun?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Anda perlu masuk lagi untuk memantau kondisi motormu.",
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
                            await AuthService.logout();
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
      barrierDismissible: false,
    );
  }
}

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final double width;
  final double height;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = AppColors.primaryBlue,
    this.inactiveColor = const Color(
      0xFFE5E5EA,
    ), // Warna abu-abu terang sesuai gambar
    this.width = 46.0, // Edit panjangnya di sini
    this.height = 24.0, // Edit ketebalannya di sini
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: width,
        height: height,
        padding: const EdgeInsets.all(
          2.0,
        ), // Jarak antara tombol putih dan tepi luar
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          color: value ? activeColor : inactiveColor,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: height - 4.0, // Menjaga tombol tetap bulat sempurna
            height: height - 4.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget ProfileMenuTile
class ProfileMenuTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ProfileMenuTile({
    super.key,
    required this.title,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                trailing ??
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.black,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
