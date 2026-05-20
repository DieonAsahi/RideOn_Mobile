import 'package:get/get.dart';

class Kendaraan {
  final String nama;
  final String plat;
  final String km;
  final String status;
  final String image;

  Kendaraan({
    required this.nama,
    required this.plat,
    required this.km,
    required this.status,
    required this.image,
  });
}

class KendaraanController extends GetxController {
  var kendaraanList = <Kendaraan>[].obs;

  void goToTambahKendaraan() {
    Get.toNamed('/pluskendaraan', arguments: false);
  }

  @override
  void onInit() {
    super.onInit();
    loadDummy();
  }

  void loadDummy() {
    kendaraanList.value = [
      Kendaraan(
        nama: "Honda Vario 150",
        plat: "G 5726 AP",
        km: "42.560 km",
        status: "Perlu Servis",
        image: "assets/images/motor.png",
      ),
      Kendaraan(
        nama: "Honda Beat CBS",
        plat: "G 2299 ABG",
        km: "7.324 km",
        status: "Optimal",
        image: "assets/images/beat.png",
      ),
      Kendaraan(
        nama: "Honda Beat CBS",
        plat: "G 1234 XYZ",
        km: "7.324 km",
        status: "Optimal",
        image: "assets/images/beat.png",
      ),
      Kendaraan(
        nama: "Honda Beat CBS",
        plat: "G 5678 MNO",
        km: "7.324 km",
        status: "Optimal",
        image: "assets/images/beat.png",
      ),
      Kendaraan(
        nama: "Honda Beat CBS",
        plat: "G 9012 PQR",
        km: "7.324 km",
        status: "Optimal",
        image: "assets/images/beat.png",
      ),
      Kendaraan(
        nama: "Honda Beat CBS",
        plat: "G 3456 STU",
        km: "7.324 km",
        status: "Optimal",
        image: "assets/images/beat.png",
      ),
    ];
  }
}
