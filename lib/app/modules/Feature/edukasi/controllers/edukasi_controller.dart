import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArtikelModel {
  final String source;
  final String title;
  final String date;
  final String desc;
  final String logo;

  ArtikelModel({
    required this.source,
    required this.title,
    required this.date,
    required this.desc,
    required this.logo,
  });
}

class EdukasiController extends GetxController {
  final searchController = TextEditingController();
  RxString search = ''.obs;
  final artikelList = <ArtikelModel>[
    ArtikelModel(
      source: "hondacengkareng.com",
      title: "Kesalahan Umum Perawatan Motor dan Cara Menghindarinya",
      date: "21 Jul 2025",
      desc: "Kesalahan umum dalam perawatan motor dan cara menghindarinya.",
      logo: "assets/logos/logo1.png",
    ),
    ArtikelModel(
      source: "Kompas.com",
      title: "Langkah Mudah Mengganti Oli Motor Sendiri di Rumah",
      date: "10 Apr 2023",
      desc: "Siapkan peralatan dan pilih lokasi nyaman sebelum ganti oli.",
      logo: "assets/logos/logo2.png",
    ),
    ArtikelModel(
      source: "PT Wahanaartha Ritelindo",
      title: "Panduan Servis Motor: Kapan dan Apa Saja yang Harus Dilakukan",
      date: "29 Jun 2025",
      desc: "Servis berkala penting untuk menjaga performa motor.",
      logo: "assets/logos/logo3.png",
    ),
    ArtikelModel(
      source: "Otomotif Academy Yogyakarta",
      title: "11 Kerusakan yang Sering Terjadi pada Motor Matic",
      date: "28 Feb 2025",
      desc: "Kerusakan motor matic sering terjadi pada bagian CVT dan oli.",
      logo: "assets/logos/logo4.png",
    ),
    ArtikelModel(
      source: "Adira Finance",
      title: "Tips Perawatan untuk Motor yang Sering Dipakai Jarak Jauh",
      date: "22 Mei 2025",
      desc: "Motor jarak jauh memerlukan pengecekan rutin dan servis berkala.",
      logo: "assets/logos/logo5.png",
    ),
  ].obs;

  List<ArtikelModel> get filteredArtikel {
    if (search.value.isEmpty) return artikelList;

    return artikelList.where((item) {
      return item.title.toLowerCase().contains(search.value.toLowerCase()) ||
          item.source.toLowerCase().contains(search.value.toLowerCase());
    }).toList();
  }
}
