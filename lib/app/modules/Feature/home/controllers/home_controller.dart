import 'package:get/get.dart';

class HomeController extends GetxController {
  final namaController = 'Atha Dion Saputra'.obs;

  var odometer = 42560.obs;

  var tanggal = <String>[
    "29 Apr",
    "30 Apr",
    "2 Mei",
    "3 Mei",
    "4 Mei",
    "5 Mei",
    "6 Mei"
  ].obs;

  var performa = <double>[20, 40, 35, 60, 80, 70, 30].obs;
}
