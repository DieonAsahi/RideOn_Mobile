import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/editprofil_controller.dart';

class EditprofilView extends GetView<EditprofilController> {
  const EditprofilView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
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
                      padding: const EdgeInsets.only(top: 30),
                      child: Row(
                        children: [
                          IconButton(
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
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value &&
                            controller.nameController.text.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Bagian Atas (Foto & Form Input)
                                    Column(
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
                                                      color: const Color(
                                                        0xFF2583FD,
                                                      ),
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
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Color(
                                                          0xFF2196F3,
                                                        ),
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
                                          controller: controller.nameController,
                                        ),

                                        const SizedBox(height: 18),

                                        /// EMAIL (ReadOnly / Disable)
                                        CustomTextField(
                                          title: "Email",
                                          hint: "Masukkan email",
                                          controller:
                                              controller.emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          readOnly: true,
                                        ),

                                        const SizedBox(height: 18),

                                        /// BIO (Max 60 Karakter)
                                        CustomTextField(
                                          title: "Bio",
                                          hint: "Masukkan bio",
                                          controller: controller.bioController,
                                          maxLines: 2,
                                          maxLength: 60,
                                        ),
                                      ],
                                    ),

                                    // Bagian Bawah (Tombol Simpan stay di bawah)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 32,
                                        bottom: 20,
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            FocusScope.of(context).unfocus();
                                            controller.updateProfile();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor: const Color(
                                              0xFF2196F3,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                          child: Obx(
                                            () => controller.isSaving.value
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                  )
                                                : const Text(
                                                    "Simpan",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(0.5),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Foto Profil",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.black,
                  ),
                  title: const Text(
                    "Kamera",
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    Get.back();
                    controller.pickImageFromCamera();
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.photo_outlined,
                    color: Colors.black,
                  ),
                  title: const Text(
                    "Galeri",
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    Get.back();
                    controller.pickImageFromGallery();
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    "Hapus",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Get.back();
                    controller.removeImage();
                  },
                ),
              ],
            ),
          ),
        );
      },
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
                              color: Color(0xFF2583FD),
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
                              color: Color(0xFF2583FD),
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
                            backgroundColor: const Color(0xFF2583FD),
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
  final TextEditingController controller;
  final int maxLines;
  final int? maxLength;
  final TextInputType keyboardType;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.title,
    required this.hint,
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
        Text(
          title,
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
              borderSide: const BorderSide(color: Color(0xFF2196F3)),
            ),
            counterText: maxLength != null ? null : "",
          ),
        ),
      ],
    );
  }
}
