import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:capbatu/app/services/auth_service.dart';
import '../controllers/profil_controller.dart';

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
            await controller.getProfile();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Obx(() {
              if (controller.isLoading.value) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              return Column(
                children: [
                  const SizedBox(height: 30),

                  const Center(
                    child: Text(
                      "Profil",
                      style: TextStyle(
                        fontSize: 20,
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
                      controller.getProfile();
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

                  // tambahan supaya aman di hp kecil
                  const SizedBox(height: 30),
                ],
              );
            }),
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
          borderRadius: BorderRadius.circular(14),

          border: Border.all(color: Colors.grey.shade300),
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
