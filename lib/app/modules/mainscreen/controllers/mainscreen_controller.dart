import 'package:get/get.dart';
import 'package:capbatu/app/modules/Feature/home/controllers/home_controller.dart';
import 'package:capbatu/app/modules/Feature/kendaraan/controllers/kendaraan_controller.dart';
import 'package:capbatu/app/modules/Feature/service/controllers/service_controller.dart';
import 'package:capbatu/app/modules/Feature/edukasi/controllers/edukasi_controller.dart';
import 'package:capbatu/app/modules/Feature/profil/controllers/profil_controller.dart';

class MainscreenController extends GetxController {
  var currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;

    switch (index) {
      case 0:
        Get.find<HomeController>().fetchHome();
        break;

      case 1:
        Get.find<KendaraanController>().getVehicles();
        break;

      case 2:
        Get.find<ServiceController>().getServices();
        break;

      case 3:
        Get.find<EdukasiController>().fetchArtikel();
        break;

      case 4:
        Get.find<ProfilController>().getProfile();
        break;
    }
  }

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      currentIndex.value = Get.arguments;

      Future.delayed(Duration.zero, () {
        changePage(currentIndex.value);
      });
    }
  }
}
