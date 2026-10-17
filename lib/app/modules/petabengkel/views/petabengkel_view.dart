import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';
import '../controllers/petabengkel_controller.dart';

class PetabengkelView extends GetView<PetabengkelController> {
  const PetabengkelView({super.key});

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// ==========================================
          /// LAYER 1: PETA DAN MARKER
          /// ==========================================
          Obx(() {
            if (!controller.isPermissionGranted.value) {
              return SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/logo/izin_lokasi.png',
                            width: 160,
                            height: 160,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Izin Lokasi Diperlukan",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Izinkan akses lokasi agar kami dapat menemukan bengkel terdekat dari lokasi Anda.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () =>
                                controller.requestLocationPermission(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              "Izinkan Lokasi",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            final userLocation = controller.userLocation.value;
            if (userLocation == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: userLocation,
                initialZoom: 14,
                onMapReady: controller.onMapReady,
                onPositionChanged: (camera, hasGesture) {
                  controller.updateMapState(camera);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.bs.rideon',
                ),
                MarkerLayer(markers: controller.markers.toList()),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLocation,
                      width: 30,
                      height: 30,
                      child: Image.asset(
                        "assets/icon/lokasi_saya.png",
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),

          /// ==========================================
          /// LAYER 2: OVERLAY FULLSCREEN SEARCH
          /// ==========================================
          Obx(() {
            return Positioned.fill(
              child: IgnorePointer(
                ignoring: !controller.isSearchActive.value,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: controller.isSearchActive.value
                      ? Container(
                          key: const ValueKey('search_overlay_active'),
                          color: Colors.white,
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top + 90,
                          ),
                          child: _buildSearchContent(context),
                        )
                      : const SizedBox.shrink(key: ValueKey('search_overlay_hidden')),
                ),
              ),
            );
          }),

          /// ==========================================
          /// LAYER 3: SEARCH BAR
          /// ==========================================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 25,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (controller.isSearchActive.value) {
                            controller.isSearchActive.value = false;
                            controller.searchController.clear();
                            controller.onSearchChanged("");
                          } else {
                            Get.back();
                          }
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            if (!controller.isSearchActive.value)
                              const BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                          ],
                        ),
                        child: TextField(
                          controller: controller.searchController,
                          onTap: () {
                            controller.isSearchActive.value = true;
                            if (controller.showBottomSheet.value) {
                              controller.showBottomSheet.value = false;
                            }
                          },
                          onChanged: controller.onSearchChanged,
                          onSubmitted: controller.onSubmitSearch,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: "Cari bengkel...",
                            suffixIcon: GestureDetector(
                              onTap: () => controller.onSubmitSearch(
                                controller.searchController.text,
                              ),
                              child: Center(
                                widthFactor: 1,
                                child: Image.asset(
                                  "assets/icon/search.png",
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// ==========================================
          /// LAYER 4: BOTTOM SHEET DETAIL BENGKEL
          /// ==========================================
          Obx(() {
            if (controller.showBottomSheet.value &&
                !controller.isSearchActive.value) {
              return NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  controller.sheetExtent.value = notification.extent;
                  if (notification.extent <= 0.1) {
                    controller.showBottomSheet.value = false;
                  }
                  return true;
                },
                child: DraggableScrollableSheet(
                  key: ValueKey(controller.selectedWorkshop.value?.id),
                  initialChildSize: isLandscape ? 0.24 : 0.2,
                  minChildSize: isLandscape ? 0.24 : 0.2,
                  maxChildSize: isLandscape ? 0.92 : 1.0,
                  snap: true,
                  snapSizes: isLandscape
                      ? const [0.24, 0.6, 0.92]
                      : const [0.2, 0.5, 1.0],
                  builder: (context, scrollController) {
                    return _buildBottomSheetDetail(context, scrollController);
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          /// ==========================================
          /// LAYER 5: TOMBOL LOKASI SAYA
          /// ==========================================
          Obx(() {
            if (controller.isSearchActive.value ||
                controller.sheetExtent.value >= 0.9) {
              return const SizedBox.shrink();
            }

            final bottomPadding = controller.showBottomSheet.value
                ? (MediaQuery.of(context).size.height *
                          controller.sheetExtent.value) +
                      16
                : 16.0;

            return Positioned(
              right: 16,
              bottom: bottomPadding,
              child: GestureDetector(
                onTap: () {
                  if (controller.userLocation.value != null) {
                    controller.animatedMapMove(
                      controller.userLocation.value!,
                      14.0,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/icon/lokasi_saya.png",
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            );
          }),

          /// ==========================================
          /// LAYER 6: OVERLAY POP-UP ANIMASI (Jika GPS Mati)
          /// ==========================================
          Obx(() {
            if (controller.isPermissionGranted.value &&
                !controller.isGpsEnabled.value &&
                !controller.isGpsDismissed.value) {
              return Positioned.fill(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                      child: Container(color: Colors.black.withOpacity(0.4)),
                    ),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutBack,
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value.clamp(0.0, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: SafeArea(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/logo/missing_lokasi.png',
                                  height: 120,
                                  width: 120,
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "Lokasi Perangkat Tidak Aktif",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Aktifkan layanan lokasi perangkat untuk menemukan bengkel terdekat dari lokasi Anda.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          controller.dismissGpsDialog();
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: AppColors.primaryBlue,
                                            width: 1.5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                        ),
                                        child: const Text(
                                          "Nanti",
                                          style: TextStyle(
                                            color: AppColors.primaryBlue,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            controller.openGpsSettings(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryBlue,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                        ),
                                        child: const Text(
                                          "Aktifkan",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildSearchContent(BuildContext context) {
    if (controller.showSuggestions.value &&
        controller.searchSuggestions.isNotEmpty) {
      return ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: controller.searchSuggestions.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, index) {
          final item = controller.searchSuggestions[index];
          return ListTile(
            leading: const Icon(
              Icons.location_on_outlined,
              color: Colors.black87,
            ),
            title: Text(
              item.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              item.address,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => controller.onSelectSuggestion(item),
          );
        },
      );
    } else if (!controller.showSuggestions.value &&
        controller.filteredWorkshops.isEmpty &&
        controller.searchController.text.isNotEmpty) {
      final topInset = MediaQuery.of(context).padding.top + 90;
      return SizedBox.expand(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: topInset),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo/bengkel_empty.png',
                    width: 160,
                    height: 160,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Bengkel Tidak Ditemukan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "Tidak dapat menemukan hasil untuk '${controller.searchController.text}'. Coba kata kunci yang berbeda.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _workshopImage(String imageUrl, {required double height}) {
    Widget fallback() => Image.asset(
      'assets/image/placeholder.png',
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
    );

    if (imageUrl.trim().isEmpty) return fallback();

    return Image.network(
      imageUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }

  Widget _buildBottomSheetDetail(
    BuildContext context,
    ScrollController scrollController,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Obx(() {
          if (controller.isLoadingSheet.value) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Center(
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(height: 40),
              ],
            );
          }

          final workshop = controller.selectedWorkshop.value;
          if (workshop == null) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text("Memuat data...")),
            );
          }

          final extent = controller.sheetExtent.value;
          final openingHours = workshop.openingHours;
          final hoursList = openingHours.split('|');
          final firstDay = hoursList.isNotEmpty ? hoursList.first.trim() : "-";

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workshop.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      workshop.category,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              workshop.rating.toStringAsFixed(1).replaceAll('.', ','),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            Text("(${workshop.reviewCount} Ulasan)"),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                "${workshop.distanceKm.toStringAsFixed(1).replaceAll('.', ',')} km dari lokasi anda",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // FOTO BENGKEL (Tampil jika fase >= 50%)
                    if (extent >= 0.4) ...[
                      const SizedBox(height: 18),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: _workshopImage(workshop.imageUrl, height: 220),
                      ),
                    ],

                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          "assets/icon/lokasi_bengkel.png",
                          width: 22,
                          height: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            workshop.address,
                            style: const TextStyle(height: 1.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.zero,
                        leading: Image.asset(
                          "assets/icon/jam.png",
                          width: 22,
                          height: 22,
                        ),
                        title: Text(
                          firstDay,
                          style: const TextStyle(fontSize: 15),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: hoursList.skip(1).map((e) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    e.trim(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Image.asset(
                          "assets/icon/phone.png",
                          width: 22,
                          height: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          workshop.phone.isEmpty ? '-' : workshop.phone,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),

                    // TOMBOL TAMBAH CATATAN SERVIS (Tampil jika fase >= 100%)
                    if (extent >= 0.9) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.toNamed(
                              '/rwttambah',
                              arguments: {"nama_bengkel": workshop.title},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Tambah Catatan Servis",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 20),
                      const Text(
                        "Bengkel Lainnya",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: controller.otherWorkshops.map((item) {
                          return GestureDetector(
                            onTap: () {
                              controller.animatedMapMove(
                                LatLng(item.latitude, item.longitude),
                                16.5,
                              );
                              controller.getWorkshopDetail(item.id!);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(18),
                                      topRight: Radius.circular(18),
                                    ),
                                    child: _workshopImage(
                                      item.imageUrl,
                                      height: 140,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(item.category),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              "${item.distanceKm.toStringAsFixed(1)} km",
                                            ),
                                            const SizedBox(width: 12),
                                            const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                            Text(
                                              " ${item.rating} (${item.reviewCount} Ulasan)",
                                            ),
                                            const Spacer(),
                                            GestureDetector(
                                              onTap: () {
                                                Get.toNamed(
                                                  '/rwttambah',
                                                  arguments: {
                                                    "nama_bengkel": item.title,
                                                  },
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  7,
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFF2196F3,
                                                    ),
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Image.asset(
                                                  "assets/icon/bagikan.png", // Icon navigasi / tambah yang sesuai
                                                  width: 18,
                                                  height: 18,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    // Spacer bawah agar bisa discroll pol
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
