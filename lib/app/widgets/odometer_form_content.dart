import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../modules/Feature/home/controllers/home_controller.dart';

class OdometerFormContent extends StatefulWidget {
  final int currentOdometer;
  final String namaMotor;
  final String platNomor;

  const OdometerFormContent({
    super.key,
    required this.currentOdometer,
    required this.namaMotor,
    required this.platNomor,
  });

  @override
  State<OdometerFormContent> createState() => _OdometerFormContentState();
}

class _OdometerFormContentState extends State<OdometerFormContent> {
  late final TextEditingController _controller;
  int? _newOdometer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      setState(() {
        _newOdometer = int.tryParse(_controller.text.replaceAll('.', ''));
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (_newOdometer == null) {
      Get.snackbar("Perhatian", "Silakan masukkan angka odometer");
      return;
    }
    if (_newOdometer! <= widget.currentOdometer) {
      Get.snackbar(
        "Gagal",
        "Odometer baru harus lebih besar dari saat ini",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);
    final homeController = Get.find<HomeController>();
    final success = await homeController.updateOdometerManual(_newOdometer!);

    if (mounted) setState(() => _isLoading = false);
    if (success) {
      Get.back(result: true);
      Get.snackbar(
        "Berhasil",
        "Odometer berhasil diperbarui",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        "Error",
        "Gagal memperbarui odometer",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.namaMotor} - ${widget.platNomor}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Odometer saat ini',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
          decoration: InputDecoration(
            hintText: widget.currentOdometer.toString(),
            suffixText: 'Km',
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        if (_newOdometer != null && _newOdometer! > widget.currentOdometer)
          Text(
            '📈 Bertambah ${_newOdometer! - widget.currentOdometer} Km',
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleUpdate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Perbaharui',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }
}
