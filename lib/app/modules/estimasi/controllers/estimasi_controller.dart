import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:capbatu/app/services/connectivity_service.dart';

class ProductModel {
  final int id;
  final String image;
  final String title;
  final String store;
  final int price;
  final String brand;
  final String componentName;

  RxBool isSelected = false.obs;

  ProductModel({
    required this.id,
    required this.image,
    required this.title,
    required this.store,
    required this.price,
    required this.brand,
    required this.componentName,
    bool selected = false,
  }) {
    isSelected.value = selected;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      image: json['image_url'] ?? '',
      title: json['product_name'] ?? '',
      store: json['store'] ?? '',
      price: json['price'] ?? 0,
      brand: json['brand'] ?? '',
      componentName: json['component_name'] ?? '',
    );
  }
}

class EstimasiController extends GetxController {
  final baseUrl = dotenv.env['PUBLIC_API_BASE_URL'];

  RxString search = ''.obs;
  RxBool isLoading = false.obs;

  final products = <ProductModel>[].obs;

  // Daftar kategori yang tersedia
  final List<String> categories = [
    'Semua',
    'Kampas Rem',
    'Oli',
    'Busi',
    'Filter',
    'CVT',
  ];
  RxString selectedCategory = 'Semua'.obs;

  @override
  void onInit() {
    super.onInit();
    getEstimasi();
  }

  Future<void> getEstimasi() async {
    try {
      isLoading.value = true;

      final response = await http.get(
        Uri.parse("$baseUrl/api/kerusakan/estimasi"),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body["success"] == true) {
        products.assignAll(
          (body["data"] as List).map((e) => ProductModel.fromJson(e)).toList(),
        );
      } else {
        Get.snackbar("Error", "Gagal mengambil data estimasi");
      }
    } catch (e) {
      if (!ConnectivityService.handleNetworkError(e)) {
        Get.snackbar("Error", "Gagal mengambil data estimasi");
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi untuk mengganti kategori
  void setCategory(String category) {
    selectedCategory.value = category;
  }

  // Getter data dengan filter text search & kategori aktif
  List<ProductModel> get filteredProducts {
    List<ProductModel> filtered = products;

    if (selectedCategory.value != 'Semua') {
      filtered = filtered.where((item) {
        return item.componentName.toLowerCase().contains(
              selectedCategory.value.toLowerCase(),
            ) ||
            item.title.toLowerCase().contains(
              selectedCategory.value.toLowerCase(),
            );
      }).toList();
    }

    if (search.value.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.title.toLowerCase().contains(search.value.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  void toggleProduct(ProductModel product) {
    product.isSelected.toggle();
    products.refresh(); // Memaksa update observer
  }

  int get totalSelected => products.where((e) => e.isSelected.value).length;

  int get totalPrice => products
      .where((e) => e.isSelected.value)
      .fold(0, (sum, item) => sum + item.price);

  String formatRupiah(int value) {
    return "Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}";
  }
}