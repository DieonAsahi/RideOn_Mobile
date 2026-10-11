import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSnackbar {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  /// Tampilkan snackbar sukses yang otomatis berada di atas keyboard jika keyboard aktif
  static void success(String message) {
    show(message);
  }

  static void show(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInternal(message);
    });
  }

  static void _showInternal(String message) {
    // Tutup snackbar GetX lama jika ada
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    _dismissTimer?.cancel();
    try {
      _currentEntry?.remove();
    } catch (_) {}
    _currentEntry = null;

    // Prioritaskan Root Navigator Overlay agar snackbar tidak terhapus saat dialog ditutup / route berganti
    final overlay = Get.key.currentState?.overlay ??
        (Get.overlayContext != null
            ? Overlay.maybeOf(Get.overlayContext!)
            : null) ??
        (Get.context != null ? Overlay.maybeOf(Get.context!) : null);

    if (overlay == null) {
      Get.rawSnackbar(
        messageText: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF1E293B),
          ),
        ),
        backgroundColor: const Color(0xFFDCFCE7),
        borderRadius: 16,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _SnackbarOverlayWidget(
        message: message,
        onDismiss: () {
          if (_currentEntry == entry) {
            try {
              _currentEntry?.remove();
            } catch (_) {}
            _currentEntry = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }
}

class _SnackbarOverlayWidget extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const _SnackbarOverlayWidget({
    required this.message,
    required this.onDismiss,
  });

  @override
  State<_SnackbarOverlayWidget> createState() => _SnackbarOverlayWidgetState();
}

class _SnackbarOverlayWidgetState extends State<_SnackbarOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();

    // Otomatis hilang setelah 3 detik
    _timer = Timer(const Duration(seconds: 3), () {
      _dismiss();
    });
  }

  void _dismiss() {
    if (!mounted) return;
    _animController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final bottomPadding = mediaQuery.padding.bottom;

    // Menghitung posisi bawah: persis di atas keyboard jika keyboard terbuka,
    // atau di bawah layar dengan margin aman jika keyboard tertutup
    final double bottomOffset = keyboardHeight > 0
        ? keyboardHeight + 12
        : (bottomPadding > 0 ? bottomPadding + 16 : 24);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      left: 16,
      right: 16,
      bottom: bottomOffset,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  widget.message,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
