import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:capbatu/app/modules/Feature/profil/controllers/profil_controller.dart';
import 'package:capbatu/app/services/connectivity_service.dart';
import 'package:capbatu/app/widgets/app_snackbar.dart';

class EditprofilController extends GetxController {
  final box = GetStorage();
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];
  
  final ImagePicker picker = ImagePicker();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();

  var imageUrl = ''.obs;
  var selectedImage = Rx<File?>(null);

  var isLoading = false.obs;
  var isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  Future<void> getProfile() async {
    try {
      isLoading.value = true;

      final token = box.read("token");

      final response = await http.get(
        Uri.parse("$baseUrl/api/auth/profile"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      nameController.text = data["full_name"] ?? "";
      emailController.text = data["email"] ?? "";
      bioController.text = data["bio"] ?? "";
      imageUrl.value = data["image_url"] ?? "";
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    try {
      isSaving.value = true;

      final token = box.read("token");

      var request = http.MultipartRequest(
        "PUT",
        Uri.parse("$baseUrl/api/auth/update-profile"),
      );

      request.headers["Authorization"] = "Bearer $token";

      request.fields["full_name"] = nameController.text;
      request.fields["bio"] = bioController.text;

      if (selectedImage.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath("image", selectedImage.value!.path),
        );
      }

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (Get.isRegistered<ProfilController>()) {
          Get.find<ProfilController>().getProfile(force: true);
        }
        Get.back();
        AppSnackbar.success("Profil berhasil diperbarui.");
      } else {
        String errorMsg = "Gagal update profil";
        try {
          final errJson = jsonDecode(resBody);
          errorMsg = errJson["error"] ?? errJson["message"] ?? errorMsg;
        } catch (_) {}
        Get.snackbar("Error", errorMsg);
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        Get.snackbar("Error", "Gagal memperbarui profil");
      }
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
    super.onClose();
  }
}
