import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/estimasi_controller.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';
import 'package:capbatu/app/widgets/base_bottom_sheet.dart';
import 'package:capbatu/app/widgets/app_feedback_widgets.dart';

class EstimasiView extends GetView<EstimasiController> {
  const EstimasiView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(EstimasiController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 30, 16, 24),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const Expanded(
                    child: Text(
                      "Estimasi Biaya",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer penyeimbang layout center
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (value) => controller.search.value = value,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: "Cari komponen...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                        child: Image.asset(
                          "assets/icon/search.png",
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Filter Kategori (Chips)
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return Obx(() {
                    final isSelected =
                        controller.selectedCategory.value == category;
                    return GestureDetector(
                      onTap: () => controller.setCategory(category),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : Colors.grey.shade300,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredProducts.isEmpty) {
                  return EmptyCostEstimate(onRetry: controller.getEstimasi);
                }

                return OrientationBuilder(
                  builder: (context, orientation) {
                    final screenWidth = MediaQuery.sizeOf(context).width;
                    final crossAxisCount = orientation == Orientation.landscape
                        ? (screenWidth >= 900 ? 4 : 3)
                        : (screenWidth >= 600 ? 3 : 2);

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.filteredProducts.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: orientation == Orientation.landscape
                            ? 0.68
                            : 0.58,
                      ),
                      itemBuilder: (context, index) {
                        final item = controller.filteredProducts[index];
                        return ProductCard(item: item, controller: controller);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),

      // Bottom Bar (Sticky Footer)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        controller.totalSelected == 0
                            ? "Belum ada komponen dipilih"
                            : "${controller.totalSelected} Komponen dipilih",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(
                      () => Text(
                        controller.formatRupiah(controller.totalPrice),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Harga perkiraan dari marketplace, dapat berbeda di toko.",
                      style: TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed: () => _showRincianBottomSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Lihat Rincian",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // PERBAIKAN: Bungkus dengan SingleChildScrollView agar tidak overflow saat keyboard muncul
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Image.asset(
            "assets/logo/biaya_empty.png",
            height: 180,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.manage_search_outlined,
              size: 120,
              color: AppColors.primarySoft,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Komponen Tidak Ditemukan",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Coba kata kunci lain atau pilih kategori di atas\nuntuk melihat komponen yang tersedia.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Modul Rincian Bottom Sheet menggunakan BaseBottomSheet bawaan Anda
  void _showRincianBottomSheet(BuildContext context) {
    if (controller.totalSelected == 0) {
      Get.snackbar(
        "Info",
        "Belum ada komponen yang dipilih",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    BaseBottomSheet.show(
      context: context,
      title: "Rincian Estimasi",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // List Item Rincian
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: controller.products
                  .where((p) => p.isSelected.value)
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              p.componentName.isNotEmpty
                                  ? p.componentName
                                  : p.title,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            controller.formatRupiah(p.price),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Total & Catatan
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // PERBAIKAN: Bungkus Column Keterangan dengan Expanded agar Teks Harga tidak overflow ke kanan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Estimasi Biaya",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Belum termasuk biaya jasa pemasangan di bengkel.",
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                controller.formatRupiah(controller.totalPrice),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Widget Item Card Produk
class ProductCard extends StatelessWidget {
  final ProductModel item;
  final EstimasiController controller;

  const ProductCard({super.key, required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () => controller.toggleProduct(item),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isSelected.value
                  ? AppColors.primaryBlue
                  : Colors.grey.shade200,
              width: item.isSelected.value ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (!item.isSelected.value)
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Image.network(
                        item.image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey.shade100),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: item.isSelected.value
                            ? AppColors.primaryBlue
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: item.isSelected.value
                              ? AppColors.primaryBlue
                              : Colors.grey.shade400,
                        ),
                      ),
                      child: item.isSelected.value
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        controller.formatRupiah(item.price),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.store,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
