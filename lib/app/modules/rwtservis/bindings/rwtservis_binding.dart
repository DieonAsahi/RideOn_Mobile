import 'package:get/get.dart';

import '../controllers/rwtservis_controller.dart';

class RwtservisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RwtservisController>(
      () => RwtservisController(),
    );
  }
}
