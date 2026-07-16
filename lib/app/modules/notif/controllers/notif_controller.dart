import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../services/local_notification_service.dart';

class NotifModel {
  final int id;
  final String image;
  final String status;
  final String title;
  final String desc;
  final String time;

  NotifModel({
    required this.id,
    required this.image,
    required this.status,
    required this.title,
    required this.desc,
    required this.time,
  });

  factory NotifModel.fromJson(Map<String, dynamic> json) {
    return NotifModel(
      id: json["id"],
      image: "assets/icons/${json["master_components"]["icon"]}.png",
      status: json["severity"],
      title: json["title"],
      desc: json["message"],
      time: timeago.format(DateTime.parse(json["created_at"]), locale: "id"),
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
          "https://backend-capstone-snowy.vercel.app/api/vehicle/notifications/$vehicleId",
        ),
        headers: {"Authorization": "Bearer $token"},
      );

      print("STATUS CODE : ${response.statusCode}");
      print("RESPONSE BODY : ${response.body}");

      if (response.statusCode == 200) {
        try {
          final List data = jsonDecode(response.body);

          print("DATA LENGTH : ${data.length}");
          print("DATA : $data");

          notifList.value = data.map((e) => NotifModel.fromJson(e)).toList();

          print("NOTIF LENGTH : ${notifList.length}");
        } catch (e, s) {
          print("FROM JSON ERROR");
          print(e);
          print(s);
        }
      }

      await checkLocalNotification();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkLocalNotification() async {
    print("CHECK LOCAL");
    print("NOTIF LIST : ${notifList.length}");

    if (notifList.isEmpty) return;

    final newest = notifList.first;

    print("NEWEST ID : ${newest.id}");

    final lastId = box.read("last_notification_id");

    print("LAST ID : $lastId");

    if (lastId == newest.id) return;

    await LocalNotificationService.show(title: newest.title, body: newest.desc);

    await box.write("last_notification_id", newest.id);
  }
}
