import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:capbatu/app/modules/Feature/kendaraan/controllers/kendaraan_controller.dart';
import 'package:capbatu/app/modules/Feature/home/controllers/home_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:capbatu/app/services/connectivity_service.dart';
import 'package:capbatu/app/widgets/app_snackbar.dart';

// Import kamera dan isolate OCR (dipertahankan untuk referensi)
// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:camera/camera.dart';
// import 'package:image/image.dart' as img;

class PluskendaraanController extends GetxController {
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  // ================= STEP WIZARD (1, 2, 3) =================
  var step = 1.obs;

  // ================= STEP 1: KENDARAAN =================
  var selectedBrand = ''.obs;
  var selectedModel = ''.obs;
  var selectedYear = ''.obs;

  final List<String> brandOptions = ["Honda", "Yamaha", "Suzuki"];
  final List<String> yearOptions = ["2024", "2025", "2026"];

  final Map<String, List<String>> vehicleData = {
    "Honda": ["Beat", "Vario 125", "Vario 160", "PCX", "Supra X"],
    "Yamaha": ["NMAX", "Aerox", "Mio M3", "Lexi", "Jupiter Z1"],
    "Suzuki": ["Satria F150", "Address", "Nex II", "Smash"],
  };

  List<String> get availableModels =>
      selectedBrand.value.isNotEmpty
          ? (vehicleData[selectedBrand.value] ?? [])
          : [];

  bool get isModelDropdownEnabled => selectedBrand.value.isNotEmpty;

  final platController = TextEditingController();
  File? selectedVehicleImage;
  var vehicleImageUrl = ''.obs;
  var vehicleImagePublicId = ''.obs;

  final picker = ImagePicker();
  final box = GetStorage();

  var isFromLogin = false.obs;
  var isLoading = false.obs;
  var isUploading = false.obs;

  // ================= STEP 2: ESTIMASI & ODOMETER =================
  final estimasiHarianController = TextEditingController();
  final odometerController = TextEditingController();

  /*
  // =========================================================================================
  // FITUR KAMERA OCR ODOMETER (DI-KOMEN SEMENTARA / BYPASS KE INPUT MANUAL SESUAI PERMINTAAN)
  // =========================================================================================
  File? odometerImage;
  CameraController? cameraController;
  var isCameraInitialized = false.obs;
  var isScanning = false.obs;
  final isManualOdometer = true.obs;
  var odometerImageUrl = ''.obs;
  var odometerImagePublicId = ''.obs;
  var odometerStep = 0.obs;
  Timer? _scanTimer;
  bool _isProcessing = false;

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
      startLiveScanningLoop();
    } catch (e) {
      Get.snackbar("Error Kamera", e.toString());
    }
  }

  void startLiveScanningLoop() {
    isScanning.value = true;
    _isProcessing = false;
    _scanTimer = Timer.periodic(const Duration(milliseconds: 2000), (timer) async {
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
      final croppedBytes = await compute(_cropImageIsolate, bytes);
      try {
        await File(picture.path).delete();
      } catch (_) {}
      if (croppedBytes == null) {
        _isProcessing = false;
        return;
      }
      final croppedPath = "${Directory.systemTemp.path}/odometer_crop_live.jpg";
      File croppedFile = File(croppedPath)..writeAsBytesSync(croppedBytes);
      final odometerValue = await scanOdometerFromBE(croppedFile);
      if (odometerValue != null && odometerValue <= 999999) {
        stopScanningLoop();
        odometerImage = croppedFile;
        odometerController.text = odometerValue.toString();
        uploadImage(croppedFile).then((uploadResult) {
          if (uploadResult != null) {
            odometerImageUrl.value = uploadResult["url"];
            odometerImagePublicId.value = uploadResult["public_id"];
          }
        });
        await disposeCamera();
        odometerStep.value = 2;
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
  // =========================================================================================
  */

  // ================= STEP 3: KOMPONEN =================
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

  final Map<String, String> komponenHints = {
    "Oli Mesin": "Contoh : 28",
    "Oli Gardan": "Contoh : 56",
    "CVT": "Contoh : 67",
    "Busi": "Contoh : 90",
    "Kampas Rem": "Contoh : 120",
    "Filter Udara": "Contoh : 130",
  };

  // ================= VALIDATOR INLINE (TEKS MERAH DI BAWAH FIELD) =================
  // Step 1 Errors
  var brandError = ''.obs;
  var modelError = ''.obs;
  var yearError = ''.obs;
  var platError = ''.obs;
  var imageError = ''.obs;

  // Step 2 Errors
  var estimasiError = ''.obs;
  var odometerError = ''.obs;

  // Step 3 Errors
  var komponenErrors = <String, RxString>{}.obs;

  @override
  void onInit() {
    super.onInit();
    isFromLogin.value = Get.arguments == true;
    for (var k in komponen) {
      komponenErrors[k] = ''.obs;
    }
  }

  void onBrandChanged(String? brand) {
    if (brand != null && brand != selectedBrand.value) {
      selectedBrand.value = brand;
      selectedModel.value = ''; // Reset model saat merek berubah
      brandError.value = '';
      modelError.value = '';
    }
  }

  void onModelChanged(String? model) {
    if (model != null) {
      selectedModel.value = model;
      modelError.value = '';
    }
  }

  void onYearChanged(String? year) {
    if (year != null) {
      selectedYear.value = year;
      yearError.value = '';
    }
  }

  // ================= UPLOAD GAMBAR KENDARAAN =================
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
      imageError.value = ''; // Reset error gambar saat user memilih file
      update();

      isUploading.value = true;
      final result = await uploadImage(selectedVehicleImage!);
      if (result != null) {
        vehicleImageUrl.value = result["url"] ?? '';
        vehicleImagePublicId.value = result["public_id"] ?? '';
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        Get.snackbar("Error", "Gagal mengunggah gambar");
      }
    } finally {
      isUploading.value = false;
      update();
    }
  }

  // ================= LOGIKA VALIDASI PER STEP =================
  bool validateStep1() {
    bool isValid = true;

    // 1. Merek
    if (selectedBrand.value.isEmpty) {
      brandError.value = "Merek kendaraan wajib dipilih";
      isValid = false;
    } else {
      brandError.value = "";
    }

    // 2. Model
    if (selectedModel.value.isEmpty) {
      modelError.value = "Model kendaraan wajib dipilih";
      isValid = false;
    } else {
      modelError.value = "";
    }

    // 3. Tahun
    if (selectedYear.value.isEmpty) {
      yearError.value = "Tahun produksi wajib dipilih";
      isValid = false;
    } else {
      yearError.value = "";
    }

    // 4. Plat Nomor
    final plate = platController.text.trim();
    if (plate.isEmpty) {
      platError.value = "Plat nomor tidak boleh kosong";
      isValid = false;
    } else {
      final plateRegex = RegExp(r'^[A-Z]{1,2}\s?[0-9]{1,4}\s?[A-Z]{1,3}$');
      if (!plateRegex.hasMatch(plate.toUpperCase())) {
        platError.value = "Format plat nomor tidak valid (contoh: A 1234 BC)";
        isValid = false;
      } else {
        platError.value = "";
      }
    }

    // 5. Gambar Kendaraan
    if (selectedVehicleImage == null && vehicleImageUrl.value.isEmpty) {
      imageError.value = "Gambar kendaraan wajib diunggah";
      isValid = false;
    } else {
      imageError.value = "";
    }

    return isValid;
  }

  bool validateStep2() {
    bool isValid = true;

    // 1. Estimasi Harian
    final estimasiText = estimasiHarianController.text.trim();
    if (estimasiText.isEmpty) {
      estimasiError.value = "Estimasi penggunaan harian tidak boleh kosong";
      isValid = false;
    } else {
      final dailyKm = int.tryParse(estimasiText);
      if (dailyKm == null || dailyKm <= 0) {
        estimasiError.value = "Estimasi harus berupa angka lebih dari 0";
        isValid = false;
      } else {
        estimasiError.value = "";
      }
    }

    // 2. Angka Odometer
    final odoText = odometerController.text.trim();
    if (odoText.isEmpty) {
      odometerError.value = "Odometer tidak boleh kosong";
      isValid = false;
    } else {
      final odo = int.tryParse(odoText);
      if (odo == null || odo < 0) {
        odometerError.value = "Angka odometer harus berupa angka valid";
        isValid = false;
      } else {
        odometerError.value = "";
      }
    }

    return isValid;
  }

  bool validateStep3() {
    bool isValid = true;

    for (var k in komponen) {
      final text = komponenControllers[k]?.text.trim() ?? '';
      if (text.isEmpty) {
        komponenErrors[k]?.value = "$k tidak boleh kosong";
        isValid = false;
      } else {
        final val = int.tryParse(text);
        if (val == null || val < 0) {
          komponenErrors[k]?.value = "$k harus berupa angka valid";
          isValid = false;
        } else {
          komponenErrors[k]?.value = "";
        }
      }
    }

    return isValid;
  }

  // ================= NAVIGASI WIZARD =================
  void nextStep() {
    // Validasi Step 1
    if (step.value == 1) {
      if (!validateStep1()) return;
      step.value = 2;
      return;
    }

    // Validasi Step 2
    if (step.value == 2) {
      if (!validateStep2()) return;
      step.value = 3;
      return;
    }

    // Step 3: Simpan
    if (step.value == 3) {
      if (!validateStep3()) return;
      saveVehicle();
    }
  }

  void prevStep() {
    if (step.value > 1) {
      step.value--;
    }
  }

  // ================= LOGIKA BACK BUTTON & KONFIRMASI PEMBATALAN =================
  Future<bool> handleBackPress() async {
    if (step.value > 1) {
      prevStep();
      return false; // Jangan tutup halaman, kembali ke step sebelumnya
    }

    // Step 1: Munculkan AlertDialog konfirmasi pembatalan
    final shouldExit = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Konfirmasi",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: const Text(
          "Apakah anda ingin membatalkan menambah kendaraan?",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(result: false),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text("Tidak", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(result: true);
              if (isFromLogin.value) {
                // Pertama kali daftar akun / login pertama: kembali ke login
                Get.offAllNamed('/login');
              } else {
                // Sedang login / diakses dari Home atau Page Kendaraan: kembali ke page kendaraan
                if (Navigator.of(Get.context!).canPop()) {
                  Get.back();
                } else {
                  Get.offAllNamed('/mainscreen', arguments: 1);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text("Ya", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  // ================= SIMPAN KENDARAAN (SUBMIT DATA) =================
  Future<void> saveVehicle() async {
    if (!validateStep3()) return;

    try {
      isLoading.value = true;
      final token = box.read("token");
      final currentOdo = int.tryParse(odometerController.text.trim()) ?? 0;

      final components = komponen.map((item) {
        return {
          "component_id": componentIds[item],
          "last_replaced_date": DateTime.now().toIso8601String(),
          "last_replaced_odometer": currentOdo,
          "service_days":
              int.tryParse(komponenControllers[item]!.text.trim()) ?? 0,
        };
      }).toList();

      final body = {
        "brand": selectedBrand.value,
        "model": selectedModel.value,
        "year": int.tryParse(selectedYear.value) ?? 0,
        "plate_number": platController.text.trim(),
        "vehicle_image": vehicleImageUrl.value,
        "odometer_image": "", // OCR dibypass, gambar odometer kosong
        "estimated_km_per_day":
            int.tryParse(estimasiHarianController.text.trim()) ?? 0,
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

        if (Get.isRegistered<HomeController>()) {
          final homeC = Get.find<HomeController>();
          homeC.vehicleId = data["vehicle"]["id"].toString();
          homeC.getVehicles();
          homeC.fetchHome(force: true);
        }

        if (Get.isRegistered<KendaraanController>()) {
          Get.find<KendaraanController>().getVehicles(force: true);
        }

        AppSnackbar.success("Kendaraan berhasil ditambahkan.");

        if (isFromLogin.value) {
          Get.offNamed('/mainscreen');
        } else {
          Get.offNamed('/mainscreen', arguments: 1);
        }
      } else {
        Get.snackbar("Error", data['message'] ?? "Terjadi kesalahan");
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        Get.snackbar("Error", "Gagal menambahkan kendaraan");
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    platController.dispose();
    estimasiHarianController.dispose();
    odometerController.dispose();
    for (var c in komponenControllers.values) {
      c.dispose();
    }
    super.onClose();
  }
}
