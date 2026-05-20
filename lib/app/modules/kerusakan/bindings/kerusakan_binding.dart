import 'package:get/get.dart';

import '../controllers/kerusakan_controller.dart';

class KerusakanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KerusakanController>(
      () => KerusakanController(),
    );
  }
}
