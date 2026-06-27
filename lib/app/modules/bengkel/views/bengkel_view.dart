import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/bengkel_controller.dart';

class BengkelView extends GetView<BengkelController> {
  const BengkelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF006BFF),
        onPressed: () {
          Get.toNamed('/petabengkel');
        },
        icon: const Icon(Icons.map_outlined, color: Colors.white),
        label: const Text(
          "Lihat Peta",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.loadNearestWorkshop();
          },
          
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios),
                    ),

                    const Expanded(
                      child: Text(
                        "Bengkel Terdekat",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 40),
                  ],
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: controller.searchController,
                  onChanged: controller.searchBengkel,
                  decoration: InputDecoration(
                    hintText: "Cari bengkel...",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                    suffixIcon: SizedBox(
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
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                      itemCount: controller.filteredBengkelList.length,
                      itemBuilder: (context, index) {
                        final item = controller.filteredBengkelList[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                ),
                                child: Image.network(
                                  item['image'],
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return Container(
                                      height: 150,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.image),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['nama'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item['jenis'],
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Get.toNamed(
                                              '/rwttambah',
                                              arguments: {
                                                "nama_bengkel": item['nama'],
                                              },
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color(0xFF006BFF),
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Image.asset(
                                              "assets/icon/bagikan.png",
                                              width: 18,
                                              height: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(item['jarak']),
                                        const SizedBox(width: 10),
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(item['rating']),
                                        const SizedBox(width: 3),
                                        Text(
                                          item['ulasan'],
                                          style: const TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
