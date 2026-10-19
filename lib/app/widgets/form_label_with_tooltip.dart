import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Label form yang menjelaskan format atau aturan input tanpa memenuhi layar.
class FormLabelWithTooltip extends StatelessWidget {
  final String label;
  final String message;
  final TextStyle? style;

  const FormLabelWithTooltip({
    super.key,
    required this.label,
    required this.message,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: style),
        const SizedBox(width: 4),
        Tooltip(
          message: message,
          triggerMode: TooltipTriggerMode.tap,
          // Batasi lebar maksimal 65% dari lebar layar agar tidak melebar full-screen
          constraints: BoxConstraints(maxWidth: screenWidth * 0.65),
          // Hapus durasi timeout cepat: tetap tampil sampai user klik di luar (tap outside)
          showDuration: const Duration(days: 1),
          waitDuration: Duration.zero,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          textStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
            height: 1.4,
            fontWeight: FontWeight.normal,
          ),
          child: const Padding(
            padding: EdgeInsets.all(2.0),
            child: Icon(Icons.info_outline, size: 17, color: Color(0xFF64748B)),
          ),
        ),
      ],
    );
  }
}
