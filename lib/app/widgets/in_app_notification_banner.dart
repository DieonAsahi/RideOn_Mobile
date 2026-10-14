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
  final String vehiclePlate;
  final String vehicleId;
  final int? componentId;
  final String componentName;
  final String category; // 'component' atau 'status'
  final String status; // 'Dijadwalkan', 'Dibatalkan', 'Selesai', 'Diproses', dll.
  final DateTime timestamp;

  InAppPushNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.vehicleName,
    this.vehiclePlate = '',
    required this.vehicleId,
    this.componentId,
    required this.componentName,
    required this.category,
    required this.status,
    required this.timestamp,
  });

  String get vehicleWithPlate {
    final cleanPlate =
        vehiclePlate.replaceAll('[', '').replaceAll(']', '').trim();
    if (cleanPlate.isNotEmpty) {
      return "$vehicleName [$cleanPlate]";
    }
    return vehicleName;
  }

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} m';
    if (diff.inHours < 24) return '${diff.inHours} j';
    return '${diff.inDays} h';
  }
}

abstract class BannerGroupItem {
  String get key;
  DateTime get latestTimestamp;
}

class VehicleComponentGroup extends BannerGroupItem {
  final String vehicleId;
  final String vehicleName;
  final String vehiclePlate;
  final List<InAppPushNotification> items;

  VehicleComponentGroup({
    required this.vehicleId,
    required this.vehicleName,
    this.vehiclePlate = '',
    required this.items,
  });

  String get vehicleWithPlate {
    String plate = vehiclePlate;
    if (plate.isEmpty) {
      final found = items.firstWhereOrNull((it) => it.vehiclePlate.isNotEmpty);
      if (found != null) plate = found.vehiclePlate;
    }
    final cleanPlate =
        plate.replaceAll('[', '').replaceAll(']', '').trim();
    if (cleanPlate.isNotEmpty) {
      return "$vehicleName [$cleanPlate]";
    }
    return vehicleName;
  }

  @override
  String get key => 'vehicle_${vehicleId.isNotEmpty ? vehicleId : vehicleName}';

  @override
  DateTime get latestTimestamp =>
      items.isNotEmpty ? items.first.timestamp : DateTime.now();
}

class StatusGroup extends BannerGroupItem {
  final InAppPushNotification item;

  StatusGroup({required this.item});

  @override
  String get key => 'status_${item.id}';

  @override
  DateTime get latestTimestamp => item.timestamp;
}

class InAppNotificationBanner {
  static final List<InAppPushNotification> _notifications = [];
  static final Set<String> _expandedGroupKeys = {};
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;
  static void Function(void Function())? _stateSetter;

  static List<BannerGroupItem> get groupedBannerItems {
    final Map<String, VehicleComponentGroup> compGroups = {};
    final List<BannerGroupItem> allGroups = [];

    for (final notif in _notifications) {
      if (notif.category == 'component') {
        final key =
            'vehicle_${notif.vehicleId.isNotEmpty ? notif.vehicleId : notif.vehicleName}';
        if (!compGroups.containsKey(key)) {
          final g = VehicleComponentGroup(
            vehicleId: notif.vehicleId,
            vehicleName: notif.vehicleName,
            vehiclePlate: notif.vehiclePlate,
            items: [],
          );
          compGroups[key] = g;
          allGroups.add(g);
        }
        compGroups[key]!.items.add(notif);
      } else {
        allGroups.add(StatusGroup(item: notif));
      }
    }

    allGroups.sort((a, b) => b.latestTimestamp.compareTo(a.latestTimestamp));
    return allGroups;
  }

  /// Tampilkan notifikasi in-app dari RemoteMessage Firebase
  static void show(RemoteMessage message) {
    final rawTitle =
        message.data['title'] ?? message.notification?.title ?? 'RideOn';
    final body = message.data['body'] ?? message.notification?.body ?? '';
    final vehicleId = message.data['vehicle_id']?.toString() ?? '';
    final notificationId =
        message.data['notification_id']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final componentId = int.tryParse(
      message.data['component_id']?.toString() ?? '',
    );

    final type = message.data['type']?.toString();
    final rawCategory = message.data['category']?.toString();

    // Sesuai aturan: Status servis berdiri sendiri, sedangkan reminder dan peringatan komponen digrup per kendaraan
    final category = (type == 'service_update')
        ? 'status'
        : (rawCategory ?? 'component');

    String status = message.data['status']?.toString() ?? '';

    // Ambil nama kendaraan dan plat nomor dari payload atau fallback ke controller lokal
    String vehicleName = message.data['vehicle_name']?.toString() ?? '';
    String vehiclePlate = message.data['vehicle_plate']?.toString() ?? '';

    if (Get.isRegistered<HomeController>()) {
      final homeC = Get.find<HomeController>();
      if (homeC.vehicles.isNotEmpty) {
        final found = homeC.vehicles.firstWhereOrNull(
          (v) => v['id']?.toString() == vehicleId,
        );
        if (found != null) {
          if (vehicleName.trim().isEmpty) {
            vehicleName =
                "${found['brand'] ?? ''} ${found['model'] ?? ''}".trim();
          }
          if (vehiclePlate.trim().isEmpty) {
            vehiclePlate = found['plate_number']?.toString() ?? '';
          }
        } else {
          final first = homeC.vehicles.first;
          if (vehicleName.trim().isEmpty) {
            vehicleName =
                "${first['brand'] ?? ''} ${first['model'] ?? ''}".trim();
          }
          if (vehiclePlate.trim().isEmpty) {
            vehiclePlate = first['plate_number']?.toString() ?? '';
          }
        }
      }
    }
    if (vehicleName.trim().isEmpty) {
      vehicleName = "RideOn";
    }

    String componentName = message.data['component_name']?.toString() ?? '';
    if (componentName.isEmpty && category == 'component') {
      if (vehicleName.isNotEmpty && rawTitle.contains(vehicleName)) {
        componentName = rawTitle.replaceAll(vehicleName, '').trim();
      } else {
        componentName = rawTitle;
      }
    }

    if (status.isEmpty && category == 'status') {
      if (vehicleName.isNotEmpty && rawTitle.contains(vehicleName)) {
        status = rawTitle.replaceAll(vehicleName, '').trim();
      } else {
        status = rawTitle;
      }
    }

    showNotification(
      id: notificationId,
      title: rawTitle,
      body: body,
      vehicleName: vehicleName,
      vehiclePlate: vehiclePlate,
      vehicleId: vehicleId,
      componentId: componentId,
      componentName: componentName,
      category: category,
      status: status,
    );
  }

  /// Tampilkan notifikasi dengan data langsung
  static void showNotification({
    required String id,
    required String title,
    required String body,
    required String vehicleName,
    String vehiclePlate = '',
    String vehicleId = '',
    int? componentId,
    String componentName = '',
    String category = 'component',
    String status = '',
  }) {
    String comp = componentName;
    if (comp.isEmpty && category == 'component') {
      if (vehicleName.isNotEmpty && title.contains(vehicleName)) {
        comp = title.replaceAll(vehicleName, '').trim();
      } else {
        comp = title;
      }
    }

    String st = status;
    if (st.isEmpty && category == 'status') {
      if (vehicleName.isNotEmpty && title.contains(vehicleName)) {
        st = title.replaceAll(vehicleName, '').trim();
      } else {
        st = title;
      }
    }

    final newItem = InAppPushNotification(
      id: id,
      title: title,
      body: body,
      vehicleName: vehicleName,
      vehiclePlate: vehiclePlate,
      vehicleId: vehicleId,
      componentId: componentId,
      componentName: comp,
      category: category,
      status: st,
      timestamp: DateTime.now(),
    );

    final existingIndex = _notifications.indexWhere((n) => n.id == id);
    if (existingIndex >= 0) {
      _notifications[existingIndex] = newItem;
    } else {
      _notifications.insert(0, newItem);
    }

    if (_currentEntry == null) {
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
    // Jika tidak ada group yang expanded, banner otomatis hilang setelah 7 detik
    if (_expandedGroupKeys.isEmpty) {
      _dismissTimer = Timer(const Duration(seconds: 7), () {
        dismiss();
      });
    }
  }

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _expandedGroupKeys.clear();
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

  void _onToggleGroupExpand(String groupKey) {
    setState(() {
      if (InAppNotificationBanner._expandedGroupKeys.contains(groupKey)) {
        InAppNotificationBanner._expandedGroupKeys.remove(groupKey);
      } else {
        InAppNotificationBanner._expandedGroupKeys.add(groupKey);
      }
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

    if (item.category == 'status') {
      Get.toNamed('/rwtservis');
    } else {
      Get.toNamed('/notif');
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = InAppNotificationBanner.groupedBannerItems;
    if (groups.isEmpty) return const SizedBox.shrink();

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

                  // Daftar Card Banner berdasarkan Group Kendaraan dan Status
                  for (int i = 0; i < groups.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    _buildGroupCard(groups[i]),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(BannerGroupItem group) {
    if (group is VehicleComponentGroup) {
      final isExpanded =
          InAppNotificationBanner._expandedGroupKeys.contains(group.key);
      return AnimatedContainer(
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
            ? _buildExpandedVehicleContent(group)
            : _buildCollapsedVehicleContent(group),
      );
    } else if (group is StatusGroup) {
      return Container(
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
        child: _buildStatusContent(group.item),
      );
    }

    return const SizedBox.shrink();
  }

  /// Desain Bagian Atas (Collapsed):
  /// Logo | [Component] (bold)  [Nama Kendaraan [Plat]] (gray kecil)  [Waktu] | [v]
  ///        [Body]
  Widget _buildCollapsedVehicleContent(VehicleComponentGroup group) {
    // Tampilkan 1 notif yang paling lama (oldest) sesuai instruksi:
    // "ini hanya akan menampilkan 1 notif yang paling lama hanya 1 ingat"
    final oldest = group.items.reduce(
      (a, b) => a.timestamp.isBefore(b.timestamp) ? a : b,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onOpenNotification(oldest),
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
                // Baris Atas: Component (Bold) + VehicleName [Plat] (gray lebih kecil) + Time
                Row(
                  children: [
                    Text(
                      oldest.componentName.isNotEmpty
                          ? oldest.componentName
                          : oldest.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        group.vehicleWithPlate,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF9E9E9E),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      oldest.timeAgo,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF8E8E93),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Baris Bawah: Body Pesan
                Text(
                  oldest.body,
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

          // Icon Down (v) hanya untuk parent group
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _onToggleGroupExpand(group.key),
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
      ),
    );
  }

  /// Desain Bagian Bawah (Expanded):
  /// Header: Logo | RideOn  [Nama Kendaraan [Plat]] (gray kecil)  [Waktu] | [^]
  /// Detail komponen awal dan semua komponen lainnya turun ikut di bawah:
  ///   [Component 1]
  ///   [Body 1]
  ///   [Jadwalkan]
  ///   --- Divider ---
  ///   [Component 2] ...
  Widget _buildExpandedVehicleContent(VehicleComponentGroup group) {
    final oldest = group.items.reduce(
      (a, b) => a.timestamp.isBefore(b.timestamp) ? a : b,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header Baris Atas: Logo + "RideOn" + VehicleName [Plat] + Time + Icon Up (^)
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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

            Expanded(
              child: Row(
                children: [
                  Text(
                    "RideOn",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF9E9E9E),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      group.vehicleWithPlate,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF9E9E9E),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    oldest.timeAgo,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF8E8E93),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Icon Up (^) hanya untuk parent group
            const SizedBox(width: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _onToggleGroupExpand(group.key),
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

        // Daftar detail seluruh komponen kendaraan ini
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.6,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < group.items.length; i++) ...[
                  if (i > 0)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 62,
                        top: 14,
                        bottom: 8,
                      ),
                      child: Container(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  _buildExpandedComponentItem(
                    item: group.items[i],
                    isFirst: i == 0,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedComponentItem({
    required InAppPushNotification item,
    required bool isFirst,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: 62, top: isFirst ? 10 : 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Judul Komponen (Bold)
          Text(
            item.componentName.isNotEmpty ? item.componentName : item.title,
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
    );
  }

  /// Desain Notifikasi Status (Dijadwalkan, Dibatalkan, Selesai, dll):
  /// Terpisah dan mandiri tanpa up/down accordion
  Widget _buildStatusContent(InAppPushNotification item) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onOpenNotification(item),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      item.status.isNotEmpty ? item.status : item.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        item.vehicleWithPlate,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF9E9E9E),
                          fontSize: 12,
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
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                Text(
                  item.body,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFD1D1D6),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
