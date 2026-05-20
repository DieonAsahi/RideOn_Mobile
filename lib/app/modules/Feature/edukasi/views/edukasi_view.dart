import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/edukasi_controller.dart';

class EdukasiView extends GetView<EdukasiController> {
  const EdukasiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,

      // bottomNavigationBar abaikan karena sudah ada
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              /// TITLE
              Center(
                child: Text(
                  "Edukasi",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// SEARCH
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: (value) {
                    controller.search.value = value;
                  },
                  decoration: InputDecoration(
                    hintText: "Cari artikel...",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: const Padding(
                      padding: EdgeInsets.only(right: 14),
                      child: Icon(Icons.search, color: Colors.black, size: 26),
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// TITLE SECTION
              const Text(
                "Artikel Populer",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),

              /// LIST ARTIKEL
              Obx(
                () => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.filteredArtikel.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final data = controller.filteredArtikel[index];

                    return ArtikelCard(
                      source: data.source,
                      title: data.title,
                      date: data.date,
                      desc: data.desc,
                      logo: data.logo,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArtikelCard extends StatelessWidget {
  final String source;
  final String title;
  final String date;
  final String desc;
  final String logo;

  const ArtikelCard({
    super.key,
    required this.source,
    required this.title,
    required this.date,
    required this.desc,
    required this.logo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade400, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LOGO + SOURCE
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(logo),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 6),

              Text(
                source,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// TITLE
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2782FF),
            ),
          ),

          const SizedBox(height: 6),

          /// DATE + DESC
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "$date — ",
                  style: TextStyle(color: Colors.grey.shade600),
                ),

                TextSpan(
                  text: desc,
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}
