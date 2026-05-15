// lib/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../widgets/custom_button.dart';
import 'scanner_page.dart';
import 'review_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildLogo(context),
              const SizedBox(height: 48),
              _buildStatsRow(context),
              const SizedBox(height: 32),
              _buildActionCards(context),
              const Spacer(),
              _buildBottomActions(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF1A56DB),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A56DB).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 16),
        const Text(
          'SkripsiScan',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
        ),
        const SizedBox(height: 6),
        Text(
          'Scan cover skripsi secara otomatis',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Consumer<ScanProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            _StatCard(
              label: 'Total Scan',
              value: '${provider.items.length}',
              icon: Icons.image_search_rounded,
              color: const Color(0xFF1A56DB),
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Berhasil',
              value: '${provider.successItems.length}',
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF0E9F6E),
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Gagal',
              value: '${provider.failedItems.length}',
              icon: Icons.error_rounded,
              color: const Color(0xFFE02424),
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
          subtitle: 'Pilih beberapa foto sekaligus',
          icon: Icons.photo_library_rounded,
          gradient: const [Color(0xFF1A56DB), Color(0xFF3B82F6)],
          onTap: () => _navigateToScanner(context, fromCamera: false),
        ),
        const SizedBox(height: 12),
        _ActionCard(
          title: 'Scan dari Kamera',
          subtitle: 'Foto langsung dari kamera',
          icon: Icons.camera_alt_rounded,
          gradient: const [Color(0xFF0E9F6E), Color(0xFF34D399)],
          onTap: () => _navigateToScanner(context, fromCamera: true),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Consumer<ScanProvider>(
      builder: (context, provider, _) {
        if (provider.items.isEmpty) return const SizedBox.shrink();
        return Column(
          children: [
            CustomButton(
              label: 'Review & Kirim (${provider.items.length} item)',
              icon: Icons.send_rounded,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReviewPage()),
              ),
            ),
            const SizedBox(height: 10),
            CustomButton(
              label: 'Hapus Semua',
              icon: Icons.delete_sweep_rounded,
              variant: ButtonVariant.outlined,
              onPressed: () => _showClearDialog(context, provider),
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
        title: const Text('Hapus Semua Data?'),
        content: const Text('Semua data scan akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              provider.clearAll();
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
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
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
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
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.3),
              blurRadius: 16,
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
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.7), size: 16),
          ],
        ),
      ),
    );
  }
}
