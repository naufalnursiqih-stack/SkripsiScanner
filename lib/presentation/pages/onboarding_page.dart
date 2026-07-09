// lib/presentation/pages/onboarding_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_shell.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const Color _uinGold = Color(0xFFFCBF48);
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingModel> _slides = [
    OnboardingModel(
      title: 'Ambil Foto Cover',
      description: 'Arahkan kamera ke sampul skripsi\nuntuk mendeteksi data otomatis.',
      imageUrl: 'assets/onboarding_1.png',
      hasScanningOverlay: true,
    ),
    OnboardingModel(
      title: 'Ekstraksi AI',
      description: 'Mengenali judul, penulis, dan data penting\nlainnya dalam hitungan detik.',
      imageUrl: 'assets/onboarding_2.png',
      hasScanningOverlay: false,
    ),
    OnboardingModel(
      title: 'Ekspor Langsung',
      description: 'Simpan hasil scan langsung ke Google Sheets\nuntuk manajemen data yang lebih rapi.',
      imageUrl: 'assets/onboarding_3.png',
      hasScanningOverlay: false,
    ),
  ];

  void _onSkip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardShell()),
    );
  }

  void _onNext() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardShell()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const secondaryColor = Color(0xFFFCBF48); // Gold
    final poppinsFont = GoogleFonts.poppins().fontFamily;

    return Scaffold(
      body: Stack(
        children: [
          // 11. Background Gradient Modern
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff145531),
                    Color(0xff1E5E3A),
                    Color(0xff206C43),
                  ],
                ),
              ),
            ),
          ),
          // Background Dot Grid Texture
          Positioned.fill(
            child: CustomPaint(
              painter: _DotGridPainter(),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    // 4. Bagian Atas Halaman dengan Padding Lebih Rapat
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 5. Logo dengan Branding Icon
                          Row(
                            children: [
                              Image.asset(
                                'assets/Group.png',
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'SkripsiScan',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: poppinsFont,
                                ),
                              ),
                            ],
                          ),
                          if (_currentIndex < _slides.length - 1)
                            // 6. Tombol Lewati (Capsule Background)
                            GestureDetector(
                              onTap: _onSkip,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Lewati',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _uinGold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 12,
                                    color: _uinGold,
                                  ),
                                ],
                              ),
                            )
                          else
                            const SizedBox(width: 48, height: 36),
                        ],
                      ),
                    ),

                    // Tampilan Geser Gambar & Konten dengan Fitur Anti-Overflow
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _slides.length,
                        onPageChanged: (index) => setState(() => _currentIndex = index),
                        itemBuilder: (context, index) {
                          final slide = _slides[index];
                          return Center(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 1. & 12. Kontainer Card Ukuran Pas & Efek Melayang
                                  Transform.translate(
                                    offset: const Offset(0, -10),
                                    child: FractionallySizedBox(
                                      widthFactor: 0.85,
                                      child: AspectRatio(
                                        aspectRatio: 1.0,
                                        // 3. Efek Glassmorphic Container
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.95),
                                            borderRadius: BorderRadius.circular(24),
                                            border: Border.all(color: Colors.white.withOpacity(0.15)),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 30,
                                                offset: Offset(0, 15),
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.all(20),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // 2. Lingkaran Glow Lembut di Belakang Gambar
                                              Positioned.fill(
                                                child: Center(
                                                  child: Container(
                                                    width: 200,
                                                    height: 200,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: const Color(0xFF1E5E3A).withOpacity(0.06),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Gambar Utama
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(16),
                                                child: Image.asset(
                                                  slide.imageUrl,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      color: Colors.grey.shade50,
                                                      child: const Icon(
                                                        Icons.image_rounded,
                                                        size: 64,
                                                        color: Colors.grey,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              if (slide.hasScanningOverlay)
                                                const _ScanningOverlay(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // 13. Animasi Transisi Teks (AnimatedSwitcher)
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Column(
                                      key: ValueKey<int>(_currentIndex),
                                      children: [
                                        // 7. Judul Lebih Besar & Bold
                                        Text(
                                          slide.title,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: -0.5,
                                            fontFamily: poppinsFont,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        // 8. Deskripsi Maksimal 2 Baris & Ringkas
                                        Text(
                                          slide.description,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white.withOpacity(0.85),
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Indikator Halaman & Aksi Bottom
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        children: [
                          // 9. Titik Indikator Halaman Animated
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_slides.length, (index) {
                              final isActive = index == _currentIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: isActive ? 32 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isActive ? secondaryColor : Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 24),

                          // 10. Tombol Utama Premium dengan Shadow Anggun
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _onNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: secondaryColor,
                                foregroundColor: const Color(0xFF271900),
                                elevation: 8,
                                shadowColor: secondaryColor.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_currentIndex == _slides.length - 1
                                      ? 'Mulai Sekarang'
                                      : 'Selanjutnya'),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Langkah ${_currentIndex + 1} dari ${_slides.length}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingModel {
  final String title;
  final String description;
  final String imageUrl;
  final bool hasScanningOverlay;

  OnboardingModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.hasScanningOverlay,
  });
}

class _ScanningOverlay extends StatefulWidget {
  const _ScanningOverlay();

  @override
  State<_ScanningOverlay> createState() => _ScanningOverlayState();
}

class _ScanningOverlayState extends State<_ScanningOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFFCBF48);

    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green.withOpacity(0.12), width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const Positioned(top: 0, left: 0, child: _CornerBorder(top: true, left: true)),
            const Positioned(top: 0, right: 0, child: _CornerBorder(top: true, left: false)),
            const Positioned(bottom: 0, left: 0, child: _CornerBorder(top: false, left: true)),
            const Positioned(bottom: 0, right: 0, child: _CornerBorder(top: false, left: false)),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Align(
                  alignment: Alignment(0.0, -0.8 + (_animationController.value * 1.6)),
                  child: child!,
                );
              },
              child: Container(
                height: 2,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, goldColor.withOpacity(0.8), Colors.transparent],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: goldColor.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerBorder extends StatelessWidget {
  final bool top;
  final bool left;
  const _CornerBorder({required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFFCBF48);
    const double size = 12.0;
    const double thickness = 2.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            top: top ? 0 : null,
            bottom: !top ? 0 : null,
            left: 0,
            right: 0,
            child: Container(height: thickness, color: goldColor),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: left ? 0 : null,
            right: !left ? 0 : null,
            child: Container(width: thickness, color: goldColor),
          ),
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;
      
    const double spacing = 24.0;
    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.75, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}