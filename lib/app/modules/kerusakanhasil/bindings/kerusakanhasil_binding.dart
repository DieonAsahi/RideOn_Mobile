import 'package:get/get.dart';

import '../controllers/kerusakanhasil_controller.dart';

class KerusakanhasilBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KerusakanhasilController>(
      () => KerusakanhasilController(),
    );
  }
}
