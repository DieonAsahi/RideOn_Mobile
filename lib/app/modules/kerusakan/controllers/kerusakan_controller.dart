import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class KerusakanController extends GetxController {
  var step = 1.obs;

  var isLoading = false.obs;

  RxList<String> selectedGejala = <String>[].obs;

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
    if (selectedGejala.isEmpty) {
      Get.snackbar(
        "Peringatan",
        "Pilih minimal satu gejala",
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse(
          "https://hireable-unelegant-linwood.ngrok-free.dev/api/kerusakan/diagnose",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "gejalaUser": selectedGejala,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        Get.toNamed(
          "/kerusakanhasil",
          arguments: data["data"],
        );
      } else {
        Get.snackbar(
          "Error",
          "Gagal melakukan diagnosa",
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }
}