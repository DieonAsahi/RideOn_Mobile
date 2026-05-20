import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditprofilController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();

  final String name = "Asahi Hamada";
  final String bio = "Professional Rider";
  final String email = "hamadaasahi@gmail.com";

  @override
  void onInit() {
    super.onInit();

    nameController.text = name;
    bioController.text = bio;
    emailController.text = email;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
    super.onClose();
  }
}