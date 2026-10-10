import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OnboardingController extends GetxController {
  final box = GetStorage();
  final pageController = PageController();
  final currentPage = 0.obs;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void completeOnboarding() {
    box.write("first_install", false);
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
