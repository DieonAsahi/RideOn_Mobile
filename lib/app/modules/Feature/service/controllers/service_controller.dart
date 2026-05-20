import 'package:get/get.dart';

class ServiceController extends GetxController {
  void goToWorkshop() {
    Get.toNamed('/bengkel');
  }

  void goToHistory() {
    Get.toNamed('/rwtservis');
  }

  void goToEstimate() {
    Get.toNamed('/estimasi');
  }

  void checkDamage() {
    Get.toNamed('/kerusakan');
  }

  void goToAddHistory() {
    Get.toNamed('/rwttambah', arguments: {'jadwalkan': true});
  }
}
