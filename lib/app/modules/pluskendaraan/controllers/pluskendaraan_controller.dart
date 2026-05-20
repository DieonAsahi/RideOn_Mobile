import 'package:get/get.dart';
import 'package:flutter/material.dart';

class PluskendaraanController extends GetxController {
  var step = 1.obs;
  var subStep = 0.obs;
  var kendaraanImage = ''.obs;

  var isFromLogin = false.obs;

  final odometerController = TextEditingController(text: "334488");

  final Map<String, TextEditingController> komponenControllers = {
    "Oli Mesin": TextEditingController(),
    "Oli Gardan": TextEditingController(),
    "CVT": TextEditingController(),
    "Busi": TextEditingController(),
    "Kampas Rem": TextEditingController(),
    "Filter Udara": TextEditingController(),
  };

  @override
  void onInit() {
    super.onInit();

    isFromLogin.value = Get.arguments == true;
  }

  void nextStep() {
    if (step.value < 8) {
      step.value++;
    } else {
      if (isFromLogin.value) {
        Get.offAllNamed('/mainscreen');
      } else {
        Get.back();
      }
    }
  }

  void prevStep() {
    if (step.value > 1) step.value--;
  }

  final List<String> komponen = [
    "Oli Mesin",
    "Oli Gardan",
    "CVT",
    "Busi",
    "Kampas Rem",
    "Filter Udara",
  ];

  @override
  void onClose() {
    odometerController.dispose();

    for (var c in komponenControllers.values) {
      c.dispose();
    }

    super.onClose();
  }
}
