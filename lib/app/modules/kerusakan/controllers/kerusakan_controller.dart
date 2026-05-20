import 'package:get/get.dart';

class KerusakanController extends GetxController {
  var step = 1.obs;

  void nextStep() {
    if (step.value < 5) {
      step.value++;
    } else {
      Get.toNamed('/kerusakanhasil');
    }
  }

  void prevStep() {
    if (step.value > 1) {
      step.value--;
    } else {
      Get.back();
    }
  }
}
