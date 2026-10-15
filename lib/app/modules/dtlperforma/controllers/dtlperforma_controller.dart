import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

/// Model data untuk titik kordinat grafik performa
class PerformancePoint {
  final String label;
  final double? score;

  const PerformancePoint({
    required this.label,
    this.score,
  });
}

class DtlperformaController extends GetxController {
  final String? baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];
  final GetStorage box = GetStorage();

  // ==========================================
  // 1. STATE (VARIABEL OBSERVABLES)
  // ==========================================
  /// Status loading untuk skeleton
  final isLoading = true.obs;

  /// Data detail kendaraan
  /// Key wajib: vehicle_image, brand, model, plate_number, year, current_odometer, daily_usage
  final vehicle = <String, dynamic>{}.obs;

  /// Skor performa kendaraan saat ini (0 - 100)
  final currentScore = 0.0.obs;

  /// Persentase perubahan performa dari minggu lalu (bisa minus atau plus)
  final weeklyChangeValue = 0.0.obs;

  /// Tab filter terpilih ("Minggu", "Bulan", "Tahun")
  final selectedFilter = 'Minggu'.obs;

  /// Data servis terakhir
  final latestService = Rx<Map<String, dynamic>?>(null);

  /// Titik-titik grafik performa
  final chartPoints = <PerformancePoint>[].obs;
  final selectedChartPointIndex = (-1).obs;

  late String vehicleId;
  List<Map<String, dynamic>> _history = [];

  // ==========================================
  // GETTERS UNTUK UI & HELPER
  // ==========================================
  Color get scoreColor {
    final score = currentScore.value.round();
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String get performanceStatus {
    final score = currentScore.value.round();
    if (score >= 75) return 'Baik';
    if (score >= 50) return 'Perlu Perhatian';
    return 'Buruk';
  }

  String get performanceText => '${currentScore.value.round()}%';

  double? get weeklyChange => weeklyChangeValue.value;

  Color get weeklyChangeColor {
    final change = weeklyChangeValue.value;
    final roundedChange = change.round();
    if (roundedChange <= -15) return Colors.red;
    if (roundedChange < 0) return Colors.orange;
    return Colors.green;
  }

  String get weeklyChangeText {
    final value = weeklyChangeValue.value.round();
    final prefix = value > 0 ? '+' : '';
    return '$prefix$value% dari minggu lalu';
  }

  String get dailyUsageText => vehicle['daily_usage']?.toString() ?? '0 Km';

  @override
  void onInit() {
    super.onInit();
    vehicleId = box.read('vehicle_id')?.toString() ?? '';
    fetchPerformanceHistory();
  }

  // ==========================================
  // 3. LOGIKA & FUNGSI UTAMA
  // ==========================================
  /// Mengganti tab filter aktif dan memperbarui titik-titik grafik
  void changeFilter(String filter) {
    selectedFilter.value = filter;
    _buildChartPoints();
  }

  void selectChartPoint(int index) {
    if (index < 0 ||
        index >= chartPoints.length ||
        chartPoints[index].score == null) {
      return;
    }
    selectedChartPointIndex.value = index;
  }

  /// Mengambil data histori performa, detail kendaraan, dan servis terakhir
  Future<void> fetchPerformanceHistory() async {
    isLoading.value = true;
    vehicleId = box.read('vehicle_id')?.toString() ?? '';

    try {
      final token = box.read('token')?.toString();
      final hasValidConfig = baseUrl != null && baseUrl!.isNotEmpty && token != null && token.isNotEmpty && vehicleId.isNotEmpty;

      if (!hasValidConfig) {
        // Gunakan solid dummy data jika belum login / belum ada koneksi backend
        _applyDummyData();
        return;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final responses = await Future.wait([
        http.get(
          Uri.parse('$baseUrl/api/vehicle/vehicle-health/$vehicleId'),
          headers: headers,
        ).timeout(const Duration(seconds: 8)),
        http.get(
          Uri.parse('$baseUrl/api/vehicle/performance-history/$vehicleId'),
          headers: headers,
        ).timeout(const Duration(seconds: 8)),
        http.get(
          Uri.parse('$baseUrl/api/vehicle/service-history/$vehicleId'),
          headers: headers,
        ).timeout(const Duration(seconds: 8)),
      ]);

      if (responses[0].statusCode == 200) {
        final health = _asMap(jsonDecode(responses[0].body));
        final vehicleData = _asMap(health['vehicle']);
        final performance = _asMap(health['performance']);

        // Set data kendaraan & hitung pemakaian harian
        calculateDailyUsage(vehicleData);
        vehicle.assignAll(vehicleData);

        // Ambil current performa real-time yang sudah memperhitungkan komponen mati (Math.min(km, day))
        final healthScore = _toDouble(performance['current']);
        if (healthScore != null) {
          currentScore.value = healthScore;
        }

        // Parse history performa jika respons ke-2 sukses
        if (responses[1].statusCode == 200) {
          final historyData = jsonDecode(responses[1].body);
          if (historyData is List) {
            _history = historyData
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
              ..sort((a, b) {
                final dateA = _recordDate(a);
                final dateB = _recordDate(b);
                if (dateA == null) return dateB == null ? 0 : -1;
                if (dateB == null) return 1;
                return dateA.compareTo(dateB);
              });
          }
        }

        if (currentScore.value == 0.0 && _history.isNotEmpty) {
          currentScore.value = _latestHistoryScore();
        }

        // Hitung persentase perubahan dari minggu lalu
        _calculateWeeklyChange();

        // Parse riwayat servis terakhir jika respons ke-3 sukses
        if (responses[2].statusCode == 200) {
          final serviceData = jsonDecode(responses[2].body);
          if (serviceData is List) {
            final services = serviceData
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .where((item) => item['status']?.toString() != 'Dibatalkan')
                .toList()
              ..sort((a, b) {
                final dateA = DateTime.tryParse(a['service_date']?.toString() ?? '');
                final dateB = DateTime.tryParse(b['service_date']?.toString() ?? '');
                if (dateA == null) return dateB == null ? 0 : 1;
                if (dateB == null) return -1;
                return dateB.compareTo(dateA);
              });

            if (services.isNotEmpty) {
              final s = services.first;
              latestService.value = {
                'title': s['service_type'] ?? s['title'] ?? s['master_components']?['name'] ?? 'Servis Kendaraan',
                'service_date': s['service_date'] ?? DateTime.now().toIso8601String(),
                'workshop_name': s['workshop_name'] ?? 'Bengkel',
                'price': s['price'] ?? 0,
                'master_components': s['master_components'] is Map
                    ? Map<String, dynamic>.from(s['master_components'])
                    : {'name': s['service_type'] ?? 'Servis', 'icon': 'bengkel'},
              };
            } else {
              latestService.value = null;
            }
          }
        }

        _buildChartPoints();
      } else {
        // Fallback jika respons status selain 200
        _applyDummyData();
      }
    } catch (e) {
      // Sediakan dummy data solid jika terjadi offline / exception
      _applyDummyData();
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // 4. LOGIKA PERHITUNGAN PEMAKAIAN HARIAN
  // ==========================================
  /// Menghitung atau mengestimasi pemakaian harian:
  /// - Jika belum pernah update odometer: gunakan estimated_km_per_day registrasi
  /// - Jika sudah pernah update: (Odometer Baru - Odometer Lama) / Selisih Hari
  /// - Menggabungkan / overwrite nilai ini ke vehicle['daily_usage'] dengan akhiran " Km"
  void calculateDailyUsage(Map<String, dynamic> v) {
    final double defaultEstimate = _toDouble(v['estimated_km_per_day']) ?? 15.0;
    final String? lastUpdateStr = v['last_odometer_update']?.toString();
    final int? currentOdo = _toInt(v['current_odometer']);
    final int? initialOdo = _toInt(v['initial_odometer']) ?? _toInt(v['previous_odometer']);
    final String? createdAtStr = v['created_at']?.toString();

    double dailyUsageKm = defaultEstimate;

    // Cek apakah user sudah pernah update odometer
    if (lastUpdateStr != null && lastUpdateStr.isNotEmpty) {
      final DateTime? lastUpdate = DateTime.tryParse(lastUpdateStr)?.toLocal();
      final DateTime? startDate = createdAtStr != null ? DateTime.tryParse(createdAtStr)?.toLocal() : null;

      if (lastUpdate != null) {
        final DateTime baseDate = startDate ?? lastUpdate.subtract(const Duration(days: 1));
        final double diffDays = lastUpdate.difference(baseDate).inHours / 24.0;

        if (diffDays >= 1 && currentOdo != null && initialOdo != null && currentOdo > initialOdo) {
          dailyUsageKm = (currentOdo - initialOdo) / diffDays;
        } else if (_toDouble(v['estimated_km_per_day']) != null) {
          dailyUsageKm = _toDouble(v['estimated_km_per_day'])!;
        }
      }
    }

    final String formatted = dailyUsageKm == dailyUsageKm.roundToDouble()
        ? dailyUsageKm.toInt().toString()
        : dailyUsageKm.toStringAsFixed(1);

    v['daily_usage'] = '$formatted Km';
  }

  /// Menghitung persentase perubahan performa dari minggu lalu
  void _calculateWeeklyChange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 14));
    final end = today.subtract(const Duration(days: 7));

    final previousWeek = _history.where((item) {
      final date = _recordDate(item);
      return date != null && !date.isBefore(start) && date.isBefore(end);
    }).map(_recordScore).whereType<double>().toList();

    if (previousWeek.isNotEmpty) {
      final avgPrevious = previousWeek.reduce((a, b) => a + b) / previousWeek.length;
      weeklyChangeValue.value = _roundToOneDecimal(currentScore.value - avgPrevious);
    } else if (_history.isNotEmpty) {
      // Gunakan selisih dari catatan performa awal jika ada
      final firstScore = _recordScore(_history.first) ?? currentScore.value;
      weeklyChangeValue.value = _roundToOneDecimal(currentScore.value - firstScore);
    } else {
      weeklyChangeValue.value = 0.0;
    }
  }

  double _roundToOneDecimal(double val) => double.parse(val.toStringAsFixed(1));

  // ==========================================
  // LOGIKA CHART (MINGGU, BULAN, TAHUN)
  // ==========================================
  void _buildChartPoints() {
    final now = DateTime.now();

    final List<String> labels;
    final List<PerformancePoint> points = [];

    switch (selectedFilter.value) {
      case 'Bulan':
        labels = const ['Mg 1', 'Mg 2', 'Mg 3', 'Mg 4'];
        final currentWeekIdx = ((now.day - 1) ~/ 7).clamp(0, 3);

        for (var i = 0; i < labels.length; i++) {
          if (i > currentWeekIdx) {
            points.add(PerformancePoint(label: labels[i], score: null));
          } else if (i == currentWeekIdx) {
            points.add(PerformancePoint(label: labels[i], score: currentScore.value));
          } else {
            // Estimasi skor minggu lalu
            final pastScore = (currentScore.value - (currentWeekIdx - i) * 2.5).clamp(20.0, 100.0);
            points.add(PerformancePoint(label: labels[i], score: pastScore));
          }
        }
        break;

      case 'Tahun':
        labels = const [
          'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
          'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
        ];
        final currentMonthIdx = now.month - 1;

        for (var i = 0; i < labels.length; i++) {
          if (i > currentMonthIdx) {
            points.add(PerformancePoint(label: labels[i], score: null));
          } else if (i == currentMonthIdx) {
            points.add(PerformancePoint(label: labels[i], score: currentScore.value));
          } else {
            // Skor bulan-bulan sebelumnya
            final pastScore = (currentScore.value - (currentMonthIdx - i) * 1.5).clamp(30.0, 100.0);
            points.add(PerformancePoint(label: labels[i], score: pastScore));
          }
        }
        break;

      default: // 'Minggu'
        labels = const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
        // DateTime.weekday: 1 = Senin, 7 = Minggu
        final currentDayIdx = now.weekday - 1;

        for (var i = 0; i < labels.length; i++) {
          if (i > currentDayIdx) {
            points.add(PerformancePoint(label: labels[i], score: null));
          } else if (i == currentDayIdx) {
            points.add(PerformancePoint(label: labels[i], score: currentScore.value));
          } else {
            // Skor hari sebelumnya dalam minggu ini
            final pastScore = (currentScore.value - (currentDayIdx - i) * 1.0).clamp(10.0, 100.0);
            points.add(PerformancePoint(label: labels[i], score: pastScore));
          }
        }
    }

    chartPoints.assignAll(points);
    selectedChartPointIndex.value = points.lastIndexWhere(
      (point) => point.score != null,
    );
  }

  // ==========================================
  // DUMMY / MOCK RESPONSE DATA
  // ==========================================
  void _applyDummyData() {
    final mockVehicle = <String, dynamic>{
      'vehicle_image': '',
      'brand': 'Honda',
      'model': 'Vario 160',
      'plate_number': 'B 1234 ABC',
      'year': '2023',
      'current_odometer': 12500,
      'initial_odometer': 10000,
      'estimated_km_per_day': 20,
      'last_odometer_update': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      'created_at': DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
    };

    calculateDailyUsage(mockVehicle);
    vehicle.assignAll(mockVehicle);

    currentScore.value = 85.0;
    weeklyChangeValue.value = 5.0; // +5% dari minggu lalu

    latestService.value = {
      'title': 'Ganti Oli & Busi',
      'service_date': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      'workshop_name': 'Bengkel AHASS Motor',
      'price': 150000,
      'master_components': {
        'name': 'Oli Mesin',
        'icon': 'oli',
      },
    };

    _buildChartPoints();
  }

  // ==========================================
  // PARSER HELPERS
  // ==========================================
  double _latestHistoryScore() {
    for (final item in _history.reversed) {
      final score = _recordScore(item);
      if (score != null) return score;
    }
    return 80.0;
  }

  DateTime? _recordDate(Map<String, dynamic> item) =>
      DateTime.tryParse(item['created_at']?.toString() ?? '')?.toLocal();

  double? _recordScore(Map<String, dynamic> item) =>
      _toDouble(item['performance_percent']);

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }
}
