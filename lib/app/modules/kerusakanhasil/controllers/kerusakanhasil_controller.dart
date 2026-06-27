import 'package:get/get.dart';

class KerusakanhasilController extends GetxController {
  late Map<String, dynamic> hasil;

  @override
  void onInit() {
    super.onInit();
    hasil = Get.arguments ?? {};
  }

  void jadwalkanServis() {
    Get.toNamed('/rwttambah', arguments: {'jenis': 'Perbaikan'});
  }
}
