import 'package:flutter/material.dart';

class BaseBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;

  const BaseBottomSheet({
    super.key,
    this.title,
    required this.child,
  });

  /// Fungsi statis untuk memanggil bottom sheet dengan mudah dari page manapun
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(0.5),
      isScrollControlled: true, // Wajib true agar form input tidak tertutup keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => BaseBottomSheet(
        title: title,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          // Ini berfungsi agar bottom sheet terdorong ke atas saat keyboard muncul
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Tinggi menyesuaikan isi child
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar (Garis abu-abu di tengah atas)
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Judul Bottom Sheet (Jika ada)
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Isi Konten Bottom Sheet (Bisa diisi OdometerForm atau Menu Foto)
            child,
          ],
        ),
      ),
    );
  }
}