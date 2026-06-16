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
    const primaryColor = Color(0xFF1E5E3A); // UIN Green for active tab
    const goldColor = Color(0xFFFCBF48); // UIN Gold dot
    const inactiveColor = Color(0xFF6F7973); // Dark grey for inactive tabs

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Solid white background
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF004532).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: const Color(0xFFBEC9C2).withOpacity(0.3),
              width: 1.0,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'Beranda',
                  activeColor: primaryColor,
                  inactiveColor: inactiveColor,
                  goldColor: goldColor,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.document_scanner_rounded,
                  label: 'Review',
                  activeColor: primaryColor,
                  inactiveColor: inactiveColor,
                  goldColor: goldColor,
                  showBadge: true,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.settings_rounded,
                  label: 'Pengaturan',
                  activeColor: primaryColor,
                  inactiveColor: inactiveColor,
                  goldColor: goldColor,
                ),
              ],
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
    required Color activeColor,
    required Color inactiveColor,
    required Color goldColor,
    bool showBadge = false,
  }) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isActive ? activeColor : inactiveColor,
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
                color: isActive ? activeColor : inactiveColor,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 4),
            // Titik penanda untuk menu aktif
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 6 : 0,
              height: isActive ? 6 : 0,
              decoration: BoxDecoration(
                color: goldColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
