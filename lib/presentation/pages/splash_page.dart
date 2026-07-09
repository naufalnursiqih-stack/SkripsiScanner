import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  int animationPhase = 1;

  @override
  void initState() {
    super.initState();
    startPerfectTimeline();
  }

  void startPerfectTimeline() {
    Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        animationPhase = 2;
      });

      Timer(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        setState(() {
          animationPhase = 3;
        });

        Timer(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          setState(() {
            animationPhase = 4;
          });

          Timer(const Duration(milliseconds: 1500), () {
            _navigateToHome();
          });
        });
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
  Widget build(BuildContext context) {
    double screenMaxDimension = MediaQuery.of(context).size.longestSide;
    
    double circleSize = animationPhase == 1 ? 16 : screenMaxDimension * 3;
    BorderRadiusGeometry animatedRadius = animationPhase == 1 
        ? BorderRadius.circular(1000) 
        : BorderRadius.circular(0);

    Color scaffoldBgColor = animationPhase == 1 ? Colors.white : const Color(0xFF1E5E3A);

    // Ukuran akhir logo (fase 3 & 4) adalah 43
    double logoWidth = animationPhase == 1 ? 16 : (animationPhase == 2 ? 85 : 43);
    double logoHeight = animationPhase == 1 ? 18 : (animationPhase == 2 ? 96 : 48);

    double textMaskWidth = (animationPhase == 3 || animationPhase == 4) ? 180.0 : 0.0;
    double textOpacity = animationPhase == 1 || animationPhase == 2 
        ? 0.0 
        : (animationPhase == 3 ? 0.8 : 1.0);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: scaffoldBgColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            
            // BACKGROUND UTAMA
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E5E3A),
                  borderRadius: animatedRadius,
                ),
              ),
            ),

            // MEKANISME KONTEN (Logo & Teks sejajar berdampingan menggunakan Row)
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  // 1. WIDGET LOGO
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    width: logoWidth,
                    height: logoHeight,
                    child: Image.asset(
                      'assets/Group.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle
                          ),
                          child: const Icon(Icons.image, color: Colors.white, size: 20),
                        );
                      },
                    ),
                  ),

                  // Spasi antara logo dan teks yang membesar secara mulus
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    width: (animationPhase == 3 || animationPhase == 4) ? 14.0 : 0.0,
                  ),

                  // 2. WIDGET TEKS
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    width: textMaskWidth,
                    child: ClipRect(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 350),
                        opacity: textOpacity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SkripsiScan',
                              softWrap: false,
                              overflow: TextOverflow.clip,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 27,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'PINDAI. EKSTRAK. SIMPAN',
                              softWrap: false,
                              overflow: TextOverflow.clip,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w300,
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
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