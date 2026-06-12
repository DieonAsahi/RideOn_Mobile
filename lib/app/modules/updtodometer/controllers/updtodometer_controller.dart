import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class UpdtodometerController extends GetxController {
  final box = GetStorage();

  CameraController? cameraController;

  var isCameraInitialized = false.obs;
  var isLoading = false.obs;

  var pageState = 0.obs;
  // 0 = kamera
  // 1 = hasil OCR

  File? odometerImage;

  var odometerImageUrl = ''.obs;
  var odometerImagePublicId = ''.obs;

  final odometerController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    Future.microtask(() async {
      await initCamera();
    });
  }

  Future<int?> scanOdometerFromBE(File imageFile) async {
    try {
      final token = box.read("token");

      var request = http.MultipartRequest(
        "POST",
        Uri.parse("https://hireable-unelegant-linwood.ngrok-free.dev/api/ocr"),
      );

      request.headers["Authorization"] = "Bearer $token";

      request.files.add(
        await http.MultipartFile.fromPath("image", imageFile.path),
      );

      final response = await request.send();

      final body = await response.stream.bytesToString();

      print(body);

      if (response.statusCode == 200) {
        final data = jsonDecode(body);

        if (data["success"] == true) {
          return int.tryParse(data["odometer"].toString());
        }
      }

      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();

    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );

    cameraController = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await cameraController!.initialize();

    isCameraInitialized.value = true;
  }

  Future<void> disposeCamera() async {
    await cameraController?.dispose();
    cameraController = null;
    isCameraInitialized.value = false;
  }

  Future<Map<String, dynamic>?> uploadImage(File file) async {
    try {
      final token = box.read("token");

      var request = http.MultipartRequest(
        "POST",
        Uri.parse(
          "https://hireable-unelegant-linwood.ngrok-free.dev/api/vehicle/upload-vehicle-image",
        ),
      );

      request.headers["Authorization"] = "Bearer $token";

      request.files.add(await http.MultipartFile.fromPath("image", file.path));

      final response = await request.send();

      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(body);
      }

      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> captureAndScanOdometer() async {
    try {
      if (cameraController == null ||
          !cameraController!.value.isInitialized ||
          cameraController!.value.isTakingPicture) {
        return;
      }

      isLoading.value = true;

      final XFile picture = await cameraController!.takePicture();

      final bytes = await File(picture.path).readAsBytes();

      img.Image? original = img.decodeImage(bytes);

      if (original == null) {
        Get.snackbar("Error", "Gagal membaca gambar");
        return;
      }

      double ratio = 2.8;

      int cropWidth = (original.width * 0.75).toInt();
      int cropHeight = (cropWidth / ratio).toInt();

      int cropX = ((original.width - cropWidth) / 2).toInt();
      int cropY = ((original.height - cropHeight) / 2).toInt();

      img.Image cropped = img.copyCrop(
        original,
        x: cropX,
        y: cropY,
        width: cropWidth,
        height: cropHeight,
      );

      final croppedPath = "${Directory.systemTemp.path}/odometer_crop.jpg";

      File croppedFile = File(croppedPath)
        ..writeAsBytesSync(img.encodeJpg(cropped, quality: 80));

      odometerImage = croppedFile;

      final uploadResult = await uploadImage(croppedFile);

      if (uploadResult != null) {
        odometerImageUrl.value = uploadResult["url"];
        odometerImagePublicId.value = uploadResult["public_id"];
      }

      final odometerValue = await scanOdometerFromBE(croppedFile);

      if (odometerValue == null) {
        Get.snackbar("Error", "OCR gagal membaca odometer");
        return;
      }

      if (odometerValue > 500000) {
        Get.snackbar("Peringatan", "Odometer tidak masuk akal");
        return;
      }

      odometerController.text = odometerValue.toString();

      await disposeCamera();

      pageState.value = 1;

      Get.snackbar("Berhasil", "Odometer berhasil dibaca");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOdometer() async {
    try {
      isLoading.value = true;

      final vehicleId = Get.arguments;

      final token = box.read("token");

      final response = await http.put(
        Uri.parse(
          "https://hireable-unelegant-linwood.ngrok-free.dev/api/vehicle/update-odometer",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "vehicle_id": vehicleId,
          "new_odometer": int.tryParse(odometerController.text) ?? 0,
          "odometer_image": odometerImageUrl.value,
        }),
      );

      print(response.body);

      if (response.statusCode == 200) {
        Get.back(result: true);

        Get.snackbar("Berhasil", "Odometer berhasil diperbarui");
      } else {
        Get.snackbar("Error", "Gagal memperbarui odometer");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    disposeCamera();
    odometerController.dispose();
    super.onClose();
  }
}
