import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:capbatu/app/services/connectivity_service.dart';
import 'package:capbatu/app/widgets/app_feedback_widgets.dart';

class KerusakanController extends GetxController {
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  // Total steps diperbarui menjadi 4 sesuai desain terbaru
  var step = 1.obs;
  var isLoading = false.obs;

  // State untuk menyimpan gejala yang dipilih (Multi-select)
  RxList<String> selectedGejala = <String>[].obs;

  // State khusus untuk Step 4 (Single-select per kategori)
  var intensitas = ''.obs;
  var kondisiJalan = ''.obs;

  void toggleGejala(String kode) {
    if (selectedGejala.contains(kode)) {
      selectedGejala.remove(kode);
    } else {
      selectedGejala.add(kode);
    }
  }

  bool isSelected(String kode) {
    return selectedGejala.contains(kode);
  }

  void nextStep() {
    if (step.value < 4) {
      step.value++;
    } else {
      prosesDiagnosa();
    }
  }

  void prevStep() {
    if (step.value > 1) {
      step.value--;
    } else {
      Get.back();
    }
  }

  Future<void> prosesDiagnosa() async {
    // Gabungkan semua input yang dipilih
    List<String> finalGejala = List.from(selectedGejala);
    if (intensitas.value.isNotEmpty) finalGejala.add(intensitas.value);
    if (kondisiJalan.value.isNotEmpty) finalGejala.add(kondisiJalan.value);

    if (finalGejala.isEmpty) {
      AppFeedback.inputRequired(
        message: 'Pilih minimal satu gejala atau kondisi.',
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse("$baseUrl/api/kerusakan/diagnose"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"gejalaUser": finalGejala}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        Get.toNamed("/kerusakanhasil", arguments: data["data"]);
      } else {
        AppFeedback.diagnosisFailed(
          message:
              data['message'] ?? data['error'] ?? 'Gagal melakukan diagnosa.',
        );
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        AppFeedback.diagnosisFailed(
          message: 'Gagal melakukan diagnosa, periksa koneksi Anda.',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
