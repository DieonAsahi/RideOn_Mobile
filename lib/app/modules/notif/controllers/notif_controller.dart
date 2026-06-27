import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:timeago/timeago.dart' as timeago;

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

  factory NotifModel.fromJson(Map<String, dynamic> json) {
    return NotifModel(
      image: "assets/icons/${json["master_components"]["icon"]}.png",
      status: json["severity"],
      title: json["title"],
      desc: json["message"],
      time: timeago.format(DateTime.parse(json["created_at"]), locale: 'id'),
    );
  }
}

class NotifController extends GetxController {
  final box = GetStorage();

  var notifList = <NotifModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getNotifications();
  }

  Future<void> getNotifications() async {
    try {
      isLoading.value = true;

      final token = box.read("token");
      final vehicleId = box.read("vehicle_id");

      final response = await http.get(
        Uri.parse(
          "https://hireable-unelegant-linwood.ngrok-free.dev/api/vehicle/notifications/$vehicleId",
        ),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        notifList.value = data.map((e) => NotifModel.fromJson(e)).toList();
      }
    } finally {
      isLoading.value = false;
    }
  }
}
