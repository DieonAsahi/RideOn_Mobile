import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:capbatu/app/modules/Feature/kendaraan/controllers/kendaraan_controller.dart';

class PluskendaraanController extends GetxController {
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

  var odometerImageUrl = ''.obs;
  var odometerImagePublicId = ''.obs;
  var vehicleImageUrl = ''.obs;
  var vehicleImagePublicId = ''.obs;

  var isFromLogin = false.obs;
  var isLoading = false.obs;
  var isUploading = false.obs;

  // ================= TEXT CONTROLLER =================

  final platController = TextEditingController();

  final estimasiHarianController = TextEditingController();

  final odometerController = TextEditingController(text: "334488");

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

  // ================= INIT =================

  @override
  void onInit() {
    super.onInit();

    isFromLogin.value = Get.arguments == true;

    print("isFromLogin = ${isFromLogin.value}");
  }

  // ================= AMBIL FOTO ODOMETER =================
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

  // ================= PICK + UPLOAD IMAGE =================
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

  // ================= STEP =================
  void nextStep() {
    // STEP 1
    if (step.value == 1) {
      if (selectedBrand.value.isEmpty) {
        Get.snackbar("Peringatan", "Silakan pilih merek kendaraan");
        return;
      }
    }

    // STEP 2
    if (step.value == 2) {
      if (selectedModel.value.isEmpty) {
        Get.snackbar("Peringatan", "Silakan pilih model kendaraan");
        return;
      }
    }

    // STEP 3
    if (step.value == 3) {
      if (selectedYear.value.isEmpty) {
        Get.snackbar("Peringatan", "Silakan pilih tahun kendaraan");
        return;
      }
    }

    // STEP 4
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

    // STEP 5
    if (step.value == 5) {
      if (vehicleImageUrl.value.isEmpty) {
        Get.snackbar("Peringatan", "Silakan upload gambar kendaraan");
        return;
      }
    }

    // STEP 6
    if (step.value == 6) {
      final dailyKm = int.tryParse(estimasiHarianController.text.trim());

      if (dailyKm == null || dailyKm <= 0) {
        Get.snackbar("Peringatan", "Estimasi harian harus berupa angka valid");
        return;
      }
    }

    // STEP 7
    if (step.value == 7) {
      final odometer = int.tryParse(odometerController.text.trim());

      if (odometer == null || odometer <= 0) {
        Get.snackbar("Peringatan", "Odometer harus berupa angka valid");
        return;
      }

      if (odometerImageUrl.value.isEmpty) {
        Get.snackbar("Peringatan", "Foto odometer belum berhasil diupload");
        return;
      }
    }

    // NEXT
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

  // ================= SAVE VEHICLE =================
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
        "brand": selectedBrand.value.isEmpty ? "" : selectedBrand.value,

        "model": selectedModel.value.isEmpty ? "" : selectedModel.value,

        "year": int.tryParse(selectedYear.value) ?? 0,

        "plate_number": platController.text.trim(),

        "vehicle_image": vehicleImageUrl.value.isEmpty
            ? ""
            : vehicleImageUrl.value,

        "odometer_image": odometerImageUrl.value.isEmpty
            ? ""
            : odometerImageUrl.value,
        "estimated_km_per_day":
            int.tryParse(estimasiHarianController.text) ?? 0,

        "current_odometer": int.tryParse(odometerController.text) ?? 0,

        "components": components,
      };

      print(jsonEncode(body));

      final response = await http.post(
        Uri.parse(
          "https://hireable-unelegant-linwood.ngrok-free.dev/api/vehicle/add-vehicle",
        ),

        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      print(response.statusCode);
      print(response.body);

      Map<String, dynamic> data = {};

      try {
        data = jsonDecode(response.body);
        print("DATA:");
        print(data);

        print("VEHICLE:");
        print(data["vehicle"]);
      } catch (e) {
        Get.snackbar("Error", "Response bukan JSON");
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("MASUK SUCCESS");

        box.write("vehicle_id", data["vehicle"]["id"]);
        Get.snackbar("Berhasil", "Kendaraan berhasil ditambahkan");

        if (isFromLogin.value) {
          Get.offNamed('/mainscreen');
        } else {
          print("GET BACK");
          print("CAN BACK = ${Get.key.currentState?.canPop()}");

          Get.find<KendaraanController>().getVehicles();

          Get.offNamed('/mainscreen', arguments: 1);
        }
      } else {
        Get.snackbar(
          "Error",
          data['message'] ?? data['error'] ?? "Terjadi kesalahan",
        );
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

      if (uploadResult == null) {
        Get.snackbar("Error", "Upload foto odometer gagal");
        return;
      }

      odometerImageUrl.value = uploadResult["url"];
      odometerImagePublicId.value = uploadResult["public_id"];

      // ================= UPLOAD ODOMETER KE CLOUDINARY =================
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

      odometerStep.value = 2;

      await disposeCamera();

      Get.snackbar("Berhasil", "Odometer berhasil dibaca");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> disposeCamera() async {
    await cameraController?.dispose();
    cameraController = null;
    isCameraInitialized.value = false;
  }

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
