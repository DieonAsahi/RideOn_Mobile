import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';

import '../../../widgets/base_bottom_sheet.dart';
import '../../../widgets/odometer_form_content.dart';
import '../../../widgets/skeleton_widget.dart';
import '../controllers/dtlperforma_controller.dart';

class DtlperformaView extends GetView<DtlperformaController> {
  const DtlperformaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFAFBFC,
      ), // Warna background lebih soft sesuai desain
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: Get.back,
                    child: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const Expanded(
                    child: Text(
                      'Detail Kendaraan', // Sesuai desain
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20), // Placeholder agar text center
                ],
              ),
            ),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: DtlperformaSkeleton(),
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchPerformanceHistory,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildVehicleProfile(),
                        const SizedBox(height: 24),
                        _buildPerformanceCard(),
                        const SizedBox(height: 16),
                        _buildVehicleInformation(context),
                        const SizedBox(height: 24),
                        _buildFilterTabs(),
                        const SizedBox(height: 16),
                        _buildPerformanceChart(),
                        const SizedBox(height: 24),
                        _buildLatestService(),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Profil Kendaraan (Tengah)
  Widget _buildVehicleProfile() {
    final imageUrl = controller.vehicle['vehicle_image']?.toString() ?? '';
    final brand = controller.vehicle['brand']?.toString() ?? '';
    final model = controller.vehicle['model']?.toString() ?? '';
    final plate =
        controller.vehicle['plate_number']?.toString() ??
        'Nomor polisi belum tersedia';

    return Column(
      children: [
        Center(
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _vehiclePlaceholder(),
                )
              : _vehiclePlaceholder(),
        ),
        const SizedBox(height: 12),
        Text(
          '$brand $model'.trim(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          plate,
          style: const TextStyle(color: Color(0xFF8A9099), fontSize: 14),
        ),
      ],
    );
  }

  Widget _vehiclePlaceholder() {
    return const Icon(
      Icons.two_wheeler,
      color: AppColors.primaryBlue,
      size: 100,
    );
  }

  // 2. Card Performa Kondisi
  Widget _buildPerformanceCard() {
    final score = controller.currentScore.value.round().clamp(0, 100);

    final status = controller.performanceStatus;
    final progressColor = controller.scoreColor;

    // Asumsi nilai persentase mingguan disediakan oleh controller dalam bentuk double
    // Jika masih string di controller, tim backend/antigravity perlu mem-parsing-nya menjadi angka
    final double weeklyChange = controller.weeklyChangeValue.value;

    // Logika Warna Persentase Mingguan
    Color weeklyColor;
    if (weeklyChange <= -15) {
      weeklyColor = AppColors.red;
    } else if (weeklyChange < 0) {
      // -1 sampai -14
      weeklyColor = AppColors.orange;
    } else {
      // 0 atau plus
      weeklyColor = AppColors.green;
    }

    final changeText = weeklyChange > 0
        ? '+${weeklyChange.toInt()}% dari minggu lalu'
        : '${weeklyChange.toInt()}% dari minggu lalu';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: _cardDecoration().copyWith(
        border: Border.all(color: progressColor),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 7,
                  backgroundColor: const Color(0xFFF1F3F5),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
                Center(
                  child: Text(
                    '$score%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kendaraan Anda dalam kondisi',
                  style: TextStyle(color: Color(0xFF5F6368), fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ).copyWith(color: progressColor),
                ),
                const SizedBox(height: 6),
                Text(
                  changeText,
                  style: TextStyle(
                    color: weeklyColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Card Informasi Kendaraan
  Widget _buildVehicleInformation(BuildContext context) {
    final odometer = _formatNumber(controller.vehicle['current_odometer'] ?? 0);
    // Asumsi properti pemakaian harian disiapkan oleh tim backend di controller
    final dailyUsage = controller.vehicle['daily_usage']?.toString() ?? '0 Km';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Informasi Kendaraan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              // Memindahkan tombol perbarui agar lebih bersih di layout baru
              InkWell(
                onTap: () => _showOdometerSheet(context),
                child: const Text(
                  'Perbarui',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _infoItem(
                  'Merk',
                  controller.vehicle['brand']?.toString() ?? '-',
                ),
              ),
              Expanded(
                child: _infoItem(
                  'Model',
                  controller.vehicle['model']?.toString() ?? '-',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _infoItem(
                  'Tahun',
                  controller.vehicle['year']?.toString() ?? '-',
                ),
              ),
              Expanded(
                child: _infoItem(
                  'Pemakaian Harian',
                  dailyUsage,
                ), // Ditambahkan dari request
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [Expanded(child: _infoItem('Odometer', '$odometer Km'))],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8A9099), fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Future<void> _showOdometerSheet(BuildContext context) async {
    final name =
        '${controller.vehicle['brand'] ?? ''} ${controller.vehicle['model'] ?? ''}'
            .trim();
    final result = await BaseBottomSheet.show<bool>(
      context: context,
      title: 'Perbaharui Odometer',
      child: OdometerFormContent(
        currentOdometer:
            int.tryParse(controller.vehicle['current_odometer'].toString()) ??
            0,
        namaMotor: name.isEmpty ? 'Kendaraan' : name,
        platNomor: controller.vehicle['plate_number']?.toString() ?? '',
      ),
    );
    if (result == true) await controller.fetchPerformanceHistory();
  }

  // 4. Filter Tabs untuk Chart (Rounded Segmented Control)
  Widget _buildFilterTabs() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: ['Minggu', 'Bulan', 'Tahun'].map((filter) {
          final selected = controller.selectedFilter.value == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.changeFilter(filter),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Text(
                  filter,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF8A9099),
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 5. Chart Performa Kendaraan & Legend
  Widget _buildPerformanceChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performa Kendaraan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 190,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                const left = 34.0;
                const right = 8.0;
                final chartWidth = constraints.maxWidth - left - right;
                final tapX = details.localPosition.dx;
                if (chartWidth <= 0 ||
                    tapX < left ||
                    tapX > left + chartWidth) {
                  return;
                }
                final points = controller.chartPoints;
                if (points.isEmpty) return;
                final selected =
                    (((tapX - left) / chartWidth * (points.length - 1)).round())
                        .clamp(0, points.length - 1);
                controller.selectChartPoint(selected);
              },
              child: Obx(
                () => CustomPaint(
                  painter: _PerformanceChartPainter(
                    points: controller.chartPoints.toList(),
                    selectedIndex: controller.selectedChartPointIndex.value,
                  ),
                  size: Size(constraints.maxWidth, 190),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Legend Score sesuai dengan logika backend yang Anda berikan
        Wrap(
          spacing: 20,
          runSpacing: 10,
          children: [
            _legend(AppColors.green, '75-100% Baik'),
            _legend(AppColors.orange, '50-74% Perlu perhatian'),
            _legend(AppColors.red, '<50% Buruk'),
          ],
        ),
      ],
    );
  }

  Widget _legend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xFF5F6368)),
        ),
      ],
    );
  }

  // 6. Servis Terakhir
  Widget _buildLatestService() {
    final service = controller.latestService.value;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Servis Terakhir',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              InkWell(
                onTap: () => Get.toNamed('/rwtservis'),
                child: const Text(
                  'Lihat riwayat',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (service == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Belum ada riwayat servis',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            )
          else
            _serviceDetails(service),
        ],
      ),
    );
  }

  Widget _serviceDetails(Map<String, dynamic> service) {
    final component = service['master_components'] is Map
        ? Map<String, dynamic>.from(service['master_components'] as Map)
        : <String, dynamic>{};

    // Konversi Tanggal (Format: 15 Oktober 2026)
    final date = DateTime.tryParse(service['service_date']?.toString() ?? '');
    final dateText = date == null
        ? '-'
        : '${date.day} ${_getMonthName(date.month)} ${date.year}';

    final title =
        component['name']?.toString() ??
        service['service_type']?.toString() ??
        service['title']?.toString() ??
        'Servis kendaraan';
    final workshop = service['workshop_name']?.toString() ?? '-';
    // Format Harga
    final priceStr = service['price']?.toString() ?? '0';
    final price = 'Rp. ${_formatNumber(priceStr)}';

    final iconName = component['icon']?.toString();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: iconName == null || iconName.isEmpty
              ? const Icon(Icons.build_outlined, color: Color(0xFF8A9099))
              : Image.asset(
                  'assets/icons/$iconName.png',
                  width: 30,
                  height: 30,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.build_outlined,
                    color: Color(0xFF8A9099),
                  ),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateText,
                style: const TextStyle(color: Color(0xFF8A9099), fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                workshop,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF5F6368)),
              ),
            ],
          ),
        ),
        // Harga di sebelah Kanan
        Text(
          price,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0A000000), // Shadow sangat tipis sesuai desain
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );

  String _formatNumber(dynamic value) {
    final number = int.tryParse(value.toString()) ?? 0;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month];
  }
}

// CustomPainter untuk Grafik
class _PerformanceChartPainter extends CustomPainter {
  _PerformanceChartPainter({required this.points, required this.selectedIndex});

  final List<PerformancePoint> points;
  final int selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    const left = 34.0;
    const right = 8.0;
    const top = 12.0;
    const bottom = 34.0;
    final chartHeight = size.height - top - bottom;
    final chartWidth = size.width - left - right;

    final gridPaint = Paint()
      ..color = const Color(0xFFF1F3F5)
      ..strokeWidth = 1;
    final axisTextStyle = const TextStyle(
      color: Color(0xFF8A9099),
      fontSize: 10,
    );

    for (final value in [100, 80, 60, 40, 20, 0]) {
      final y = top + (100 - value) / 100 * chartHeight;
      // Dot dash pattern can be handled here, but solid line is fine as per baseline
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
      _drawText(canvas, '$value%', Offset(0, y - 6), axisTextStyle);
    }

    final pointsOnChart = <Offset?>[];
    for (var index = 0; index < points.length; index++) {
      final score = points[index].score;
      if (score == null) {
        pointsOnChart.add(null);
        continue;
      }
      final x = points.length == 1
          ? left + chartWidth / 2
          : left + chartWidth * index / (points.length - 1);
      final y = top + (100 - score.clamp(0, 100)) / 100 * chartHeight;
      pointsOnChart.add(Offset(x, y));
    }

    final area = Path();
    var segment = <Offset>[];
    final segments = <List<Offset>>[];
    for (final point in pointsOnChart) {
      if (point == null) {
        if (segment.isNotEmpty) segments.add(segment);
        segment = [];
      } else {
        segment.add(point);
      }
    }
    if (segment.isNotEmpty) segments.add(segment);

    final linePaint = Paint()
      ..color = AppColors.primaryBlue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final linePoints in segments) {
      if (linePoints.isEmpty) continue;
      final path = Path()..moveTo(linePoints.first.dx, linePoints.first.dy);
      // Gunakan garis lurus biasa sesuai gambar mockup (grafik.png lebih ke garis lurus / linear antar node)
      for (var index = 1; index < linePoints.length; index++) {
        final current = linePoints[index];
        path.lineTo(current.dx, current.dy);
      }

      area
        ..moveTo(linePoints.first.dx, size.height - bottom)
        ..lineTo(linePoints.first.dx, linePoints.first.dy);
      for (var index = 1; index < linePoints.length; index++) {
        final current = linePoints[index];
        area.lineTo(current.dx, current.dy);
      }
      area
        ..lineTo(linePoints.last.dx, size.height - bottom)
        ..close();

      canvas.drawPath(
        area,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x442196F3), Color(0x002196F3)],
          ).createShader(Rect.fromLTWH(left, top, chartWidth, chartHeight)),
      );
      area.reset();

      // Draw Line
      canvas.drawPath(path, linePaint);

      // Draw Points
      for (final point in linePoints) {
        canvas.drawCircle(point, 4, Paint()..color = AppColors.primaryBlue);
        canvas.drawCircle(point, 2, Paint()..color = Colors.white);
      }
    }

    if (selectedIndex >= 0 &&
        selectedIndex < points.length &&
        points[selectedIndex].score != null) {
      final selectedPoint = pointsOnChart[selectedIndex]!;
      final score = points[selectedIndex].score!.round();

      // Menggambar Badge gelap sesuai desain (cth: 87%)
      final badgeRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(
            selectedPoint.dx,
            (selectedPoint.dy - 20).clamp(8, size.height - bottom - 10),
          ),
          width: 36,
          height: 22,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(badgeRect, Paint()..color = const Color(0xFF2D3748));
      _drawCenteredText(
        canvas,
        '$score%',
        badgeRect.outerRect.center,
        const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      );

      // Menggambar point khusus paling ujung yang lebih besar & beda warna (sesuai statusnya)
      Color dotColor = AppColors.green;
      if (score < 50) {
        dotColor = AppColors.red;
      } else if (score < 75) {
        dotColor = AppColors.orange;
      }

      canvas.drawCircle(selectedPoint, 6, Paint()..color = dotColor);
      canvas.drawCircle(
        selectedPoint,
        3,
        Paint()..color = AppColors.primaryBlue,
      );
    }

    // Draw X-Axis Labels (Sen, Sel, dll yang akan dikirimkan oleh point.label dari controller)
    for (var index = 0; index < points.length; index++) {
      final x = points.length == 1
          ? left + chartWidth / 2
          : left + chartWidth * index / (points.length - 1);
      _drawCenteredText(
        canvas,
        points[index].label,
        Offset(x, size.height - 15),
        const TextStyle(color: Color(0xFF8A9099), fontSize: 10),
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  void _drawCenteredText(
    Canvas canvas,
    String text,
    Offset center,
    TextStyle style,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _PerformanceChartPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.selectedIndex != selectedIndex;
}
