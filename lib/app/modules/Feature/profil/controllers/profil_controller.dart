import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ProfilController extends GetxController {
  final box = GetStorage();

  var isLoading = false.obs;

  var name = ''.obs;
  var bio = ''.obs;
  var imageUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  Future<void> getProfile() async {
    try {
      isLoading.value = true;

      final token = box.read("token");

      final response = await http.get(
        Uri.parse(
          "https://hireable-unelegant-linwood.ngrok-free.dev/api/auth/profile",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      name.value = data["full_name"] ?? "";
      bio.value = data["bio"] ?? "";
      imageUrl.value = data["image_url"] ?? "";
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}