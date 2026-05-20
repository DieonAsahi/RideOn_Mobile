import 'package:capbatu/app/modules/Feature/kendaraan/controllers/kendaraan_controller.dart';
import 'package:capbatu/app/modules/Feature/home/controllers/home_controller.dart';
import 'package:capbatu/app/modules/Feature/edukasi/controllers/edukasi_controller.dart';
import 'package:capbatu/app/modules/Feature/profil/controllers/profil_controller.dart';
import 'package:capbatu/app/modules/Feature/service/controllers/service_controller.dart';
import 'package:get/get.dart';

import '../controllers/mainscreen_controller.dart';

class MainscreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainscreenController>(() => MainscreenController());

    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<KendaraanController>(() => KendaraanController());
    Get.lazyPut<ServiceController>(() => ServiceController());
    Get.lazyPut<EdukasiController>(() => EdukasiController());
    Get.lazyPut<ProfilController>(() => ProfilController());
  }
}
