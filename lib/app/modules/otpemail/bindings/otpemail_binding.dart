import 'package:get/get.dart';

import '../controllers/otpemail_controller.dart';

class OtpemailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpemailController>(
      () => OtpemailController(),
    );
  }
}
