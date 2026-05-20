import 'package:get/get.dart';

import '../controllers/rwttambah_controller.dart';

class RwttambahBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RwttambahController>(
      () => RwttambahController(),
    );
  }
}
