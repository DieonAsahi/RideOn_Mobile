import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ArtikelModel {
  final String source;
  final String title;
  final String date;
  final String desc;
  final String link; // Tambahan field link sesuai backend

  ArtikelModel({
    required this.source,
    required this.title,
    required this.date,
    required this.desc,
    required this.link,
  });

  // Fungsi helper untuk mengubah JSON dari backend menjadi Object Flutter
  factory ArtikelModel.fromJson(Map<String, dynamic> json) {
    return ArtikelModel(
      source: json['sumber'] ?? 'Portal Otomotif',
      title: json['judul'] ?? '',
      date: json['tanggal'] ?? '',
      desc: json['ringkasan'] ?? '',
      link: json['link'] ?? '',
    );
  }
}

class EdukasiController extends GetxController {
  final searchController = TextEditingController();
  final _connect = GetConnect(); // HTTP Client bawaan GetX
  
  RxString search = ''.obs;
  RxList<ArtikelModel> artikelList = <ArtikelModel>[].obs;
  RxBool isLoading = false.obs; // State untuk loading indicator

  @override
  void onInit() {
    super.onInit();
    fetchArtikel(); // Ambil data dari backend saat controller aktif
  }

Future<void> fetchArtikel() async {
  try {
    isLoading.value = true;

    final response = await _connect.get(
      'https://hireable-unelegant-linwood.ngrok-free.dev/api/edukasi/edu',
    );

    if (response.statusCode == 200) {
      final List data = response.body['data'];

      artikelList.assignAll(
        data.map((e) => ArtikelModel.fromJson(e)).toList(),
      );
    }
  } catch (e) {
    print(e);
  } finally {
    isLoading.value = false;
  }
}

  // Fungsi untuk membuka website artikel saat kartu di-klik
  Future<void> bukaArtikel(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
        Get.snackbar('Error', 'Tidak dapat membuka link artikel');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuka browser');
    }
  }

  List<ArtikelModel> get filteredArtikel {
    if (search.value.isEmpty) return artikelList;

    return artikelList.where((item) {
      return item.title.toLowerCase().contains(search.value.toLowerCase()) ||
          item.source.toLowerCase().contains(search.value.toLowerCase());
    }).toList();
  }
}
