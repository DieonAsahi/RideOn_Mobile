import 'package:get/get.dart';

import '../controllers/kendaraan_controller.dart';

class KendaraanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KendaraanController>(
      () => KendaraanController(),
    );
  }
}
