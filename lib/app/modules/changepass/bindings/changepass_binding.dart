import 'package:get/get.dart';

import '../controllers/changepass_controller.dart';

class ChangepassBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChangepassController>(
      () => ChangepassController(),
    );
  }
}
