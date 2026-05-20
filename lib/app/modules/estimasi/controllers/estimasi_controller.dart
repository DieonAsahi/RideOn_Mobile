import 'package:get/get.dart';

class ProductModel {
  final String image;
  final String title;
  final String store;
  final int price;
  RxBool isSelected = false.obs;

  ProductModel({
    required this.image,
    required this.title,
    required this.store,
    required this.price,
    bool selected = false,
  }) {
    isSelected.value = selected;
  }
}

class EstimasiController extends GetxController {
  RxString search = ''.obs;

  final products = <ProductModel>[
    ProductModel(
      image:
          'assets/images/estimasi1.png',
      title: 'Oli Mesin MPX2 10W30 800ml',
      store: 'Lazada',
      price: 64000,
      selected: true,
    ),
    ProductModel(
      image:
          'assets/images/estimasi2.png',
      title: 'CVT Mio J-Mio GT-XRIDE 115cc',
      store: 'Shopee',
      price: 352000,
    ),
    ProductModel(
      image: 'assets/images/estimasi3.png',
      title: 'CVT Mio J-Mio GT-XRIDE 115cc',
      store: 'Blibli',
      price: 80000,
    ),
    ProductModel(
      image:
          'assets/images/estimasi4.png',
      title: 'NGK C7HSA Busi Motor Honda',
      store: 'Shopee',
      price: 18900,
      selected: true,
    ),
  ].obs;

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
    return "Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }
}