import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

      print("STATUS : ${response.statusCode}");
      print("BODY : ${response.body}");

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body["success"] == true) {
        products.assignAll(
          (body["data"] as List).map((e) => ProductModel.fromJson(e)).toList(),
        );

        print("TOTAL DATA : ${products.length}");
      } else {
        Get.snackbar("Error", "Gagal mengambil data estimasi");
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  List<ProductModel> get filteredProducts {
    if (search.value.isEmpty) return products;

    return products.where((item) {
      return item.title.toLowerCase().contains(search.value.toLowerCase());
    }).toList();
  }

  void toggleProduct(ProductModel product) {
    product.isSelected.toggle();
    products.refresh();
  }

  int get totalSelected => products.where((e) => e.isSelected.value).length;

  int get totalPrice => products
      .where((e) => e.isSelected.value)
      .fold(0, (sum, item) => sum + item.price);

  String formatRupiah(int value) {
    return "Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}";
  }
}
