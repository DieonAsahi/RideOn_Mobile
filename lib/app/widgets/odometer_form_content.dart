import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../modules/Feature/home/controllers/home_controller.dart';
import 'app_snackbar.dart';
import 'form_label_with_tooltip.dart';

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
  String? _odometerError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      setState(() {
        _newOdometer = int.tryParse(_controller.text.replaceAll('.', ''));
        _odometerError = null;
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
      setState(() => _odometerError = 'Silakan masukkan angka odometer.');
      return;
    }
    if (_newOdometer! <= widget.currentOdometer) {
      setState(
        () => _odometerError = 'Odometer baru harus lebih besar dari saat ini.',
      );
      return;
    }

    setState(() => _odometerError = null);
    setState(() => _isLoading = true);
    final homeController = Get.find<HomeController>();
    final success = await homeController.updateOdometerManual(_newOdometer!);

    if (mounted) setState(() => _isLoading = false);
    if (success) {
      Get.back(result: true);
      AppSnackbar.success('Odometer berhasil diperbarui.');
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
        const FormLabelWithTooltip(
          label: 'Odometer baru',
          message:
              'Masukkan hanya angka kilometer yang lebih besar dari odometer saat ini.',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: widget.currentOdometer.toString(),
            suffixText: 'Km',
            errorText: _odometerError,
            errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
            errorMaxLines: 3,
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
