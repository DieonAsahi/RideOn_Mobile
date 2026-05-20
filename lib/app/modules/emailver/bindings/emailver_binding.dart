import 'package:get/get.dart';

import '../controllers/emailver_controller.dart';

class EmailverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmailverController>(
      () => EmailverController(),
    );
  }
}
