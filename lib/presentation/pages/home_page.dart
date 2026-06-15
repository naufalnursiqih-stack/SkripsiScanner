// lib/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../../data/models/thesis_model.dart';
import 'scanner_page.dart';
import 'review_page.dart';
import 'dashboard_shell.dart';
import 'edit_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      body: Stack(
        children: [
          // Background Dot Grid Texture
          Positioned.fill(
            child: CustomPaint(
              painter: _DotGridPainter(),
            ),
          ),
          
          // Main Scrollable Body
          SafeArea(
            child: Column(
              children: [
                // Glassmorphic Top App Bar
                _buildTopAppBar(context),
                
                // Content Scroll View
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Card Grid Row
                        _buildStatsRow(context),
                        const SizedBox(height: 24),
                        
                        // Capture Options (Gallery / Camera)
                        _buildActionCards(context),
                        const SizedBox(height: 28),
                        
                        // Recent Activity Segment
                        _buildRecentActivity(context),
                        const SizedBox(height: 24),
                        
                        // Bottom buttons (if queue is not empty)
                        _buildBottomActions(context),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Container(
      height: 64,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFC0C9BF).withOpacity(0.2),
            width: 1.0,
          ),
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SkripsiScan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF004625),
                fontFamily: 'Inter',
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Selamat Datang',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF707971),
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Consumer<ScanProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            _StatCard(
              label: 'TOTAL SCAN',
              value: '${provider.items.length}',
              icon: Icons.search_rounded,
              iconBgColor: const Color(0xFFEFF4FF),
              iconColor: const Color(0xFF004625),
              valueColor: const Color(0xFF004625),
            ),
            const SizedBox(width: 8),
            _StatCard(
              label: 'BERHASIL',
              value: '${provider.successItems.length}',
              icon: Icons.check_circle_rounded,
              iconBgColor: const Color(0xFFE8F5E9),
              iconColor: const Color(0xFF0E9F6E),
              valueColor: const Color(0xFF0E9F6E),
            ),
            const SizedBox(width: 8),
            _StatCard(
              label: 'GAGAL',
              value: '${provider.failedItems.length}',
              icon: Icons.cancel_rounded,
              iconBgColor: const Color(0xFFFEE2E2),
              iconColor: const Color(0xFFE02424),
              valueColor: const Color(0xFFE02424),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Column(
      children: [
        _ActionCard(
          title: 'Scan dari Galeri',
          subtitle: 'Pilih dokumen yang sudah ada',
          icon: Icons.photo_library_rounded,
          gradient: const [Color(0xFF004625), Color(0xFF11512F)],
          onTap: () => _navigateToScanner(context, fromCamera: false),
        ),
        const SizedBox(height: 12),
        _ActionCard(
          title: 'Scan dari Kamera',
          subtitle: 'Ambil foto dokumen langsung',
          icon: Icons.photo_camera_rounded,
          gradient: const [Color(0xFF7D5800), Color(0xFFF9BC46)],
          onTap: () => _navigateToScanner(context, fromCamera: true),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final shellState = context.findAncestorStateOfType<DashboardShellState>();
    
    return Consumer<ScanProvider>(
      builder: (context, provider, _) {
        final recentItems = provider.items.length > 2
            ? provider.items.sublist(provider.items.length - 2)
            : provider.items;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aktivitas Terakhir',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004625),
                    fontFamily: 'Inter',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (shellState != null) {
                      shellState.setTabIndex(1); // switch tab to review list
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReviewPage()),
                      );
                    }
                  },
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7D5800),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (recentItems.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Belum ada aktivitas terbaru',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        final mockItem = ThesisModel(
                          id: 'mock-id-${DateTime.now().millisecondsSinceEpoch}',
                          imagePath: '',
                          title: 'Implementasi Artificial Intelligence dalam Klasifikasi Judul Tugas Akhir Berbasis Web',
                          name: 'Ahmad Dhani',
                          nim: '10117234',
                          year: '2024',
                          advisor: 'Dr. Sri Mulyani, M.Kom',
                          status: ScanStatus.success,
                          scannedAt: DateTime.now(),
                        );
                        context.read<ScanProvider>().addThesis(mockItem);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditPage(thesis: mockItem),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text(
                        'Simulasikan Hasil Scan (Demo)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEFF4FF),
                        foregroundColor: const Color(0xFF004625),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  // Show reverse chronological order
                  final item = recentItems[recentItems.length - 1 - index];
                  final isSuccess = item.status == ScanStatus.success;
                  
                  String fileName = 'Skripsi_Dokumen.png';
                  if (item.imagePath.isNotEmpty) {
                    fileName = item.imagePath.split('/').last.split('\\').last;
                  }

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF4FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.description_rounded,
                            color: Color(0xFF004625),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title.isNotEmpty ? item.title : fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF121C2A),
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.scannedAt.day} ${_getMonthName(item.scannedAt.month)} ${item.scannedAt.year}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSuccess ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isSuccess ? 'BERHASIL' : 'GAGAL',
                            style: TextStyle(
                              color: isSuccess ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  Widget _buildBottomActions(BuildContext context) {
    final shellState = context.findAncestorStateOfType<DashboardShellState>();
    
    return Consumer<ScanProvider>(
      builder: (context, provider, _) {
        if (provider.items.isEmpty) return const SizedBox.shrink();
        
        return Column(
          children: [
            // Gold submit action button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (shellState != null) {
                    shellState.setTabIndex(1);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReviewPage()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA900), // Rich Gold Accent
                  foregroundColor: const Color(0xFF271900),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  'Review & Kirim (${provider.items.length} Item)',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, fontFamily: 'Inter'),
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            // Outlined wipe action button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => _showClearDialog(context, provider),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE02424),
                  side: const BorderSide(color: Color(0xFFE02424), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Hapus Semua',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Inter'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToScanner(BuildContext context, {required bool fromCamera}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScannerPage(fromCamera: fromCamera),
      ),
    );
  }

  void _showClearDialog(BuildContext context, ScanProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua Data?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Semua data scan akan dihapus secara permanen dari daftar antrean.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              provider.clearAll();
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Color valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade500,
                letterSpacing: 0.5,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: valueColor,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.22),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.8), size: 24),
          ],
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC0C9BF).withOpacity(0.12)
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
