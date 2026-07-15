import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
  final namaController = ''.obs;
  late String vehicleId;
  final box = GetStorage();
  final vehicleImage = ''.obs;

  var isLoadingOdometer = false.obs;
  var odometer = 0.obs;
  var components = <VehicleComponent>[].obs;

  var isLoading = false.obs;
  var tanggal = <String>[].obs;
  var performa = <double>[].obs;

  var currentVehicleIndex = 0.obs;
  var vehicles = <dynamic>[].obs;

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
    print("INIT HASH = $hashCode");

    vehicleId = box.read("vehicle_id") ?? "";

    getVehicles();

    if (vehicleId.isEmpty) {
      print("Vehicle ID kosong");
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

  void previousVehicle() {
    if (currentVehicleIndex.value < vehicles.length - 1) {
      currentVehicleIndex.value++;

      final id = vehicles[currentVehicleIndex.value]["id"];
      box.write("vehicle_id", id);
      vehicleId = id;
      fetchHome();
    }
  }

  void nextVehicle() {
    if (currentVehicleIndex.value > 0) {
      currentVehicleIndex.value--;

      final id = vehicles[currentVehicleIndex.value]["id"];
      box.write("vehicle_id", id);
      vehicleId = id;
      fetchHome();
    }
  }

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

  Future<void> getVehicles() async {
    final token = box.read("token");

    final response = await http.get(
      Uri.parse(
        "https://hireable-unelegant-linwood.ngrok-free.dev/api/vehicle/my-vehicles",
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);
    vehicles.value = data;

    final selectedId = box.read("vehicle_id");

    currentVehicleIndex.value = vehicles.indexWhere(
      (e) => e["id"] == selectedId,
    );

    if (currentVehicleIndex.value < 0) {
      currentVehicleIndex.value = 0;
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
        Uri.parse(
          "https://hireable-unelegant-linwood.ngrok-free.dev/api/analisis/artikel?${params.join("&")}",
        ),
      );
      print(response.statusCode);
      print(response.body);

      final json = jsonDecode(response.body);
      if (json["status"] == "success") {
        lastUpdateArtikel.value = json["lastUpdate"];

        artikelTopik.value = (json["charts"]["barChartTopik"] as List)
            .map((e) => TopikModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print(e);
    } finally {
      isLoadingArtikel.value = false;
    }
  }

  Future<void> fetchArtikelFilter() async {
    String url =
        "https://hireable-unelegant-linwood.ngrok-free.dev/api/analisis/artikel-filter";

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

    print("FILTER URL = $url");

    final response = await http.get(Uri.parse(url));
    print(response.statusCode);
    print(response.body);

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
        Uri.parse(
          "https://hireable-unelegant-linwood.ngrok-free.dev/api/analisis/artikel-trend?${params.join("&")}",
        ),
      );
      print(response.statusCode);
      print(response.body);

      final json = jsonDecode(response.body);

      if (json["status"] == "success") {
        lastUpdateTrendTopik.value = json["lastUpdate"];

        trendTopik.value = (json["data"] as List)
            .map((e) => TrendTopikModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print(e);
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
        Uri.parse(
          "https://hireable-unelegant-linwood.ngrok-free.dev/api/analisis/tren-komponen?${params.join("&")}",
        ),
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
    } catch (e, stack) {
      print(e);
      print(stack);
    } finally {
      isLoadingKomponen.value = false;
    }
  }

  Future<void> fetchKomponenFilter() async {
    String url =
        "https://hireable-unelegant-linwood.ngrok-free.dev/api/analisis/komponen-filter";

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

    print(url);

    final response = await http.get(Uri.parse(url));

    print(response.statusCode);
    print(response.body);

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

  Future<void> fetchHome() async {
    try {
      isLoading.value = true;
      isLoadingOdometer.value = true;
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

      print(response.statusCode);
      print(response.body);

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

      print("HOME VEHICLE ID = $vehicleId");
      print("HOME ODOMETER = ${data['vehicle']['current_odometer']}");
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY:");
      print(response.body);
    } catch (e) {
      print(e);
    } finally {
      isLoadingOdometer.value = false;
      isLoading.value = false;
    }
  }
}
