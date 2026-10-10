import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../modules/Feature/home/controllers/home_controller.dart';
import '../services/firebase_messaging_service.dart';

class InAppPushNotification {
  final String id;
  final String title;
  final String body;
  final String vehicleName;
  final String vehicleId;
  final int? componentId;
  final DateTime timestamp;

  InAppPushNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.vehicleName,
    required this.vehicleId,
    this.componentId,
    required this.timestamp,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} m';
    if (diff.inHours < 24) return '${diff.inHours} j';
    return '${diff.inDays} h';
  }
}

class InAppNotificationBanner {
  static final List<InAppPushNotification> _notifications = [];
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;
  static bool _isExpanded = false;
  static void Function(void Function())? _stateSetter;

  /// Tampilkan notifikasi in-app dari RemoteMessage Firebase
  static void show(RemoteMessage message) {
    final title =
        message.data['title'] ?? message.notification?.title ?? 'RideOn';
    final body = message.data['body'] ?? message.notification?.body ?? '';
    final vehicleId = message.data['vehicle_id']?.toString() ?? '';
    final notificationId =
        message.data['notification_id']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final componentId = int.tryParse(
      message.data['component_id']?.toString() ?? '',
    );

    // Ambil nama kendaraan dari payload atau fallback ke controller lokal
    String vehicleName = message.data['vehicle_name']?.toString() ?? '';
    if (vehicleName.trim().isEmpty) {
      if (Get.isRegistered<HomeController>()) {
        final homeC = Get.find<HomeController>();
        if (homeC.vehicles.isNotEmpty) {
          final found = homeC.vehicles.firstWhereOrNull(
            (v) => v['id']?.toString() == vehicleId,
          );
          if (found != null) {
            vehicleName =
                "${found['brand'] ?? ''} ${found['model'] ?? ''}".trim();
          } else {
            final first = homeC.vehicles.first;
            vehicleName =
                "${first['brand'] ?? ''} ${first['model'] ?? ''}".trim();
          }
        }
      }
    }
    if (vehicleName.trim().isEmpty) {
      vehicleName = "Honda Vario 125";
    }

    showNotification(
      id: notificationId,
      title: title,
      body: body,
      vehicleName: vehicleName,
      vehicleId: vehicleId,
      componentId: componentId,
    );
  }

  /// Tampilkan notifikasi dengan data langsung
  static void showNotification({
    required String id,
    required String title,
    required String body,
    required String vehicleName,
    String vehicleId = '',
    int? componentId,
  }) {
    final newItem = InAppPushNotification(
      id: id,
      title: title,
      body: body,
      vehicleName: vehicleName,
      vehicleId: vehicleId,
      componentId: componentId,
      timestamp: DateTime.now(),
    );

    final existingIndex = _notifications.indexWhere((n) => n.id == id);
    if (existingIndex >= 0) {
      _notifications[existingIndex] = newItem;
    } else {
      _notifications.insert(0, newItem);
    }

    if (_currentEntry == null) {
      _isExpanded = false;
      _insertOverlay();
    } else {
      _stateSetter?.call(() {});
    }

    _resetAutoDismiss();
  }

  static void _insertOverlay() {
    final overlay = Get.overlayContext != null
        ? Overlay.maybeOf(Get.overlayContext!)
        : (Get.key.currentState?.overlay);

    if (overlay == null) return;

    _currentEntry = OverlayEntry(
      builder: (context) => _BannerOverlayWidget(
        onDismiss: dismiss,
        onRegisterStateSetter: (setter) {
          _stateSetter = setter;
        },
      ),
    );

    overlay.insert(_currentEntry!);
  }

  static void _resetAutoDismiss() {
    _dismissTimer?.cancel();
    // Jika tidak sedang di-expand, banner otomatis hilang setelah 7 detik
    if (!_isExpanded) {
      _dismissTimer = Timer(const Duration(seconds: 7), () {
        dismiss();
      });
    }
  }

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _isExpanded = false;
    _stateSetter = null;
    _notifications.clear();
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _BannerOverlayWidget extends StatefulWidget {
  final VoidCallback onDismiss;
  final void Function(void Function(void Function())) onRegisterStateSetter;

  const _BannerOverlayWidget({
    required this.onDismiss,
    required this.onRegisterStateSetter,
  });

  @override
  State<_BannerOverlayWidget> createState() => _BannerOverlayWidgetState();
}

class _BannerOverlayWidgetState extends State<_BannerOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    widget.onRegisterStateSetter(setState);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleDismiss() async {
    await _animController.reverse();
    widget.onDismiss();
  }

  void _onToggleExpand() {
    setState(() {
      InAppNotificationBanner._isExpanded =
          !InAppNotificationBanner._isExpanded;
    });
    InAppNotificationBanner._resetAutoDismiss();
  }

  void _onSchedule(InAppPushNotification item) {
    _handleDismiss();

    // Mark as read jika ada id
    if (item.id.isNotEmpty) {
      FirebaseMessagingService.markNotificationRead(item.id);
    }

    if (item.vehicleId.isNotEmpty) {
      GetStorage().write('vehicle_id', item.vehicleId);
    }

    // Navigasi ke halaman Tambah Riwayat dengan mode 'jadwalkan'
    Get.toNamed(
      '/rwttambah',
      arguments: {
        'jadwalkan': true,
        'component_id': item.componentId,
        'vehicle_id': item.vehicleId,
      },
    )?.then((_) {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().syncVehicleFromStorage();
      }
    });
  }

  void _onOpenNotification(InAppPushNotification item) {
    _handleDismiss();

    if (item.vehicleId.isNotEmpty) {
      GetStorage().write('vehicle_id', item.vehicleId);
    }
    if (item.id.isNotEmpty) {
      FirebaseMessagingService.markNotificationRead(item.id);
    }

    Get.toNamed('/notif');
  }

  @override
  Widget build(BuildContext context) {
    final notifications = InAppNotificationBanner._notifications;
    if (notifications.isEmpty) return const SizedBox.shrink();

    final isExpanded = InAppNotificationBanner._isExpanded;
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                // Swipe ke atas untuk dismiss
                if (details.primaryDelta != null && details.primaryDelta! < -8) {
                  _handleDismiss();
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label Header: "Notifikasi" persis seperti di desain
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 6),
                    child: Text(
                      "Notifikasi",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF9E9E9E),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  // Kartu Notifikasi Utama (Dark Charcoal, rounded 24)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: isExpanded
                        ? _buildExpandedContent(notifications)
                        : _buildCollapsedContent(notifications),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Desain Bagian Atas (Collapsed):
  /// Logo | Title (bold)  VehicleName  Time | [v] jika notif > 1
  ///        Body
  Widget _buildCollapsedContent(List<InAppPushNotification> notifications) {
    final first = notifications.first;
    final hasMultiple = notifications.length > 1;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onOpenNotification(first),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo RideOn App
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/logo/RideOn_app.png',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),

          // Teks Notifikasi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Baris Atas: Title (Bold) + VehicleName + Time
                Row(
                  children: [
                    Text(
                      first.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        first.vehicleName,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFB0B0B0),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      first.timeAgo,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF8E8E93),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Baris Bawah: Body Pesan
                Text(
                  first.body,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFD1D1D6),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Icon Down (V) hanya jika notifikasi lebih dari 1
          if (hasMultiple) ...[
            const SizedBox(width: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _onToggleExpand,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  'assets/icons/down.png',
                  width: 14,
                  height: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Desain Bagian Bawah (Expanded):
  /// Logo | RideOn  VehicleName  Time | [^]
  ///        Title (bold)
  ///        Body
  ///        [Jadwalkan]
  Widget _buildExpandedContent(List<InAppPushNotification> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < notifications.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          _buildExpandedItem(
            item: notifications[i],
            isFirst: i == 0,
          ),
        ],
      ],
    );
  }

  Widget _buildExpandedItem({
    required InAppPushNotification item,
    required bool isFirst,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo RideOn App
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            'assets/logo/RideOn_app.png',
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 14),

        // Detail Notifikasi
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Baris Header: RideOn + VehicleName + Time + Icon Up (^)
              Row(
                children: [
                  Text(
                    "RideOn",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFB0B0B0),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      item.vehicleName,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFB0B0B0),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.timeAgo,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF8E8E93),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),

                  // Icon Up (^) hanya ditampilkan di baris paling atas
                  if (isFirst)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _onToggleExpand,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                          'assets/icons/up.png',
                          width: 14,
                          height: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),

              // Title Komponen (Bold)
              Text(
                item.title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),

              // Body Pesan
              Text(
                item.body,
                style: GoogleFonts.poppins(
                  color: const Color(0xFFD1D1D6),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),

              // Tombol "Jadwalkan" Pill
              GestureDetector(
                onTap: () => _onSchedule(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF424242),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Jadwalkan",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
