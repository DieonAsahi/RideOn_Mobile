import 'package:get/get.dart';

class DtlperformaController extends GetxController {
  var selectedFilter = 'Minggu'.obs;

  final mingguTanggal = [
    "29 Apr",
    "30 Apr",
    "2 Mei",
    "3 Mei",
    "4 Mei",
    "5 Mei",
    "6 Mei",
  ];

  final mingguData = [20.0, 40.0, 35.0, 60.0, 80.0, 70.0, 30.0];

  final bulanTanggal = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "Mei",
    "Jun",
    "Jul",
    "Ags",
    "Sep",
    "Okt",
    "Nov",
    "Des",
  ];

  final bulanData = [
    70.0,
    75.0,
    80.0,
    82.0,
    78.0,
    85.0,
    88.0,
    90.0,
    86.0,
    89.0,
    92.0,
    94.0,
  ];

  final tahunTanggal = ["2021", "2022", "2023", "2024", "2025"];

  final tahunData = [60.0, 70.0, 80.0, 85.0, 89.0];

  List<String> get tanggal {
    switch (selectedFilter.value) {
      case 'Bulan':
        return bulanTanggal;
      case 'Tahun':
        return tahunTanggal;
      default:
        return mingguTanggal;
    }
  }

  List<double> get performa {
    switch (selectedFilter.value) {
      case 'Bulan':
        return bulanData;
      case 'Tahun':
        return tahunData;
      default:
        return mingguData;
    }
  }

  void changeFilter(String value) {
    selectedFilter.value = value;
  }
}
