import 'package:get/get.dart';

import '../controllers/estimasi_controller.dart';

class EstimasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EstimasiController>(
      () => EstimasiController(),
    );
  }
}
