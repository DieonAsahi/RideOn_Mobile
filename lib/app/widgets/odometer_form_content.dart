import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../modules/Feature/home/controllers/home_controller.dart';
import 'app_snackbar.dart';
import 'form_label_with_tooltip.dart';

class OdometerFormContent extends StatefulWidget {
  final int currentOdometer;
  final String? lastOdometerUpdate;
  final String namaMotor;
  final String platNomor;

  const OdometerFormContent({
    super.key,
    required this.currentOdometer,
    this.lastOdometerUpdate,
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

  String _formatOdometer(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
  }

  Widget? _buildLastUpdatedInfo() {
    final updatedAt = DateTime.tryParse(
      widget.lastOdometerUpdate ?? '',
    )?.toLocal();
    if (updatedAt == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final updateDate = DateTime(updatedAt.year, updatedAt.month, updatedAt.day);
    final daysAgo = today.difference(updateDate).inDays;
    final relativeDate = daysAgo <= 0 ? 'hari ini' : '$daysAgo hari lalu';

    return Text.rich(
      TextSpan(
        style: const TextStyle(fontSize: 12, color: Colors.black87),
        children: [
          const TextSpan(text: 'Terakhir diperbaharui '),
          TextSpan(text: relativeDate),
          const TextSpan(text: '  '),
          TextSpan(
            text: '${_formatOdometer(widget.currentOdometer)} Km',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

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
    if (_isLoading) return;

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
    if (_newOdometer! > 999999) {
      setState(() => _odometerError = 'Odometer maksimal 999.999 km.');
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
    final lastUpdatedInfo = _buildLastUpdatedInfo();

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
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
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
        const SizedBox(height: 8),
        if (_newOdometer != null && _newOdometer! > widget.currentOdometer)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/image/grafik.png',
                width: 16,
                height: 16,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 4),
              Text(
                'Bertambah ${_formatOdometer(_newOdometer! - widget.currentOdometer)} Km',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        if (lastUpdatedInfo != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: lastUpdatedInfo,
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
