import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Diperlukan untuk FilteringTextInputFormatter
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2196F3);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: primaryBlue,
      body: Stack(
        children: [
          // ================= BACKGROUND GELEMBUNG =================
          Positioned(
            top: 50,
            right: -30,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ================= LOGO AREA (ANIMASI) =================
          Positioned(
            top: MediaQuery.of(context).size.height * 0.08,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: controller.logoOffsetAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo/rideon.png',
                    width: MediaQuery.of(context).size.width * 0.8,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      "RideOn Logo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Ganti SizedBox dengan Transform.translate
                  // Mainkan angka -20 menjadi lebih minus (contoh -30 atau -40)
                  // kalau dirasa masih kurang mepet ke atas.
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: const Text(
                      "Rawat Motor Lebih Teratur",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ================= CONTAINER FORM (ANIMASI NAIK) =================
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: controller.sheetOffsetAnim,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.72,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      const Text(
                        "Selamat Datang Kembali",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Masuk untuk melanjutkan perawatan motormu.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 30),

                      const Text(
                        "Email",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Text Field Email dengan validasi error real-time
                      Obx(
                        () => TextField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                            "Masukkan email Anda",
                            errorText: controller.emailError.value,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      const Text(
                        "Kata Sandi",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Text Field Password dengan validasi number only & length
                      Obx(
                        () => TextField(
                          controller: controller.passwordController,
                          obscureText: controller.isObscure.value,
                          keyboardType: TextInputType.number, // Keyboard angka
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly, // Hanya terima angka
                          ],
                          decoration:
                              _inputDecoration(
                                "Masukkan kata sandi",
                                errorText: controller.passwordError.value,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isObscure.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed:
                                      controller.togglePasswordVisibility,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 5),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Get.toNamed(
                              '/emailver',
                              arguments: {'from': 'forgot_password'},
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "Lupa kata sandi?",
                            style: TextStyle(
                              color: primaryBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: controller.login,
                          child: const Text(
                            "Masuk",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              "Or",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                            backgroundColor: Colors.white,
                          ),
                          onPressed: controller.loginGoogle,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/google.png',
                                height: 24,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Masuk dengan Google",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Belum punya akun? ",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.offNamed('/register');
                            },
                            child: const Text(
                              "Daftar",
                              style: TextStyle(
                                color: primaryBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ================= OVERLAY LOADING =================
          Obx(() {
            if (controller.isLoggingIn.value) {
              return Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SequentialDotsLoading(),
                        SizedBox(height: 14),
                        Text(
                          "Melakukan proses login",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  // Fungsi Helper inputDecoration yang menerima parameter errorText
  InputDecoration _inputDecoration(String hint, {String? errorText}) {
    return InputDecoration(
      hintText: hint,
      errorText:
          errorText, // Menampilkan error text otomatis secara bawaan material UI
      errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}

// Komponen loading
class SequentialDotsLoading extends StatefulWidget {
  const SequentialDotsLoading({super.key});

  @override
  State<SequentialDotsLoading> createState() => _SequentialDotsLoadingState();
}

class _SequentialDotsLoadingState extends State<SequentialDotsLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0, val),
            const SizedBox(width: 10),
            _buildDot(1, val),
            const SizedBox(width: 10),
            _buildDot(2, val),
          ],
        );
      },
    );
  }

  Widget _buildDot(int index, double progress) {
    final start = index * 0.33;
    final end = start + 0.33;
    final isActive = progress >= start && progress < end;

    String assetPath;
    if (isActive) {
      assetPath = 'assets/icons/Ellipse 11.png';
    } else if ((progress >= (start - 0.15) && progress < start) ||
        (progress >= end && progress < (end + 0.15))) {
      assetPath = 'assets/icons/Ellipse 10.png';
    } else {
      assetPath = 'assets/icons/Ellipse 9.png';
    }

    return AnimatedScale(
      scale: isActive ? 1.35 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Image.asset(
        assetPath,
        width: 18,
        height: 18,
        errorBuilder: (_, __, ___) => Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF0085FF) : const Color(0xFFB3D9FF),
          ),
        ),
      ),
    );
  }
}
