import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class VehicleComponent {
  final String title;
  final String imagePath;

  final int currentKm;
  final int maxKm;

  final int currentDays;
  final int maxDays;

  VehicleComponent({
    required this.title,
    required this.imagePath,
    required this.currentKm,
    required this.maxKm,
    required this.currentDays,
    required this.maxDays,
  });

  factory VehicleComponent.fromJson(Map<String, dynamic> json) {
    return VehicleComponent(
      title: json['name'],

      imagePath: "assets/icons/${json['icon']}.png",

      currentKm: json['remaining_km'],
      maxKm: json['max_km'],

      currentDays: json['remaining_days'],
      maxDays: json['max_days'],
    );
  }
}

class HomeController extends GetxController {
  final namaController = ''.obs;
  late final String vehicleId;
  final box = GetStorage();
  final vehicleImage = ''.obs;

  var odometer = 0.obs;

  var components = <VehicleComponent>[].obs;

  var isLoading = false.obs;
  var tanggal = <String>[].obs;
  var performa = <double>[].obs;

  @override
  void onInit() {
    super.onInit();

    vehicleId = box.read("vehicle_id") ?? "";

    if (vehicleId.isEmpty) {
      print("Vehicle ID kosong");
      return;
    }

    fetchHome();
  }

  String formatTanggal(DateTime date) {
    const bulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];  
    return '${date.day} ${bulan[date.month]}';
  }

  Future<void> fetchHome() async {
    try {
      isLoading.value = true;
      final token = box.read("token");

      final response = await http.get(
        Uri.parse(
          "https://hireable-unelegant-linwood.ngrok-free.dev/api/vehicle/vehicle-health/$vehicleId",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      namaController.value = data['user']['full_name'];
      vehicleImage.value = data['vehicle']['vehicle_image'];

      final history = (data['performance']['history'] as List)
        ..sort(
          (a, b) => DateTime.parse(
            a['created_at'],
          ).compareTo(DateTime.parse(b['created_at'])),
        );

      tanggal.value = history.map<String>((item) {
        final date = DateTime.parse(item['created_at']);
        return formatTanggal(date);
      }).toList();

      performa.value = history.map<double>((item) {
        return (item['performance_percent'] as num).toDouble();
      }).toList();

      if (history.isEmpty) {
        tanggal.value = ["-"];
        performa.value = [0];
      }

      odometer.value = data['vehicle']['current_odometer'];

      components.value = (data['components'] as List)
          .map((e) => VehicleComponent.fromJson(e))
          .toList();

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY:");
      print(response.body);
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}
