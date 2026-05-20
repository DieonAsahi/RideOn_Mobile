import 'package:get/get.dart';

import '../controllers/pluskendaraan_controller.dart';

class PluskendaraanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PluskendaraanController>(
      () => PluskendaraanController(),
    );
  }
}
