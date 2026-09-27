import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:capbatu/app/modules/Feature/kendaraan/controllers/kendaraan_controller.dart';
import 'package:capbatu/app/modules/Feature/home/controllers/home_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PluskendaraanController extends GetxController {
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  var step = 1.obs;
  var imageStep = 0.obs;
  var odometerStep = 0.obs;

  var selectedBrand = ''.obs;
  var selectedModel = ''.obs;
  var selectedYear = ''.obs;

  final picker = ImagePicker();
  final box = GetStorage();

  File? odometerImage;
  File? selectedVehicleImage;
  CameraController? cameraController;

  var isCameraInitialized = false.obs;
  var isScanning = false.obs; // Indikator scanning aktif
  final isManualOdometer = false.obs;

  var odometerImageUrl = ''.obs;
  var odometerImagePublicId = ''.obs;
  var vehicleImageUrl = ''.obs;
  var vehicleImagePublicId = ''.obs;

  var isFromLogin = false.obs;
  var isLoading = false.obs;
  var isUploading = false.obs;

  // Variabel untuk perulangan scan otomatis
  Timer? _scanTimer;
  bool _isProcessing = false;

  // ================= TEXT CONTROLLER =================
  final platController = TextEditingController();
  final estimasiHarianController = TextEditingController();
  final odometerController = TextEditingController();

  // ================= Kendaraan =================
  final Map<String, List<String>> vehicleData = {
    "Honda": ["Beat", "Vario 125", "Vario 160", "PCX", "Supra X"],
    "Yamaha": ["NMAX", "Aerox", "Mio M3", "Lexi", "Jupiter Z1"],
    "Suzuki": ["Satria F150", "Address", "Nex II", "Smash"],
  };

  // ================= KOMPONEN =================
  final List<String> komponen = [
    "Oli Mesin",
    "Oli Gardan",
    "CVT",
    "Busi",
    "Kampas Rem",
    "Filter Udara",
  ];

  final Map<String, int> componentIds = {
    "Oli Mesin": 1,
    "Oli Gardan": 2,
    "CVT": 3,
    "Busi": 4,
    "Kampas Rem": 5,
    "Filter Udara": 6,
  };

  final Map<String, TextEditingController> komponenControllers = {
    "Oli Mesin": TextEditingController(),
    "Oli Gardan": TextEditingController(),
    "CVT": TextEditingController(),
    "Busi": TextEditingController(),
    "Kampas Rem": TextEditingController(),
    "Filter Udara": TextEditingController(),
  };

  @override
  void onInit() {
    super.onInit();
    isFromLogin.value = Get.arguments == true;
    print("isFromLogin = ${isFromLogin.value}");
  }

  // ================= AMBIL FOTO ODOMETER (CV REALTIME) =================
  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        Get.snackbar("Error", "Kamera tidak ditemukan");
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

      // Nyalakan loop pengambilan frame berkala
      startLiveScanningLoop();
    } catch (e) {
      Get.snackbar("Error Kamera", e.toString());
    }
  }

  void startLiveScanningLoop() {
    isScanning.value = true;
    _isProcessing = false;

    // Menjepret preview kamera secara otomatis setiap 2000 ms (2 detik)
    _scanTimer = Timer.periodic(const Duration(milliseconds: 2000), (
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

      // Eksekusi manipulasi crop gambar pada Isolate background thread
      final croppedBytes = await compute(_cropImageIsolate, bytes);

      // Bersihkan cache file aslinya
      try {
        await File(picture.path).delete();
      } catch (_) {}

      if (croppedBytes == null) {
        _isProcessing = false;
        return;
      }

      final croppedPath = "${Directory.systemTemp.path}/odometer_crop_live.jpg";
      File croppedFile = File(croppedPath)..writeAsBytesSync(croppedBytes);

      // Mengirimkan gambar potongan target ke server OCR Paddle
      final odometerValue = await scanOdometerFromBE(croppedFile);

      // Batas maksimum odometer disesuaikan (999999 sesuai kode awal Anda)
      if (odometerValue != null && odometerValue <= 999999) {
        stopScanningLoop();

        odometerImage = croppedFile;
        odometerController.text = odometerValue.toString();

        // Unggah gambar secara asinkron ke server cloud aset kendaraan
        uploadImage(croppedFile).then((uploadResult) {
          if (uploadResult != null) {
            odometerImageUrl.value = uploadResult["url"];
            odometerImagePublicId.value = uploadResult["public_id"];
          }
        });

        await disposeCamera();
        odometerStep.value = 2; // Berpindah otomatis ke status hasil ocr
        Get.snackbar("Berhasil", "Odometer otomatis terdeteksi!");
        return;
      }
    } catch (e) {
      print("Error real-time processing: $e");
    } finally {
      _isProcessing = false;
    }
  }

  static Uint8List? _cropImageIsolate(Uint8List imageBytes) {
    img.Image? original = img.decodeImage(imageBytes);
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

  void stopScanningLoop() {
    isScanning.value = false;
    _scanTimer?.cancel();
    _scanTimer = null;
  }

  Future<void> disposeCamera() async {
    stopScanningLoop();
    if (cameraController != null) {
      await cameraController!.dispose();
      cameraController = null;
    }
    isCameraInitialized.value = false;
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

  Future<void> pickVehicleImage(ImageSource source) async {
    try {
      final picked = await picker.pickImage(source: source, imageQuality: 70);
      if (picked == null) return;

      selectedVehicleImage = File(picked.path);
      isUploading.value = true;

      final result = await uploadImage(selectedVehicleImage!);
      if (result != null) {
        vehicleImageUrl.value = result["url"];
        vehicleImagePublicId.value = result["public_id"];
      }

      imageStep.value = 1;
      Get.snackbar("Berhasil", "Gambar berhasil diupload");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isUploading.value = false;
    }
  }

  void nextStep() {
    if (step.value == 1 && selectedBrand.value.isEmpty) {
      Get.snackbar("Peringatan", "Silakan pilih merek kendaraan");
      return;
    }
    if (step.value == 2 && selectedModel.value.isEmpty) {
      Get.snackbar("Peringatan", "Silakan pilih model kendaraan");
      return;
    }
    if (step.value == 3 && selectedYear.value.isEmpty) {
      Get.snackbar("Peringatan", "Silakan pilih tahun kendaraan");
      return;
    }
    if (step.value == 4) {
      final plate = platController.text.trim();
      final plateRegex = RegExp(r'^[A-Z]{1,2}\s?[0-9]{1,4}\s?[A-Z]{1,3}$');
      if (plate.isEmpty) {
        Get.snackbar("Peringatan", "Plat nomor wajib diisi");
        return;
      }
      if (!plateRegex.hasMatch(plate.toUpperCase())) {
        Get.snackbar("Peringatan", "Format plat nomor tidak valid");
        return;
      }
    }
    if (step.value == 5 && vehicleImageUrl.value.isEmpty) {
      Get.snackbar("Peringatan", "Silakan upload gambar kendaraan");
      return;
    }
    if (step.value == 6) {
      final dailyKm = int.tryParse(estimasiHarianController.text.trim());
      if (dailyKm == null || dailyKm <= 0) {
        Get.snackbar("Peringatan", "Estimasi harian harus berupa angka valid");
        return;
      }
    }
    if (step.value == 7) {
      final odometer = int.tryParse(odometerController.text.trim());
      if (odometer == null || odometer <= 0) {
        Get.snackbar("Peringatan", "Odometer harus berupa angka valid");
        return;
      }
      // Foto odometer hanya wajib jika menggunakan mode pemindaian OCR / kamera
      if (!isManualOdometer.value && odometerImageUrl.value.isEmpty) {
        Get.snackbar("Peringatan", "Foto odometer belum berhasil diupload");
        return;
      }
    }

    if (step.value == 8) {
      saveVehicle();
      return;
    }
    step.value++;
  }

  void prevStep() {
    if (step.value > 1) {
      step.value--;
    }
  }

  Future<void> saveVehicle() async {
    try {
      isLoading.value = true;
      final token = box.read("token");
      final currentOdo = int.tryParse(odometerController.text.trim()) ?? 0;

      final components = komponen.map((item) {
        return {
          "component_id": componentIds[item],
          "last_replaced_date": DateTime.now().toIso8601String(),
          "last_replaced_odometer": currentOdo,
          "service_days": int.tryParse(komponenControllers[item]!.text) ?? 0,
        };
      }).toList();

      final body = {
        "brand": selectedBrand.value,
        "model": selectedModel.value,
        "year": int.tryParse(selectedYear.value) ?? 0,
        "plate_number": platController.text.trim(),
        "vehicle_image": vehicleImageUrl.value,
        "odometer_image": odometerImageUrl.value,
        "estimated_km_per_day":
            int.tryParse(estimasiHarianController.text) ?? 0,
        "current_odometer": currentOdo,
        "components": components,
      };

      final response = await http.post(
        Uri.parse("$baseUrl/api/vehicle/add-vehicle"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        box.write("vehicle_id", data["vehicle"]["id"]);
        Get.snackbar("Berhasil", "Kendaraan berhasil ditambahkan");

        if (Get.isRegistered<HomeController>()) {
          final homeC = Get.find<HomeController>();
          homeC.vehicleId = data["vehicle"]["id"].toString();
          homeC.getVehicles();
          homeC.fetchHome();
        }

        if (Get.isRegistered<KendaraanController>()) {
          Get.find<KendaraanController>().getVehicles();
        }

        if (isFromLogin.value) {
          Get.offNamed('/mainscreen');
        } else {
          Get.offNamed('/mainscreen', arguments: 1);
        }
      } else {
        Get.snackbar("Error", data['message'] ?? "Terjadi kesalahan");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
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

  // Metode warisan lama sengaja dikosongkan karena beralih ke stream loop otomatis
  Future<void> captureAndScanOdometer() async {}

  @override
  void onClose() {
    disposeCamera();
    platController.dispose();
    estimasiHarianController.dispose();
    odometerController.dispose();
    for (var c in komponenControllers.values) {
      c.dispose();
    }
    super.onClose();
  }
}
