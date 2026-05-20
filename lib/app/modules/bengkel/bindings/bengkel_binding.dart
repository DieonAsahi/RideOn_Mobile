import 'package:get/get.dart';

import '../controllers/bengkel_controller.dart';

class BengkelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BengkelController>(
      () => BengkelController(),
    );
  }
}
