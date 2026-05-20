import 'package:get/get.dart';

import '../controllers/petabengkel_controller.dart';

class PetabengkelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PetabengkelController>(
      () => PetabengkelController(),
    );
  }
}
