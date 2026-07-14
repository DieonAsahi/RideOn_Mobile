import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class WelcomeController extends GetxController {
  final box = GetStorage();

  @override
  void onReady() {
    super.onReady();

    final isFirstInstall = box.read("first_install") ?? true;
    final token = box.read("token");

    if (!isFirstInstall) {
      if (token != null) {
        Get.offAllNamed("/mainscreen");
      } else {
        Get.offAllNamed("/login");
      }
    }
  }

  void getStarted() {
    box.write("first_install", false);
    Get.offAllNamed("/login");
  }
}