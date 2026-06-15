// lib/presentation/pages/splash_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _scanController;
  double _progress = 0.0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    
    // Animasi garis laser scanner (mengulang naik turun)
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Simulasi loading progress bar (0.0 sampai 1.0 dalam waktu ~2.5 detik)
    _startProgress();
  }

  void _startProgress() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) return;
      setState(() {
        if (_progress >= 1.0) {
          _progressTimer?.cancel();
          _navigateToHome();
        } else {
          _progress += 0.015;
          if (_progress > 1.0) _progress = 1.0;
        }
      });
    });
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const OnboardingPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Warna tema sesuai UIN Alauddin Makassar (Hijau UIN & Emas UIN)
    const primaryContainerColor = Color(0xFF1E5E3A); // Hijau Tua
    const goldColor = Color(0xFFFCBF48); // Aksen Emas UIN

    return Scaffold(
      backgroundColor: primaryContainerColor,
      body: Stack(
        children: [
          // Tekstur latar belakang pola titik (grid)
          Positioned.fill(
            child: CustomPaint(
              painter: _DotGridPainter(),
            ),
          ),
          
          // Tata letak konten utama
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Wadah logo dengan animasi pemindaian
                  _buildScanningLogo(goldColor),

                  const SizedBox(height: 32),

                  // Teks nama aplikasi
                  const Text(
                    'SkripsiScan',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Precision Academic Verification & Analysis',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Indikator status loading
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      children: [
                        // Wadah progress bar
                        Container(
                          height: 4,
                          width: 180,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: _progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: goldColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Initializing Archive',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.5),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningLogo(Color goldColor) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Desain buku menggunakan CustomPaint
          Positioned.fill(
            child: CustomPaint(
              painter: _BookLogoPainter(bookColor: const Color(0xFF1E5E3A)),
            ),
          ),

          // Garis laser pemindai di atas logo
          AnimatedBuilder(
            animation: _scanController,
            builder: (context, child) {
              // Menggerakkan garis laser dari atas ke bawah (0 sampai 100px)
              final topOffset = _scanController.value * 100;
              return Positioned(
                top: topOffset,
                left: 0,
                right: 0,
                child: child!,
              );
            },
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    goldColor.withOpacity(0.1),
                    goldColor,
                    goldColor.withOpacity(0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: goldColor.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookLogoPainter extends CustomPainter {
  final Color bookColor;
  _BookLogoPainter({required this.bookColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = bookColor
      ..style = PaintingStyle.fill;

    // Menggambar pola luar buku (posisi di tengah)
    final RRect bookRect = RRect.fromLTRBR(
      15, 10, size.width - 15, size.height - 10,
      const Radius.circular(8),
    );
    canvas.drawRRect(bookRect, paint);

    // Menggambar garis putih halaman di dalam buku
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.3),
      linePaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.45),
      Offset(size.width * 0.7, size.height * 0.45),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
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
