// lib/presentation/pages/onboarding_page.dart

import 'package:flutter/material.dart';
import 'dashboard_shell.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingModel> _slides = [
    OnboardingModel(
      title: 'Ambil Foto Cover',
      description: 'Arahkan kamera ke sampul skripsi. Kami akan mendeteksi informasi secara otomatis.',
      imageUrl: 'assets/onboarding_1.png',
      hasScanningOverlay: true,
    ),
    OnboardingModel(
      title: 'Ekstraksi AI',
      description: 'Teknologi cerdas kami mengenali judul, penulis, dan data penting lainnya dalam hitungan detik.',
      imageUrl: 'assets/onboarding_2.png',
      hasScanningOverlay: false,
    ),
    OnboardingModel(
      title: 'Ekspor Langsung',
      description: 'Simpan hasil scan langsung ke Google Sheets Anda untuk manajemen data skripsi yang lebih rapi.',
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
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
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
    const primaryColor = Color(0xFF004625); // Deep Green
    const secondaryColor = Color(0xFFFCBF48); // Gold

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SkripsiScan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                      fontFamily: 'Inter',
                    ),
                  ),
                  if (_currentIndex < _slides.length - 1)
                    TextButton(
                      onPressed: _onSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF707971),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text(
                        'Lewati',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48, height: 36), // Balanced spacing
                ],
              ),
            ),

            // Sliding Views
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image Container
                        Expanded(
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFC0C9BF).withOpacity(0.3)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.04),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Main Illustration Image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        slide.imageUrl,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade100,
                                            child: const Icon(
                                              Icons.image_rounded,
                                              size: 64,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    // Decorative scanning overlay for Step 1
                                    if (slide.hasScanningOverlay)
                                      const _ScanningOverlay(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title & Subtitle text
                        Text(
                          slide.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                            letterSpacing: -0.5,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            slide.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF404941),
                              height: 1.5,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Pagination Indicator & Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
                      final isActive = index == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? secondaryColor : const Color(0xFFC0C9BF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        foregroundColor: const Color(0xFF271900),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
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
                  
                  // Step Label
                  Text(
                    'Langkah ${_currentIndex + 1} dari ${_slides.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF707971),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            // Dotted HUD Corners
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green.withOpacity(0.12), width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            
            // Custom HUD Corners (Decorative)
            const Positioned(
              top: 0, left: 0,
              child: _CornerBorder(top: true, left: true),
            ),
            const Positioned(
              top: 0, right: 0,
              child: _CornerBorder(top: true, left: false),
            ),
            const Positioned(
              bottom: 0, left: 0,
              child: _CornerBorder(top: false, left: true),
            ),
            const Positioned(
              bottom: 0, right: 0,
              child: _CornerBorder(top: false, left: false),
            ),

            // Moving Scan Line
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
                    colors: [
                      Colors.transparent,
                      goldColor.withOpacity(0.8),
                      Colors.transparent,
                    ],
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
