import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/petabengkel_controller.dart';

class PetabengkelView extends GetView<PetabengkelController> {
  const PetabengkelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          // MAP
          SizedBox(
            width: double.infinity,
            height: double.infinity,

            child: Image.asset(
              "assets/images/map.png",
              fit: BoxFit.cover,
            ),
          ),

          // SEARCH
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios),
                  ),

                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Cari bengkel...",

                        prefixIcon: const Icon(Icons.search),

                        filled: true,
                        fillColor: Colors.white,

                        contentPadding: const EdgeInsets.symmetric(vertical: 0),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),

                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BOTTOM SHEET
          DraggableScrollableSheet(
            initialChildSize: 0.23,
            minChildSize: 0.23,
            maxChildSize: 0.82,

            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),

                child: SingleChildScrollView(
                  controller: scrollController,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const SizedBox(height: 12),

                      Center(
                        child: Container(
                          width: 50,
                          height: 5,

                          decoration: BoxDecoration(
                            color: Colors.blue,

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
                            const Text(
                              "Bengkel nada motor",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              "Servis Motor 24 Jam",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),

                                const SizedBox(width: 4),

                                const Text(
                                  "5,0",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(width: 4),

                                const Text("(21 Ulasan)"),

                                const Spacer(),

                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                ),

                                const SizedBox(width: 4),

                                const Text(
                                  "1,6 km dari lokasi anda",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),

                              child: Image.asset(
                                "assets/images/bengkel.png",
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),

                            const SizedBox(height: 20),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.blue,
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: const Text(
                                    "Jl. Sunan Gn. Jati III, Limbangan Wetan, Kec. Brebes, Kabupaten Brebes, Jawa Tengah 52218",
                                    style: TextStyle(height: 1.5),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Colors.blue,
                                ),

                                const SizedBox(width: 10),

                                const Text(
                                  "Buka 24 Jam",
                                  style: TextStyle(fontSize: 15),
                                ),

                                const SizedBox(width: 5),

                                const Icon(Icons.keyboard_arrow_down),
                              ],
                            ),

                            const SizedBox(height: 20),

                            Row(
                              children: [
                                const Icon(
                                  Icons.phone_outlined,
                                  color: Colors.blue,
                                ),

                                const SizedBox(width: 10),

                                const Text(
                                  "0877-8863-1358",
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),

                            const Divider(),

                            const SizedBox(height: 20),

                            const Text(
                              "Ringkasan Ulasan",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 20),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Expanded(
                                  child: Column(
                                    children: List.generate(5, (index) {
                                      int star = 5 - index;

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),

                                        child: Row(
                                          children: [
                                            Text("$star"),

                                            const SizedBox(width: 8),

                                            Expanded(
                                              child: LinearProgressIndicator(
                                                value: star == 5 ? 0.95 : 0.05,

                                                minHeight: 6,

                                                borderRadius:
                                                    BorderRadius.circular(10),

                                                backgroundColor:
                                                    Colors.grey.shade200,

                                                valueColor:
                                                    const AlwaysStoppedAnimation(
                                                      Colors.amber,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ),

                                const SizedBox(width: 20),

                                Column(
                                  children: const [
                                    Text(
                                      "5,0",
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 6),

                                    Text(
                                      "21 ulasan",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),

                            _reviewItem(
                              "“Service nya bagus, pelayanan memuaskan”",
                            ),

                            const SizedBox(height: 16),

                            _reviewItem(
                              "“Cepat tanggap solusi terbaik pas motor trouble tapi ngga ada bengkel di sekitar”",
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static Widget _reviewItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey,

          child: Icon(Icons.person, color: Colors.white, size: 18),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14, height: 1.5)),
        ),
      ],
    );
  }
}