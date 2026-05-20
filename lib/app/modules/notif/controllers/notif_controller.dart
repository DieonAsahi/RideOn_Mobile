import 'package:get/get.dart';

class NotifModel {
  final String image;
  final String status;
  final String title;
  final String desc;
  final String time;

  NotifModel({
    required this.image,
    required this.status,
    required this.title,
    required this.desc,
    required this.time,
  });
}

class NotifController extends GetxController {
  final notifList = <NotifModel>[
    NotifModel(
      image: 'assets/icons/Oli Mesin.png',
      status: 'Darurat',
      title: 'Oli Mesin',
      desc: 'Sudah melewati 40 km, ganti oli mesin sekarang',
      time: '46 menit yang lalu',
    ),

    NotifModel(
      image: 'assets/icons/Oli Mesin.png',
      status: 'Darurat',
      title: 'Oli Mesin',
      desc: 'Saatnya ganti oli mesin sekarang',
      time: '8 jam yang lalu',
    ),

    NotifModel(
      image: 'assets/icons/Kampas Rem.png',
      status: 'Mendesak',
      title: 'Kampas Rem',
      desc: 'Perlu diperiksa dalam 3 hari',
      time: '12 jam yang lalu',
    ),

    NotifModel(
      image: 'assets/icons/Oli Mesin.png',
      status: 'Mendesak',
      title: 'Oli Mesin',
      desc: '100 km lagi menuju ganti oli',
      time: '3 hari yang lalu',
    ),

    NotifModel(
      image: 'assets/icons/Busi.png',
      status: 'Segera',
      title: 'Busi',
      desc: 'Lakukan pengecekan dalam 7 hari',
      time: '4 hari yang lalu',
    ),

    NotifModel(
      image: 'assets/icons/Filter Udara.png',
      status: 'Darurat',
      title: 'Filter Udara',
      desc: 'Sudah melewati 6 hari, periksa filter udara sekarang',
      time: '6 hari yang lalu',
    ),

    NotifModel(
      image: 'assets/icons/CVT.png',
      status: 'Segera',
      title: 'CVT',
      desc: '300 km lagi menuju pengecekan CVT',
      time: '6 hari yang lalu',
    ),

    NotifModel(
      image: 'assets/icons/Oli Mesin.png',
      status: 'Segera',
      title: 'Oli Mesin',
      desc: 'Lakukan penggantian oli mesin dalam 7 hari',
      time: '6 hari yang lalu',
    ),
  ].obs;
}