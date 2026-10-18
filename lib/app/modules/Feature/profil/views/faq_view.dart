import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:capbatu/app/core/theme/app_theme.dart';

class FaqItem {
  final String question;
  final String answer;

  const FaqItem({
    required this.question,
    required this.answer,
  });
}

class FaqView extends StatelessWidget {
  const FaqView({super.key});

  static const List<FaqItem> _faqList = [
    FaqItem(
      question: "Apa itu aplikasi RideOn?",
      answer:
          "RideOn adalah asisten pintar untuk perawatan motor Anda. Kami membantu mencatat riwayat servis, mengingatkan jadwal ganti komponen, dan menemukan bengkel terdekat.",
    ),
    FaqItem(
      question: "Bagaimana cara kerja Pengingat Servis?",
      answer:
          "RideOn menggunakan data odometer harian Anda untuk memprediksi kapan komponen motor (seperti Oli, CVT, Busi) akan aus, lalu mengirimkan notifikasi pengingat sebelum komponen tersebut rusak.",
    ),
    FaqItem(
      question: "Apakah saya harus memperbarui odometer setiap hari?",
      answer:
          "Sangat disarankan. Semakin rutin Anda memperbarui odometer, semakin akurat prediksi keausan komponen dan jadwal servis motor Anda.",
    ),
    FaqItem(
      question: "Apa fungsi tombol Pengingat Servis di Profil?",
      answer:
          "Tombol ini memungkinkan Anda mengaktifkan atau menonaktifkan notifikasi otomatis dari server (seperti pengingat odometer dan peringatan keausan komponen). Namun, notifikasi riwayat servis yang Anda input sendiri akan tetap masuk.",
    ),
    FaqItem(
      question: "Bagaimana cara menemukan bengkel terdekat?",
      answer:
          "Buka tab \"Bengkel\" di menu bawah. RideOn akan mendeteksi lokasi Anda dan menampilkan daftar bengkel resmi maupun umum di sekitar Anda beserta rute dan kontak yang bisa dihubungi.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "FAQ",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: _faqList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _faqList[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      childrenPadding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      iconColor: AppColors.primary,
                      collapsedIconColor: Colors.grey.shade600,
                      title: Text(
                        item.question,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item.answer,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
