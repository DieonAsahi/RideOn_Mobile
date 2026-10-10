import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../services/connectivity_service.dart';

class DtlperformaController extends GetxController {
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];
  
  int get dataCount => performa.length;
  bool get hasData => dataCount > 0;
  bool get isFewData => dataCount < 8;
  double get maxChartHeight => 210;
  double get bottomAreaHeight => 30;
  double get averagePerformance {
    if (performa.isEmpty) return 0;

    return performa.reduce((a, b) => a + b) / performa.length;
  }

  String get performanceText {
    if (averagePerformance % 1 == 0) {
      return "${averagePerformance.toInt()}%";
    }
    return "${averagePerformance.toStringAsFixed(1)}%";
  }

  String get performanceStatus {
    if (averagePerformance >= 90) {
      return "Kendaraan Anda dalam kondisi sangat baik";
    } else if (averagePerformance >= 75) {
      return "Kendaraan dalam kondisi baik";
    } else if (averagePerformance >= 55) {
      return "Performa kendaraan perlu perhatian";
    } else if (averagePerformance >= 35) {
      return "Perlu pemeriksaan ringan";
    } else {
      return "Segera lakukan pemeriksaan kendaraan";
    }
  }

  final box = GetStorage();
  late final String vehicleId;
  var isLoading = false.obs;

  var selectedFilter = 'Minggu'.obs;

  var mingguTanggal = <String>[].obs;
  var mingguData = <double>[].obs;

  var bulanTanggal = <String>[].obs;
  var bulanData = <double>[].obs;

  var tahunTanggal = <String>[].obs;
  var tahunData = <double>[].obs;

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

  Future<void> fetchPerformanceHistory() async {
    try {
      isLoading.value = true;

      final token = box.read("token");

      final response = await http.get(
        Uri.parse("$baseUrl/api/vehicle/performance-history/$vehicleId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final List history = jsonDecode(response.body);

      history.sort((a, b) {
        final dateA = DateTime.parse(a['created_at']);
        final dateB = DateTime.parse(b['created_at']);
        return dateA.compareTo(dateB);
      });

      final now = DateTime.now();

      // ================= Minggu =================
      final last7Days = history.where((item) {
        final date = DateTime.parse(item['created_at']);
        return date.isAfter(now.subtract(const Duration(days: 7)));
      }).toList();

      mingguTanggal.value = last7Days.map<String>((item) {
        final date = DateTime.parse(item['created_at']);
        return "${date.day}/${date.month}";
      }).toList();

      mingguData.value = last7Days.map<double>((item) {
        return (item['performance_percent'] as num).toDouble();
      }).toList();

      print("MINGGU DATA: $mingguData");
      print("MINGGU TANGGAL: $mingguTanggal");

      if (mingguData.isEmpty) {
        mingguTanggal.value = ["-"];
        mingguData.value = [0];
      }

      // ================= BULAN =================
      final Map<String, List<double>> monthlyMap = {};

      for (var item in history) {
        final date = DateTime.parse(item['created_at']);

        final key = "${date.month}-${date.year}";

        monthlyMap.putIfAbsent(key, () => []);

        monthlyMap[key]!.add((item['performance_percent'] as num).toDouble());
      }

      bulanTanggal.value = [];
      bulanData.value = [];

      monthlyMap.forEach((key, values) {
        final split = key.split('-');

        final month = int.parse(split[0]);

        const monthNames = [
          "",
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

        bulanTanggal.add(monthNames[month]);

        bulanData.add(values.reduce((a, b) => a + b) / values.length);
      });

      // ================= TAHUN =================

      final Map<String, List<double>> yearlyMap = {};

      for (var item in history) {
        final date = DateTime.parse(item['created_at']);

        final key = date.year.toString();

        yearlyMap.putIfAbsent(key, () => []);

        yearlyMap[key]!.add((item['performance_percent'] as num).toDouble());
      }

      tahunTanggal.value = [];
      tahunData.value = [];

      yearlyMap.forEach((key, values) {
        tahunTanggal.add(key);

        tahunData.add(values.reduce((a, b) => a + b) / values.length);
      });

      print(history);
    } catch (e) {
      print(e);
      ConnectivityService.handleNetworkError(e);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();

    vehicleId = box.read("vehicle_id") ?? "";

    fetchPerformanceHistory();
  }
}
