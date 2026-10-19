import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:capbatu/app/modules/Feature/home/controllers/home_controller.dart';
import 'package:capbatu/app/modules/Feature/kendaraan/controllers/kendaraan_controller.dart';
import 'package:capbatu/app/services/connectivity_service.dart';
import 'package:capbatu/app/services/local_notification_service.dart';
import 'package:capbatu/app/widgets/app_snackbar.dart';
import 'package:capbatu/app/widgets/app_feedback_widgets.dart';

class UpdtodometerController extends GetxController {
  final box = GetStorage();
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  CameraController? cameraController;

  var isCameraInitialized = false.obs;
  var isLoading = false.obs;
  var isScanning = false.obs;

  var pageState = 0.obs; // 0 = kamera, 1 = hasil OCR
  File? odometerImage;

  var isManualOdometer = false.obs;
  var odometerImageUrl = ''.obs;
  var odometerImagePublicId = ''.obs;
  final odometerController = TextEditingController();

  // Pengendali Timer untuk Loop Pemindaian Real-time
  Timer? _scanTimer;
  bool _isProcessing = false;

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() async {
      await initCamera();
    });
  }

  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        AppFeedback.cameraUnavailable(message: 'Kamera tidak ditemukan.');
        return;
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;

      // Panggil fungsi loop scanning yang benar
      startLiveScanningLoop();
    } catch (e) {
      AppFeedback.cameraUnavailable();
    }
  }

  void startLiveScanningLoop() {
    isScanning.value = true;
    _isProcessing = false;

    // Diubah menjadi 500ms agar pemindaian odometer berjalan super cepat dan instan
    _scanTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) async {
      if (_isProcessing || !isScanning.value) return;

      if (cameraController == null ||
          !cameraController!.value.isInitialized ||
          cameraController!.value.isTakingPicture) {
        return;
      }

      _isProcessing = true;
      await _captureAndProcessFrame();
    });
  }

  Future<void> _captureAndProcessFrame() async {
    try {
      final XFile picture = await cameraController!.takePicture();
      final bytes = await File(picture.path).readAsBytes();

      // MENGGUNAKAN ISOLATE ADAPTIF YANG SAMA SEPERTI PLUS KENDARAAN
      final croppedBytes = await compute(_cropImageIsolate, bytes);

      try {
        await File(picture.path).delete();
      } catch (_) {}

      if (croppedBytes == null) {
        _isProcessing = false;
        return;
      }

      final tempPath = "${Directory.systemTemp.path}/odometer_live_crop.jpg";
      File croppedFile = File(tempPath)..writeAsBytesSync(croppedBytes);

      final odometerValue = await scanOdometerFromBE(croppedFile);

      // KUNCI PERBAIKAN: Batas dinaikkan menjadi 9999999 agar deteksi angka 6 Juta lolos validasi
      if (odometerValue != null && odometerValue <= 9999999) {
        stopScanningLoop();

        isManualOdometer.value = false;
        odometerImage = croppedFile;
        odometerController.text = odometerValue.toString();

        uploadImage(croppedFile).then((uploadResult) {
          if (uploadResult != null) {
            odometerImageUrl.value = uploadResult["url"];
            odometerImagePublicId.value = uploadResult["public_id"];
          }
        });

        await disposeCamera();
        pageState.value = 1; // Pindah ke layar hasil
        AppSnackbar.success('Odometer otomatis terdeteksi!');
        return;
      }
    } catch (e) {
      // Pemindaian akan mencoba kembali pada frame berikutnya.
    } finally {
      _isProcessing = false;
    }
  }

  // MENYELARASKAN FUNGSI ISOLATE SAMA PERSIS DENGAN MODUL TAMBAH KENDARAAN
  static Uint8List? _cropImageIsolate(Uint8List imageBytes) {
    img.Image? original = img.decodeImage(
      imageBytes,
    ); // Menggunakan decodeImage, bukan decodeJpg
    if (original == null) return null;

    if (original.width > original.height) {
      original = img.copyRotate(original, angle: 90);
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

    return Uint8List.fromList(img.encodeJpg(cropped, quality: 80));
  }

  Future<int?> scanOdometerFromBE(File imageFile) async {
    try {
      final token = box.read("token");
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/api/ocr"),
      );
      request.headers["Authorization"] = "Bearer $token";
      request.files.add(
        await http.MultipartFile.fromPath("image", imageFile.path),
      );

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        if (data["success"] == true) {
          return int.tryParse(data["odometer"].toString());
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> uploadImage(File file) async {
    try {
      final token = box.read("token");
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/api/vehicle/upload-vehicle-image"),
      );
      request.headers["Authorization"] = "Bearer $token";
      request.files.add(await http.MultipartFile.fromPath("image", file.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();
      if (response.statusCode == 200) return jsonDecode(body);
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateOdometer() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      final vehicleId = Get.arguments;
      final token = box.read("token");

      final cleanText = odometerController.text.replaceAll(
        RegExp(r'[^0-9.]'),
        '',
      );
      final parsedInt =
          int.tryParse(cleanText) ?? (double.tryParse(cleanText)?.round() ?? 0);

      if (parsedInt > 999999) {
        isLoading.value = false;
        AppFeedback.odometerUpdateFailed(
          message: "Odometer maksimal 999.999 km.",
        );
        return;
      }

      final response = await http.put(
        Uri.parse("$baseUrl/api/vehicle/update-odometer"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "vehicle_id": vehicleId,
          "new_odometer": parsedInt,
          "odometer_image": odometerImageUrl.value,
        }),
      );

      if (response.statusCode == 200) {
        final newKm = parsedInt;
        final todayStr = DateTime.now().toIso8601String().substring(0, 10);
        box.write('last_odometer_update_date', todayStr);
        await LocalNotificationService.cancelOdometerReminderToday();

        if (Get.isRegistered<HomeController>()) {
          final homeC = Get.find<HomeController>();
          homeC.odometer.value = newKm;
          homeC.fetchHome(force: true);
        }

        if (Get.isRegistered<KendaraanController>()) {
          Get.find<KendaraanController>().getVehicles(force: true);
        }

        Get.offNamed('/mainscreen', arguments: 0);
        AppSnackbar.success("Odometer berhasil diperbarui.");
      } else {
        String message = 'Gagal memperbarui odometer.';
        try {
          final data = jsonDecode(response.body);
          message = data['message'] ?? data['error'] ?? message;
        } catch (_) {}
        AppFeedback.odometerUpdateFailed(message: message);
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        AppFeedback.odometerUpdateFailed(
          message: 'Gagal memperbarui odometer, periksa koneksi Anda.',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void stopScanningLoop() {
    isScanning.value = false;
    _scanTimer?.cancel();
    _scanTimer = null;
    _isProcessing = false;
  }

  Future<void> disposeCamera() async {
    stopScanningLoop();
    if (cameraController != null) {
      await cameraController!.dispose();
      cameraController = null;
    }
    isCameraInitialized.value = false;
  }

  @override
  void onClose() {
    disposeCamera();
    odometerController.dispose();
    super.onClose();
  }
}
