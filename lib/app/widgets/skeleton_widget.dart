import 'package:flutter/material.dart';

class SkeletonBox extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final ShapeBorder? shape;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.shape,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final color = Color.lerp(
          Color(0xFFE3F2FD),
          Color(0xFFF0F2F5),
          _animController.value,
        );

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: widget.shape == null
                ? BorderRadius.circular(widget.borderRadius)
                : null,
            shape: widget.shape is CircleBorder
                ? BoxShape.circle
                : BoxShape.rectangle,
          ),
        );
      },
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        const SkeletonBox(width: 80, height: 24, borderRadius: 6),
        const SizedBox(height: 30),
        const SkeletonBox(width: 84, height: 84, shape: CircleBorder()),
        const SizedBox(height: 14),
        const SkeletonBox(width: 140, height: 20, borderRadius: 6),
        const SizedBox(height: 8),
        const SkeletonBox(width: 200, height: 16, borderRadius: 6),
        const SizedBox(height: 36),
        const Align(
          alignment: Alignment.centerLeft,
          child: SkeletonBox(width: 130, height: 18, borderRadius: 6),
        ),
        const SizedBox(height: 16),
        const SkeletonBox(width: double.infinity, height: 56, borderRadius: 14),
        const SizedBox(height: 12),
        const SkeletonBox(width: double.infinity, height: 56, borderRadius: 14),
        const SizedBox(height: 12),
        const SkeletonBox(width: double.infinity, height: 56, borderRadius: 14),
      ],
    );
  }
}

class HomeVehicleSkeleton extends StatelessWidget {
  const HomeVehicleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: SkeletonBox(width: 220, height: 160, borderRadius: 16),
      ),
    );
  }
}

class HomeComponentsSkeleton extends StatelessWidget {
  const HomeComponentsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: constraints.maxWidth > 700 ? 0.82 : 0.68,
          ),
          itemBuilder: (context, index) {
            return const SkeletonBox(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 16,
            );
          },
        );
      },
    );
  }
}

class OdometerCardSkeleton extends StatelessWidget {
  const OdometerCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
      decoration: BoxDecoration(
        // Skeleton OdometerCard ini saya buat biru pucat agar cocok
        // dengan desain asli card-nya saat data sudah muncul
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF90CAF9), Color(0xFFEBF6FF)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              // Skeleton untuk Dropdown Nama Motor
              SkeletonBox(width: 140, height: 24, borderRadius: 6),
              // Skeleton untuk Plat Nomor
              SkeletonBox(width: 80, height: 20, borderRadius: 6),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              // Skeleton Kotak untuk Icon Odometer
              SkeletonBox(width: 30, height: 30, borderRadius: 8),
              SizedBox(width: 10),
              // Skeleton untuk Angka KM
              SkeletonBox(width: 160, height: 34, borderRadius: 8),
            ],
          ),
          const SizedBox(height: 15),
          // Skeleton untuk Tombol Update
          const SkeletonBox(
            width: double.infinity,
            height: 48,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }
}

class HeaderProfilSkeleton extends StatelessWidget {
  const HeaderProfilSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // Skeleton untuk logo RideOn
              SkeletonBox(width: 100, height: 30, borderRadius: 6),
              SizedBox(height: 15),
              // Skeleton untuk Teks "Halo, Nama"
              SkeletonBox(width: 150, height: 20, borderRadius: 4),
            ],
          ),
          // Skeleton untuk Icon Notifikasi (Bentuk Lingkaran)
          const SkeletonBox(width: 32, height: 32, shape: CircleBorder()),
        ],
      ),
    );
  }
}

class PerformaSkeleton extends StatelessWidget {
  const PerformaSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300, // Warna abu-abu pucat untuk loading
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SkeletonBox(width: 50, height: 50, shape: CircleBorder()),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SkeletonBox(width: 120, height: 14, borderRadius: 4),
                SizedBox(height: 8),
                SkeletonBox(width: 60, height: 14, borderRadius: 4),
              ],
            ),
          ),

          const SkeletonBox(width: 85, height: 32, borderRadius: 8),
        ],
      ),
    );
  }
}

class ServiceSkeleton extends StatelessWidget {
  const ServiceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE1E1E1), width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                SkeletonBox(width: 60, height: 60, borderRadius: 14),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 60, height: 18, borderRadius: 6),
                      SizedBox(height: 8),
                      SkeletonBox(width: 140, height: 16, borderRadius: 6),
                      SizedBox(height: 6),
                      SkeletonBox(
                        width: double.infinity,
                        height: 12,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class KendaraanSkeleton extends StatelessWidget {
  const KendaraanSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (index) => Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE1E1E1), width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 120, height: 24, borderRadius: 12),
                    SkeletonBox(width: 24, height: 24, borderRadius: 12),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    SkeletonBox(width: 100, height: 75, borderRadius: 14),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 140, height: 18, borderRadius: 6),
                          SizedBox(height: 8),
                          SkeletonBox(width: 100, height: 14, borderRadius: 6),
                          SizedBox(height: 8),
                          SkeletonBox(width: 80, height: 14, borderRadius: 6),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RwtservisSkeleton extends StatelessWidget {
  const RwtservisSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE1E1E1), width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10, top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 90, height: 18, borderRadius: 6),
                          SizedBox(height: 8),
                          SkeletonBox(width: 140, height: 16, borderRadius: 6),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10, right: 8),
                    child: SkeletonBox(width: 60, height: 20, borderRadius: 4),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: SkeletonBox(width: 18, height: 18, borderRadius: 4),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Padding(
                padding: EdgeInsets.only(left: 10, right: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 50, height: 10, borderRadius: 4),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              SkeletonBox(
                                  width: 20, height: 20, borderRadius: 6),
                              SizedBox(width: 8),
                              SkeletonBox(
                                  width: 80, height: 14, borderRadius: 4),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 60, height: 10, borderRadius: 4),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              SkeletonBox(
                                  width: 20, height: 20, borderRadius: 6),
                              SizedBox(width: 8),
                              SkeletonBox(
                                  width: 70, height: 14, borderRadius: 4),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 50, height: 10, borderRadius: 4),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        SkeletonBox(width: 20, height: 20, borderRadius: 6),
                        SizedBox(width: 8),
                        SkeletonBox(width: 120, height: 14, borderRadius: 4),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Divider(color: Colors.grey.shade200),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 75, height: 14, borderRadius: 4),
                    SkeletonBox(width: 90, height: 14, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EdukasiSkeleton extends StatelessWidget {
  const EdukasiSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE1E1E1), width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonBox(width: 90, height: 12, borderRadius: 4),
                  SkeletonBox(width: 70, height: 12, borderRadius: 4),
                ],
              ),
              SizedBox(height: 8),
              SkeletonBox(width: double.infinity, height: 16, borderRadius: 4),
              SizedBox(height: 6),
              SkeletonBox(width: 180, height: 16, borderRadius: 4),
              SizedBox(height: 8),
              SkeletonBox(width: double.infinity, height: 12, borderRadius: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class DtlperformaSkeleton extends StatelessWidget {
  const DtlperformaSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Center(
          child: SkeletonBox(width: 130, height: 130, shape: CircleBorder()),
        ),
        const SizedBox(height: 24),
        const SkeletonBox(
            width: double.infinity, height: 44, borderRadius: 100),
        const SizedBox(height: 24),
        const SkeletonBox(
            width: double.infinity, height: 210, borderRadius: 16),
        const SizedBox(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: SkeletonBox(width: 140, height: 18, borderRadius: 6),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          2,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE1E1E1)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(width: 100, height: 16, borderRadius: 4),
                SkeletonBox(width: 60, height: 16, borderRadius: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
