import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RwtservisController extends GetxController {
  var selectedFilter = 'Semua'.obs;

  final riwayat = [
    {
      'jenis': 'SERVIS RUTIN',
      'detail': 'Oli Mesin & Filter Udara',
      'tanggal': '1 Mei 2026',
      'odometer': '42.560 km',
      'bengkel': 'AHASS Brebes',
      'biaya': '-',
      'status': 'Dijadwalkan',
      'statusColor': Colors.grey,
    },
    {
      'jenis': 'PERBAIKAN',
      'detail': 'Tambal Ban',
      'tanggal': '26 Apr 2026',
      'odometer': '42.398 km',
      'bengkel': 'Makmur Bengkel',
      'biaya': 'Rp 25.000',
      'status': 'Proses',
      'statusColor': Colors.orange,
    },
    {
      'jenis': 'PERBAIKAN',
      'detail': 'Tambal Ban Belakang',
      'tanggal': '23 Apr 2026',
      'odometer': '42.398 km',
      'bengkel': 'Bengkel Om Toni',
      'biaya': 'Rp 20.000',
      'status': 'Selesai',
      'statusColor': Colors.green,
    },
  ].obs;

  List<Map<String, dynamic>> get filteredData {
    if (selectedFilter.value == 'Semua') {
      return riwayat;
    }

    return riwayat
        .where((item) => item['jenis'] == selectedFilter.value.toUpperCase())
        .toList();
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }
}
