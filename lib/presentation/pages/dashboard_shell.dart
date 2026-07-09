// lib/presentation/pages/dashboard_shell.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import 'home_page.dart';
import 'review_page.dart';
import 'settings_page.dart';

class DashboardShell extends StatefulWidget {
  final int initialIndex;
  const DashboardShell({super.key, this.initialIndex = 0});

  @override
  State<DashboardShell> createState() => DashboardShellState();
}

class DashboardShellState extends State<DashboardShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _pages = [
    const HomePage(),
    const ReviewPage(),
    const SettingsPage(),
  ];

  void setTabIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definisi Warna sesuai UIN Hijau & Kuning
    const primaryGreen = Color(0xFF1E5E3A); // UIN Green untuk background pill aktif
    const goldColor = Color(0xFFFCBF48);    // UIN Gold untuk teks/ikon saat aktif
    const inactiveColor = Color(0xFF6F7973); // Abu-abu saat tidak aktif

    return Scaffold(
      backgroundColor: primaryGreen,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // Menggunakan bottomNavigationBar tapi dibungkus Padding agar MELAYANG
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Background utama navbar putih
            borderRadius: BorderRadius.circular(28), // Box container dibuat melengkung penuh
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8), // Memberikan efek bayangan melayang ke bawah
              ),
            ],
          ),
          child: SafeArea(
            // Mengurangi padding internal karena bentuknya sekarang melayang
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    index: 0,
                    icon: Icons.home_rounded,
                    label: 'Home',
                    activeBgColor: primaryGreen,
                    activeContentColor: goldColor,
                    inactiveColor: inactiveColor,
                  ),
                  _buildNavItem(
                    index: 1,
                    icon: Icons.document_scanner_rounded,
                    label: 'Review',
                    activeBgColor: primaryGreen,
                    activeContentColor: goldColor,
                    inactiveColor: inactiveColor,
                    showBadge: true,
                  ),
                  _buildNavItem(
                    index: 2,
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    activeBgColor: primaryGreen,
                    activeContentColor: goldColor,
                    inactiveColor: inactiveColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Color activeBgColor,
    required Color activeContentColor,
    required Color inactiveColor,
    bool showBadge = false,
  }) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          // Jika aktif: background Hijau UIN, jika tidak: transparan
          color: isActive ? activeBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20), // Border radius untuk pill aktif
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  // Jika aktif: warna Kuning Emas UIN, jika tidak: abu-abu
                  color: isActive ? activeContentColor : inactiveColor,
                  size: 24,
                ),
                if (showBadge)
                  Consumer<ScanProvider>(
                    builder: (context, provider, _) {
                      if (provider.items.isEmpty) return const SizedBox.shrink();
                      return Positioned(
                        top: -4,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBA1A1A),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.0),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${provider.items.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                // Teks tetap di bawah, selalu muncul, warnanya mengikuti state aktif/tidak
                color: isActive ? activeContentColor : inactiveColor,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}