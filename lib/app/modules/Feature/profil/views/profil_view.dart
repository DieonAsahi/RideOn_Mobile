import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profil_controller.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // supaya aman saat keyboard muncul
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),

          child: Column(
            children: [
              const SizedBox(height: 30),

              const Center(
                child: Text(
                  "Profil",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 30),

              /// PROFILE
              CircleAvatar(
                radius: 42,
                backgroundImage: AssetImage(controller.profileImage),
              ),

              const SizedBox(height: 14),

              Text(
                controller.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                controller.bio,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 30),

              /// SECTION
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Pengaturan Akun",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 14),

              /// MENU
              ProfileMenuTile(
                icon: Icons.person_outline,
                title: "Edit Profil",
                onTap: () {
                  // tutup keyboard dulu
                  FocusScope.of(context).unfocus();

                  Get.toNamed('/editprofil');
                },
              ),

              const SizedBox(height: 10),

              ProfileMenuTile(
                icon: Icons.password_outlined,
                title: "Ganti Password",
                onTap: () {
                  FocusScope.of(context).unfocus();

                  Get.toNamed('/emailver', arguments: {'from': 'profile'});
                },
              ),

              const SizedBox(height: 10),

              ProfileMenuTile(
                icon: Icons.logout,
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
                          onPressed: () {
                            Get.offAllNamed('/login');

                            /// logout logic
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
          ),
        ),
      ),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
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
            Icon(icon, size: 22, color: isLogout ? Colors.red : Colors.black),

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