import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';
import 'package:capbatu/app/widgets/form_label_with_tooltip.dart';

import '../controllers/editprofil_controller.dart';
import '../../../widgets/base_bottom_sheet.dart';
import '../../../widgets/skeleton_widget.dart';

class EditprofilView extends GetView<EditprofilController> {
  const EditprofilView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        FocusScope.of(context).unfocus();

        if (controller.hasChanges()) {
          _showUnsavedChangesDialog(context);
        } else {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(
                              width: 36,
                              height: 36,
                            ),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              if (controller.hasChanges()) {
                                _showUnsavedChangesDialog(context);
                              } else {
                                Get.back();
                              }
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              "Edit Profil",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 40,
                          ), // Spacer penyeimbang tombol back
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// KONTEN UTAMA (Bisa di-scroll, dengan tombol simpan stay di bawah)
                    /// KONTEN UTAMA (Bisa di-scroll)
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: controller.getProfile,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Obx(() {
                            if (controller.isLoading.value) {
                              return const EditProfileSkeleton();
                            }
                            return Column(
                              children: [
                                /// FOTO PROFILE
                                Stack(
                                  children: [
                                    Obx(
                                      () => GestureDetector(
                                        onTap: () =>
                                            _showImagePickerBottomSheet(
                                              context,
                                            ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFF2583FD),
                                              width: 2.0,
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            radius: 45,
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            backgroundImage:
                                                controller
                                                        .selectedImage
                                                        .value !=
                                                    null
                                                ? FileImage(
                                                    controller
                                                        .selectedImage
                                                        .value!,
                                                  )
                                                : (controller
                                                              .imageUrl
                                                              .value
                                                              .isNotEmpty
                                                          ? NetworkImage(
                                                              controller
                                                                  .imageUrl
                                                                  .value,
                                                            )
                                                          : const AssetImage(
                                                              'assets/images/profile.jpg',
                                                            ))
                                                      as ImageProvider,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () =>
                                            _showImagePickerBottomSheet(
                                              context,
                                            ),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF2196F3),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_outlined,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 30),

                                /// NAMA
                                CustomTextField(
                                  title: "Nama",
                                  hint: "Masukkan nama",
                                  helperText:
                                      'Masukkan nama yang ingin ditampilkan pada profil Anda.',
                                  controller: controller.nameController,
                                ),

                                const SizedBox(height: 18),

                                /// EMAIL (ReadOnly / Disable)
                                CustomTextField(
                                  title: "Email",
                                  hint: "Masukkan email",
                                  helperText:
                                      'Alamat email akun tidak dapat diubah.',
                                  controller: controller.emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  readOnly: true,
                                ),

                                const SizedBox(height: 18),

                                /// BIO (Max 60 Karakter)
                                CustomTextField(
                                  title: "Bio",
                                  hint: "Masukkan bio",
                                  helperText:
                                      'Bio bersifat opsional dan maksimal 60 karakter.',
                                  controller: controller.bioController,
                                  maxLines: 2,
                                  maxLength: 60,
                                ),

                                const SizedBox(height: 20),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),

                    // ================= TOMBOL SIMPAN (STICKY DI BAWAH) =================
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6, 12, 6, 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: controller.isSaving.value
                                ? null
                                : () {
                                    FocusScope.of(context).unfocus();
                                    controller.updateProfile();
                                  },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFF2196F3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isSaving.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Simpan",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// BOTTOM SHEET PILIH FOTO
  void _showImagePickerBottomSheet(BuildContext context) {
    BaseBottomSheet.show(
      context: context,
      title: "Foto Profil",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Image.asset(
              'assets/image/camera.png',
              width: 24,
              height: 24,
            ),
            title: const Text("Kamera", style: TextStyle(color: Colors.black)),
            onTap: () {
              Get.back();
              controller.pickImageFromCamera();
            },
          ),

          // Divider Pembatas
          Divider(color: Colors.grey.shade300, height: 1),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Image.asset(
              'assets/image/galeri.png',
              width: 24,
              height: 24,
            ),
            title: const Text("Galeri", style: TextStyle(color: Colors.black)),
            onTap: () {
              Get.back();
              controller.pickImageFromGallery();
            },
          ),

          // Divider Pembatas
          Divider(color: Colors.grey.shade300, height: 1),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Image.asset(
              'assets/image/hapus_fill.png',
              width: 24,
              height: 24,
            ),
            title: const Text("Hapus", style: TextStyle(color: AppColors.red)),
            onTap: () {
              Get.back();
              controller.removeImage();
            },
          ),
        ],
      ),
    );
  }

  /// DIALOG PERINGATAN KELUAR (UNSAVED CHANGES)
  void _showUnsavedChangesDialog(BuildContext context) {
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
              Image.asset(
                'assets/icons/warning.png',
                width: Get.width > 400 ? 90 : Get.width * 0.22,
                height: Get.width > 400 ? 90 : Get.width * 0.22,
              ),
              const SizedBox(height: 20),
              const Text(
                "Perubahan belum disimpan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Anda akan kehilangan perubahan jika keluar sekarang.",
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
                              color: AppColors.primaryBlue,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Get.back(); // Tutup dialog
                            Get.back(); // Keluar halaman edit
                          },
                          child: const Text(
                            "Keluar",
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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
                            backgroundColor: AppColors.primaryBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Get.back(); // Tutup dialog, tetap di halaman edit
                          },
                          child: const Text(
                            "Lanjut Edit",
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

/// WIDGET CUSTOM TEXT FIELD
class CustomTextField extends StatelessWidget {
  final String title;
  final String hint;
  final String helperText;
  final TextEditingController controller;
  final int maxLines;
  final int? maxLength;
  final TextInputType keyboardType;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.title,
    required this.hint,
    required this.helperText,
    required this.controller,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormLabelWithTooltip(
          label: title,
          message: helperText,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: TextStyle(color: readOnly ? Colors.black87 : Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            errorMaxLines: 3,
            filled: true,
            fillColor: readOnly ? Colors.grey.shade50 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryBlue),
            ),
            counterText: maxLength != null ? null : "",
          ),
        ),
      ],
    );
  }
}
