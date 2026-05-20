import 'package:get/get.dart';

import '../controllers/dtlperforma_controller.dart';

class DtlperformaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DtlperformaController>(
      () => DtlperformaController(),
    );
  }
}
