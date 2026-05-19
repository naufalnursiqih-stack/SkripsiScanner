// lib/presentation/widgets/thesis_card.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/thesis_model.dart';

class ThesisCard extends StatelessWidget {
  final ThesisModel thesis;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showImage;

  const ThesisCard({
    super.key,
    required this.thesis,
    this.onEdit,
    this.onDelete,
    this.showImage = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outline.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            if (showImage && thesis.imagePath.isNotEmpty) ...[
              _buildImage(),
              const SizedBox(height: 12),
            ],
            _buildField(
              context,
              Icons.menu_book_rounded,
              'Judul',
              thesis.title,
            ),
            _buildField(context, Icons.person_rounded, 'Nama', thesis.name),
            _buildField(context, Icons.badge_rounded, 'NIM', thesis.nim),
            _buildField(
              context,
              Icons.school_rounded,
              'Program Studi',
              thesis.major,
            ),
            if (thesis.faculty.isNotEmpty)
              _buildField(
                context,
                Icons.account_balance_rounded,
                'Fakultas',
                thesis.faculty,
              ),
            if (thesis.university.isNotEmpty)
              _buildField(
                context,
                Icons.location_city_rounded,
                'Universitas',
                thesis.university,
              ),
            if (thesis.year.isNotEmpty)
              _buildField(
                context,
                Icons.calendar_today_rounded,
                'Tahun',
                thesis.year,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildStatusBadge(),
        const Spacer(),
        if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, size: 18),
            tooltip: 'Edit',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFEFF6FF),
              foregroundColor: const Color(0xFF1A56DB),
            ),
          ),
        const SizedBox(width: 6),
        if (onDelete != null)
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_rounded, size: 18),
            tooltip: 'Hapus',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFEF2F2),
              foregroundColor: const Color(0xFFE02424),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    switch (thesis.status) {
      case ScanStatus.success:
        bg = AppTheme.statusSuccess.withOpacity(0.1);
        fg = AppTheme.statusSuccess;
        icon = Icons.check_circle_rounded;
        label = 'Berhasil';
        break;
      case ScanStatus.failed:
        bg = AppTheme.statusFailed.withOpacity(0.1);
        fg = AppTheme.statusFailed;
        icon = Icons.error_rounded;
        label = 'Gagal';
        break;
      case ScanStatus.processing:
        bg = AppTheme.statusProcessing.withOpacity(0.1);
        fg = AppTheme.statusProcessing;
        icon = Icons.hourglass_top_rounded;
        label = 'Memproses…';
        break;
      case ScanStatus.pending:
        bg = AppTheme.statusPending.withOpacity(0.1);
        fg = AppTheme.statusPending;
        icon = Icons.schedule_rounded;
        label = 'Antrian';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.file(
        File(thesis.imagePath),
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          height: 140,
          color: Colors.grey.shade100,
          child: const Center(
            child: Icon(
              Icons.broken_image_rounded,
              color: Colors.grey,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
