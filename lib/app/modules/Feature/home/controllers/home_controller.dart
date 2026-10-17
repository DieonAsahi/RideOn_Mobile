import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:capbatu/app/services/auth_service.dart';
import 'package:capbatu/app/services/connectivity_service.dart';
import 'package:capbatu/app/modules/Feature/kendaraan/controllers/kendaraan_controller.dart';
import 'package:capbatu/app/modules/Feature/service/controllers/service_controller.dart';
import 'package:capbatu/app/modules/notif/controllers/notif_controller.dart';
import 'package:capbatu/app/widgets/app_feedback_widgets.dart';

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

class TopikModel {
  final String kata;
  final int jumlah;
  final String kategori;

  TopikModel({
    required this.kata,
    required this.jumlah,
    required this.kategori,
  });

  factory TopikModel.fromJson(Map<String, dynamic> json) {
    return TopikModel(
      kata: json["kata"],
      jumlah: json["jumlah"],
      kategori: json["kategori"],
    );
  }
}

class KomponenServisModel {
  final String komponen;
  final int totalServis;
  final String persentase;

  KomponenServisModel({
    required this.komponen,
    required this.totalServis,
    required this.persentase,
  });

  factory KomponenServisModel.fromJson(Map<String, dynamic> json) {
    return KomponenServisModel(
      komponen: json["komponen"],
      totalServis: json["total_servis"],
      persentase: json["persentase"],
    );
  }
}

class TrendTopikModel {
  final String label;
  final int jumlah;
  TrendTopikModel({required this.label, required this.jumlah});

  factory TrendTopikModel.fromJson(Map<String, dynamic> json) {
    return TrendTopikModel(label: json["label"], jumlah: json["jumlah"]);
  }
}

class HomeController extends GetxController {
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  final namaController = ''.obs;
  late String vehicleId;
  final box = GetStorage();
  final vehicleImage = ''.obs;

  var isLoadingOdometer = false.obs;
  var odometer = 0.obs;
  var components = <VehicleComponent>[].obs;
  var unreadNotifCount = 0.obs;

  var isDropdownOpen = false.obs;
  var isLoading = false.obs;
  var tanggal = <String>[].obs;
  var performa = <double>[].obs;

  var currentVehicleIndex = 0.obs;
  var vehicles = <dynamic>[].obs;

  var selectedVehicleId = "".obs;
  var vehiclePlat = "".obs;

  bool get isFirstVehicle => currentVehicleIndex.value == vehicles.length - 1;
  bool get isLastVehicle => vehicles.isEmpty || currentVehicleIndex.value == 0;

  final isLoadingArtikel = false.obs;
  final isLoadingKomponen = false.obs;
  final isLoadingTrendTopik = false.obs;

  final artikelTopik = <TopikModel>[].obs;
  final komponenServis = <KomponenServisModel>[].obs;
  final trendTopik = <TrendTopikModel>[].obs;

  final lastUpdateArtikel = "".obs;
  final lastUpdateKomponen = "".obs;
  final lastUpdateTrendTopik = "".obs;

  // Filter Komponen
  final selectedYearKomponen = 0.obs;
  final selectedMonthKomponen = 0.obs;
  final selectedWeekKomponen = 0.obs;
  // Filter Artikel
  final selectedYearArtikel = 0.obs;
  final selectedMonthArtikel = 0.obs;
  final selectedWeekArtikel = 0.obs;

  // Komponen
  final yearsKomponen = <int>[].obs;
  final monthsKomponen = <int>[].obs;
  final weeksKomponen = <int>[].obs;
  // Artikel
  final yearsArtikel = <int>[].obs;
  final monthsArtikel = <int>[].obs;
  final weeksArtikel = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
    vehicleId = box.read("vehicle_id") ?? "";

    getVehicles();

    if (vehicleId.isEmpty) {
      return;
    }

    fetchHome();

    fetchKomponenFilter();
    fetchArtikelFilter();

    fetchDashboardArtikel();
    fetchKomponenServis();

    fetchTrendTopik();
  }

  String formatLastUpdate(String isoString) {
    final date = DateTime.parse(isoString).toLocal();

    return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(date);
  }

  final List<String> namaBulan = [
    "",
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember",
  ];

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

  void changeVehicle(String id) {
    box.write("vehicle_id", id);
    vehicleId = id;
    selectedVehicleId.value = id;

    final index = vehicles.indexWhere((e) => e["id"].toString() == id);
    if (index != -1) {
      currentVehicleIndex.value = index;
      vehiclePlat.value = vehicles[index]["plate_number"]?.toString() ?? "-";
    } else {
      getVehicles();
    }

    fetchHome(force: true);

    // Sinkronkan ke KendaraanController agar berpindah ke paling atas dan badge aktif berpindah
    if (Get.isRegistered<KendaraanController>()) {
      Get.find<KendaraanController>().onVehicleChangedFromExternal(id);
    }

    // Sinkronkan ke ServiceController
    if (Get.isRegistered<ServiceController>()) {
      Get.find<ServiceController>().getServices(force: true);
    }

    // Sinkronkan ke NotifController jika aktif
    if (Get.isRegistered<NotifController>()) {
      Get.find<NotifController>().getNotifications(silent: true);
    }
  }

  void syncVehicleFromStorage() {
    final storedId = box.read("vehicle_id")?.toString();
    if (storedId != null && storedId.isNotEmpty && storedId != vehicleId) {
      changeVehicle(storedId);
    }
  }

  // void previousVehicle() {
  //   if (currentVehicleIndex.value < vehicles.length - 1) {
  //     currentVehicleIndex.value++;

  //     final id = vehicles[currentVehicleIndex.value]["id"];
  //     box.write("vehicle_id", id);
  //     vehicleId = id;
  //     fetchHome();
  //   }
  // }

  // void nextVehicle() {
  //   if (currentVehicleIndex.value > 0) {
  //     currentVehicleIndex.value--;

  //     final id = vehicles[currentVehicleIndex.value]["id"];
  //     box.write("vehicle_id", id);
  //     vehicleId = id;
  //     fetchHome();
  //   }
  // }

  Future<void> selectYearArtikel(int year) async {
    selectedYearArtikel.value = year;
    selectedMonthArtikel.value = 0;
    selectedWeekArtikel.value = 0;

    await fetchArtikelFilter();
    await fetchDashboardArtikel();
    await fetchTrendTopik();
  }

  Future<void> selectMonthArtikel(int month) async {
    selectedMonthArtikel.value = month;
    selectedWeekArtikel.value = 0;

    await fetchArtikelFilter();
    await fetchDashboardArtikel();
    await fetchTrendTopik();
  }

  Future<void> selectWeekArtikel(int week) async {
    selectedWeekArtikel.value = week;

    await fetchDashboardArtikel();
    await fetchTrendTopik();
  }

  Future<void> selectYearKomponen(int year) async {
    selectedYearKomponen.value = year;
    selectedMonthKomponen.value = 0;
    selectedWeekKomponen.value = 0;

    await fetchKomponenFilter();
    await fetchKomponenServis();
  }

  Future<void> selectMonthKomponen(int month) async {
    selectedMonthKomponen.value = month;
    selectedWeekKomponen.value = 0;

    await fetchKomponenFilter();
    await fetchKomponenServis();
  }

  Future<void> selectWeekKomponen(int week) async {
    selectedWeekKomponen.value = week;

    await fetchKomponenFilter();
    await fetchKomponenServis();
  }

  // Tambahkan fungsi ini di dalam HomeController
  Future<bool> updateOdometerManual(int newOdometer) async {
    try {
      final token = box.read("token");
      if (token == null) return false;

      final response = await http.put(
        Uri.parse("$baseUrl/api/vehicle/update-odometer"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "vehicle_id":
              vehicleId, // Mengambil ID kendaraan yang sedang aktif di Home
          "new_odometer": newOdometer,
          "odometer_image": "", // Kosong karena ini update manual lewat teks
        }),
      );

      if (response.statusCode == 200) {
        // Update angka odometer di UI secara instan
        odometer.value = newOdometer;

        // Refresh data lainnya (grafik, notif, dll)
        fetchHome(force: true);

        // Sinkronkan juga dengan KendaraanController jika terdaftar
        if (Get.isRegistered<KendaraanController>()) {
          Get.find<KendaraanController>().getVehicles(force: true);
        }

        return true;
      } else {
        String message = 'Gagal memperbarui odometer.';
        try {
          final data = jsonDecode(response.body);
          message = data['message'] ?? data['error'] ?? message;
        } catch (_) {}
        AppFeedback.odometerUpdateFailed(message: message);
        return false;
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        AppFeedback.odometerUpdateFailed(
          message: 'Gagal memperbarui odometer, periksa koneksi Anda.',
        );
      }
      return false;
    }
  }

  Future<void> getVehicles() async {
    final token = box.read("token");
    if (token == null) {
      AuthService.logout();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/vehicle/my-vehicles"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 401) {
        await AuthService.logout();
        return;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          vehicles.value = data;

          final selectedId = box.read("vehicle_id")?.toString();

          currentVehicleIndex.value = vehicles.indexWhere(
            (e) => e["id"].toString() == selectedId,
          );

          if (currentVehicleIndex.value < 0) {
            currentVehicleIndex.value = 0;
          }
          if (vehicles.isNotEmpty) {
            selectedVehicleId.value = vehicles[currentVehicleIndex.value]["id"]
                .toString();
            vehicleId = selectedVehicleId.value;

            vehiclePlat.value =
                vehicles[currentVehicleIndex.value]["plate_number"]
                    ?.toString() ??
                "-";
          }
        }
      }
    } catch (e) {
      ConnectivityService.handleNetworkError(e);
    }
  }

  Future<void> fetchDashboardArtikel() async {
    isLoadingArtikel.value = true;

    try {
      final params = <String>[];

      if (selectedYearArtikel.value != 0) {
        params.add("tahun=${selectedYearArtikel.value}");
      }

      if (selectedMonthArtikel.value != 0) {
        params.add("bulan=${selectedMonthArtikel.value}");
      }

      if (selectedWeekArtikel.value != 0) {
        params.add("minggu=${selectedWeekArtikel.value}");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/api/analisis/artikel?${params.join("&")}"),
      );
      final json = jsonDecode(response.body);
      if (json["status"] == "success") {
        lastUpdateArtikel.value = json["lastUpdate"];

        artikelTopik.value = (json["charts"]["barChartTopik"] as List)
            .map((e) => TopikModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      ConnectivityService.handleNetworkError(e);
    } finally {
      isLoadingArtikel.value = false;
    }
  }

  Future<void> fetchHome({bool force = false}) async {
    if (!force && components.isNotEmpty && namaController.value.isNotEmpty) {
      fetchUnreadNotifications();
      return;
    }
    try {
      isLoading.value = true;
      isLoadingOdometer.value = true;
      final token = box.read("token");
      final storedVehicleId = box.read("vehicle_id")?.toString();
      if (storedVehicleId != null &&
          storedVehicleId.isNotEmpty &&
          storedVehicleId != vehicleId) {
        vehicleId = storedVehicleId;
        selectedVehicleId.value = storedVehicleId;
        final idx = vehicles.indexWhere(
          (e) => e["id"].toString() == storedVehicleId,
        );
        if (idx != -1) {
          currentVehicleIndex.value = idx;
          vehiclePlat.value = vehicles[idx]["plate_number"]?.toString() ?? "-";
        }
      }

      if (token == null) {
        await AuthService.logout();
        return;
      }

      final response = await http.get(
        Uri.parse("$baseUrl/api/vehicle/vehicle-health/$vehicleId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 401) {
        await AuthService.logout();
        return;
      }

      if (response.statusCode != 200) {
        return;
      }

      final data = jsonDecode(response.body);

      if (data == null || data is! Map<String, dynamic>) {
        return;
      }

      if (data['user'] != null && data['user'] is Map) {
        namaController.value = data['user']['full_name']?.toString() ?? '';
      }

      if (data['vehicle'] != null && data['vehicle'] is Map) {
        vehicleImage.value = data['vehicle']['vehicle_image']?.toString() ?? '';
        odometer.value = data['vehicle']['current_odometer'] ?? 0;
      }

      if (data['performance'] != null && data['performance'] is Map) {
        final perfMap = data['performance'] as Map;
        final currentScore = perfMap['current'] != null
            ? (perfMap['current'] as num).toDouble()
            : null;

        if (perfMap['history'] != null && perfMap['history'] is List) {
          final history = (perfMap['history'] as List)
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
        }

        // Pastikan nilai performa terkini konsisten persis dengan backend real-time current score
        if (currentScore != null) {
          if (performa.isEmpty) {
            performa.value = [currentScore];
            tanggal.value = [formatTanggal(DateTime.now())];
          } else {
            // Update titik terakhir agar persis sama dengan real-time current score
            performa[performa.length - 1] = currentScore;
          }
        }
      }

      if (tanggal.isEmpty) {
        tanggal.value = ["-"];
        performa.value = [0];
      }

      if (data['components'] != null && data['components'] is List) {
        components.value = (data['components'] as List)
            .map((e) => VehicleComponent.fromJson(e))
            .toList();
      }

      await fetchUnreadNotifications();
    } catch (e) {
      ConnectivityService.handleNetworkError(e);
    } finally {
      isLoadingOdometer.value = false;
      isLoading.value = false;
    }
  }

  Future<void> fetchArtikelFilter() async {
    String url = "$baseUrl/api/analisis/artikel-filter";

    final params = <String>[];

    if (selectedYearArtikel.value != 0) {
      params.add("tahun=${selectedYearArtikel.value}");
    }

    if (selectedMonthArtikel.value != 0) {
      params.add("bulan=${selectedMonthArtikel.value}");
    }

    if (selectedWeekArtikel.value != 0) {
      params.add("minggu=${selectedWeekArtikel.value}");
    }

    if (params.isNotEmpty) {
      url += "?${params.join("&")}";
    }

    final response = await http.get(Uri.parse(url));

    final json = jsonDecode(response.body);

    if (json["status"] == "success") {
      yearsArtikel.value = List<int>.from(json["tahun"]);
      monthsArtikel.value = List<int>.from(json["bulan"]);
      weeksArtikel.value = List<int>.from(json["minggu"]);
    }

    if (selectedYearArtikel.value == 0 && yearsArtikel.isNotEmpty) {
      selectedYearArtikel.value = yearsArtikel.first;
    }
  }

  Future<void> fetchTrendTopik() async {
    // API backend mewajibkan tahun dan bulan terisi
    if (selectedYearArtikel.value == 0 || selectedMonthArtikel.value == 0) {
      trendTopik.clear();
      return;
    }

    isLoadingTrendTopik.value = true;

    try {
      final params = <String>[];

      if (selectedYearArtikel.value != 0) {
        params.add("tahun=${selectedYearArtikel.value}");
      }

      if (selectedMonthArtikel.value != 0) {
        params.add("bulan=${selectedMonthArtikel.value}");
      }

      if (selectedWeekArtikel.value != 0) {
        params.add("minggu=${selectedWeekArtikel.value}");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/api/analisis/artikel-trend?${params.join("&")}"),
      );
      final json = jsonDecode(response.body);

      if (json["status"] == "success") {
        lastUpdateTrendTopik.value = json["lastUpdate"];

        trendTopik.value = (json["data"] as List)
            .map((e) => TrendTopikModel.fromJson(e))
            .toList();
      }
    } catch (_) {
    } finally {
      isLoadingTrendTopik.value = false;
    }
  }

  Future<void> fetchKomponenServis() async {
    // print("FETCH HASH = $hashCode");
    // print("FETCH LENGTH = ${komponenServis.length}");

    isLoadingKomponen.value = true;

    try {
      final params = <String>[];

      if (selectedYearKomponen.value != 0) {
        params.add("tahun=${selectedYearKomponen.value}");
      }

      if (selectedMonthKomponen.value != 0) {
        params.add("bulan=${selectedMonthKomponen.value}");
      }

      if (selectedWeekKomponen.value != 0) {
        params.add("minggu=${selectedWeekKomponen.value}");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/api/analisis/tren-komponen?${params.join("&")}"),
      );

      // print(response.statusCode);
      // print(response.body);

      final json = jsonDecode(response.body);
      if (json["status"] == "success") {
        lastUpdateKomponen.value = json["lastUpdate"];
        komponenServis.value = (json["data"] as List)
            .map((e) => KomponenServisModel.fromJson(e))
            .toList();

        // print("Komponen setelah fetch: ${komponenServis.length}");
        // print("FETCH -> ${komponenServis.length}");
      }
      // print("Komponen setelah fetch: ${komponenServis.length}");
      // print("FETCH -> ${komponenServis.length}");

      // print("Jumlah komponen = ${komponenServis.length}");

      // for (final k in komponenServis) {
      //   print("${k.komponen} ${k.totalServis}");
      // }

      // print("FETCH HASH = $hashCode");
    } catch (e) {
      ConnectivityService.handleNetworkError(e);
    } finally {
      isLoadingKomponen.value = false;
    }
  }

  Future<void> fetchKomponenFilter() async {
    String url = "$baseUrl/api/analisis/komponen-filter";

    final params = <String>[];

    if (selectedYearKomponen.value != 0) {
      params.add("tahun=${selectedYearKomponen.value}");
    }

    if (selectedMonthKomponen.value != 0) {
      params.add("bulan=${selectedMonthKomponen.value}");
    }

    if (selectedWeekKomponen.value != 0) {
      params.add("minggu=${selectedWeekKomponen.value}");
    }

    if (params.isNotEmpty) {
      url += "?${params.join("&")}";
    }

    final response = await http.get(Uri.parse(url));

    final json = jsonDecode(response.body);

    if (json["status"] == "success") {
      yearsKomponen.value = List<int>.from(json["tahun"]);
      monthsKomponen.value = List<int>.from(json["bulan"]);
      weeksKomponen.value = List<int>.from(json["minggu"]);
    }

    if (selectedYearKomponen.value == 0 && yearsKomponen.isNotEmpty) {
      selectedYearKomponen.value = yearsKomponen.first;
    }
  }

  Future<void> fetchUnreadNotifications() async {
    try {
      final token = box.read("token");
      final vId = box.read("vehicle_id") ?? vehicleId;
      if (token == null || vId == null || vId.toString().isEmpty) return;

      final response = await http.get(
        Uri.parse("$baseUrl/api/vehicle/notifications/$vId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final unread = data.where((item) => item['is_read'] != true).length;
        unreadNotifCount.value = unread;
      }
    } catch (_) {}
  }
}
