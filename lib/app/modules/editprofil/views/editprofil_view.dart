import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/editprofil_controller.dart';

class EditprofilView extends GetView<EditprofilController> {
  const EditprofilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // aman saat keyboard muncul
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),

          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 100,
            ),

            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  /// HEADER
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          Get.back();
                        },
                        icon: const Icon(Icons.arrow_back_ios),
                      ),

                      const Expanded(
                        child: Text(
                          "Edit Profil",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 40),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// FOTO PROFILE
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage(
                          'assets/images/profile.png',
                        ),
                      ),

                      Positioned(
                        bottom: 0,
                        right: 0,

                        child: Container(
                          padding: const EdgeInsets.all(6),

                          decoration: const BoxDecoration(
                            color: Color(0xFF006BFF),
                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// NAMA
                  CustomTextField(
                    title: "Nama",
                    hint: "Enter your name",
                    controller: controller.nameController,
                  ),

                  const SizedBox(height: 18),

                  /// EMAIL
                  CustomTextField(
                    title: "Email",
                    hint: "Enter your email",
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: false,
                  ),

                  const SizedBox(height: 18),

                  /// BIO
                  CustomTextField(
                    title: "Bio",
                    hint: "Enter your bio",
                    controller: controller.bioController,
                    maxLines: 3,
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();

                        Get.back();
                      },

                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF006BFF),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),

                      child: const Text(
                        "Simpan",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom > 0
                        ? 20
                        : 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboardType;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.title,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          enabled: enabled,

          decoration: InputDecoration(
            hintText: hint,

            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),

            filled: true,
            fillColor: Colors.white,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),

              borderSide: BorderSide(color: Colors.grey.shade300),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),

              borderSide: BorderSide(color: Colors.grey.shade300),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),

              borderSide: const BorderSide(color: Color(0xFF006BFF)),
            ),
          ),
        ),
      ],
    );
  }
}
