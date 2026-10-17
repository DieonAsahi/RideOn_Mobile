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
import 'package:capbatu/app/widgets/app_feedback_widgets.dart';

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

  // Menyimpan data awal untuk perbandingan perubahan (Unsaved Changes)
  String initialName = "";
  String initialBio = "";

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  /// Cek apakah ada perubahan data pada form
  bool hasChanges() {
    bool isNameChanged = nameController.text.trim() != initialName;
    bool isBioChanged = bioController.text.trim() != initialBio;
    bool isImageChanged = selectedImage.value != null;
    return isNameChanged || isBioChanged || isImageChanged;
  }

  /// Validasi Format File Gambar (Harus JPG / JPEG / PNG, Bukan Video)
  bool _isValidImage(String path) {
    final lowerPath = path.toLowerCase();
    return lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.png');
  }

  Future<void> pickImageFromGallery() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      if (!_isValidImage(image.path)) {
        AppFeedback.inputRequired(
          message:
              'Harap pilih foto dengan format JPG, JPEG, atau PNG (bukan video/file lain).',
        );
        return;
      }
      selectedImage.value = File(image.path);
    }
  }

  Future<void> pickImageFromCamera() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      if (!_isValidImage(image.path)) {
        AppFeedback.inputRequired(
          message: 'Harap ambil foto dengan format JPG atau PNG.',
        );
        return;
      }
      selectedImage.value = File(image.path);
    }
  }

  void removeImage() {
    selectedImage.value = null;
    imageUrl.value = '';
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

      initialName = data["full_name"] ?? "";
      initialBio = data["bio"] ?? "";

      nameController.text = initialName;
      emailController.text = data["email"] ?? "";
      bioController.text = initialBio;
      imageUrl.value = data["image_url"] ?? "";
    } catch (e) {
      ConnectivityService.handleNetworkError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    // Validasi tambahan sebelum kirim
    if (nameController.text.trim().isEmpty) {
      AppFeedback.inputRequired(message: 'Nama tidak boleh kosong.');
      return;
    }

    if (bioController.text.length > 60) {
      AppFeedback.inputRequired(message: 'Bio maksimal 60 karakter.');
      return;
    }

    try {
      isSaving.value = true;

      final token = box.read("token");

      var request = http.MultipartRequest(
        "PUT",
        Uri.parse("$baseUrl/api/auth/update-profile"),
      );

      request.headers["Authorization"] = "Bearer $token";

      request.fields["full_name"] = nameController.text.trim();
      request.fields["bio"] = bioController.text.trim();

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
          errorMsg = errJson["message"] ?? errJson["error"] ?? errorMsg;
        } catch (_) {}
        AppFeedback.profileUpdateFailed(message: errorMsg);
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        AppFeedback.profileUpdateFailed(
          message: 'Gagal memperbarui profil, periksa koneksi Anda.',
        );
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
