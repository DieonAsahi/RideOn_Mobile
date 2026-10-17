import 'package:get/get.dart';

class KerusakanhasilController extends GetxController {
  late Map<String, dynamic> hasil;

  @override
  void onInit() {
    super.onInit();
    hasil = Get.arguments ?? {};
  }

  // Getter untuk memformat daftar solusi/rekomendasi
  List<String> get solusiList {
    var rawSolusi = hasil["solusi"];
    if (rawSolusi == null) return [];
    if (rawSolusi is List) {
      return rawSolusi.map((e) => e.toString()).toList();
    }
    if (rawSolusi is String) {
      return rawSolusi.split('\n').where((s) => s.trim().isNotEmpty).toList();
    }
    return [rawSolusi.toString()];
  }

  void jadwalkanServis() {
    Get.toNamed('/rwttambah', arguments: {'jenis': 'Perbaikan'});
  }
}
