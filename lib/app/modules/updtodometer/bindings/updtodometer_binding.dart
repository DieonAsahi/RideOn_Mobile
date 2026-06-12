import 'package:get/get.dart';

import '../controllers/updtodometer_controller.dart';

class UpdtodometerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpdtodometerController>(
      () => UpdtodometerController(),
    );
  }
}
