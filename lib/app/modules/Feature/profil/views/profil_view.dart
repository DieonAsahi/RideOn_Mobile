import "package:capbatu/app/widgets/skeleton_widget.dart";
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:capbatu/app/services/auth_service.dart';
import '../controllers/profil_controller.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.getProfile(force: true);
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const ProfileSkeleton();
                  }

                  return Column(
                    children: [
                      const SizedBox(height: 20),

                  const Center(
                    child: Text(
                      "Profil",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// PROFILE
                  Obx(
                    () => CircleAvatar(
                      radius: 42,
                      backgroundImage: controller.imageUrl.value.isNotEmpty
                          ? NetworkImage(controller.imageUrl.value)
                          : const AssetImage("assets/images/profile.jpg")
                                as ImageProvider,
                    ),
                  ),

                  const SizedBox(height: 14),

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
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// SECTION
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Pengaturan Akun",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// MENU
                  ProfileMenuTile(
                    icon: Image.asset(
                      'assets/icon/edit_profil.png',
                      width: 24,
                      height: 24,
                    ),
                    title: "Edit Profil",
                    onTap: () async {
                      // tutup keyboard dulu
                      FocusScope.of(context).unfocus();

                      await Get.toNamed('/editprofil');
                      controller.getProfile(force: true);
                    },
                  ),

                  const SizedBox(height: 10),

                  ProfileMenuTile(
                    icon: Image.asset(
                      'assets/icon/ganti_pass.png',
                      width: 24,
                      height: 24,
                    ),
                    title: "Ganti Password",
                    onTap: () {
                      FocusScope.of(context).unfocus();

                      Get.toNamed('/emailver', arguments: {'from': 'profile'});
                    },
                  ),

                  const SizedBox(height: 10),

                  ProfileMenuTile(
                    icon: Image.asset(
                      'assets/icon/logout.png',
                      width: 24,
                      height: 24,
                    ),
                    title: "Logout",
                    isLogout: true,
                    onTap: () {
                      FocusScope.of(context).unfocus();

                      Get.dialog(
                        AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),

                          title: const Text(
                            "Konfirmasi",
                            style: TextStyle(fontSize: 16),
                          ),

                          content: const Text(
                            "Apakah Anda yakin ingin keluar?",
                            style: TextStyle(fontSize: 13),
                          ),

                          actions: [
                            OutlinedButton(
                              onPressed: () {
                                Get.back();
                              },

                              child: const Text("Tidak"),
                            ),

                            ElevatedButton(
                              onPressed: () async {
                                Get.back();
                                await AuthService.logout();
                              },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                "Ya",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Ruang bawah agar menu logout tidak tertutup bottom navigation bar
                  const SizedBox(height: 110),
                ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  final Widget icon;
  final String title;
  final VoidCallback onTap;
  final bool isLogout;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),

      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder, width: 1.0),
          boxShadow: [
            AppColors.cardShadow,
          ],
        ),

        child: Row(
          children: [
            icon,

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isLogout ? Colors.red : Colors.black,
                ),
              ),
            ),

            if (!isLogout) const Icon(Icons.chevron_right, size: 24),
          ],
        ),
      ),
    );
  }
}
