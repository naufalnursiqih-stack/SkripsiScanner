// lib/presentation/widgets/thesis_card.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/models/thesis_model.dart';

class ThesisCard extends StatelessWidget {
  final ThesisModel thesis;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showImage;
  final bool isSelectionMode;
  final bool isSelected;

  const ThesisCard({
    super.key,
    required this.thesis,
    this.onEdit,
    this.onDelete,
    this.showImage = true,
    this.isSelectionMode = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFF855300);
    const outlineVariantColor = Color(0xFFBEC9C2);

    String fileName = 'Skripsi_Dokumen.png';
    if (thesis.imagePath.isNotEmpty) {
      fileName = thesis.imagePath.split('/').last.split('\\').last;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE2ECE6) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? const Color(0xFF1E5E3A).withOpacity(0.5) 
              : outlineVariantColor.withOpacity(0.3)
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left checkbox in selection mode
          if (isSelectionMode) ...[
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0, right: 4.0),
                child: Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? const Color(0xFF1E5E3A) : const Color(0xFFBEC9C2),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Left side: Image preview (30% of width)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFECEEF0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: outlineVariantColor.withOpacity(0.2)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: kIsWeb
                        ? const Center(
                            child: Icon(
                              Icons.image_rounded,
                              color: Color(0xFF6F7973),
                              size: 32,
                            ),
                          )
                        : (thesis.imagePath.isNotEmpty
                            ? Image.file(
                                File(thesis.imagePath),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.broken_image_rounded,
                                    color: Color(0xFF6F7973),
                                    size: 32,
                                  ),
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.image_rounded,
                                  color: Color(0xFF6F7973),
                                  size: 32,
                                ),
                              )),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.visibility_rounded, size: 14, color: goldColor),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Referensi Asli',
                        style: TextStyle(
                          color: goldColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right side: Metadata and actions (70% of width)
          Expanded(
            flex: 7,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Skripsi
                      const Text(
                        'JUDUL SKRIPSI',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3F4944),
                          fontFamily: 'Inter',
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        thesis.title.isNotEmpty ? thesis.title : fileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191C1E),
                          fontFamily: 'Inter',
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Grid of attributes
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildAttribute('NAMA', thesis.name.isNotEmpty ? thesis.name : '-'),
                                const SizedBox(height: 8),
                                _buildAttribute('TAHUN', thesis.year.isNotEmpty ? thesis.year : '-'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildAttribute('NIM', thesis.nim.isNotEmpty ? thesis.nim : '-'),
                                const SizedBox(height: 8),
                                _buildStatusBadgeWidget(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Action Buttons Column
                if (!isSelectionMode) ...[
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      if (onEdit != null)
                        GestureDetector(
                          onTap: onEdit,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEAF0EC), // soft green
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: Color(0xFF1E5E3A), // UIN Green edit icon
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      if (onDelete != null)
                        GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFDAD6), // bg-red-50 equivalent / error-container
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                              color: Color(0xFFBA1A1A),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttribute(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: Color(0xFF3F4944),
            fontFamily: 'Inter',
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191C1E),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadgeWidget() {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    switch (thesis.status) {
      case ScanStatus.success:
        bg = const Color(0xFFD1FAE5); // soft green
        fg = const Color(0xFF047857);
        icon = Icons.check_rounded;
        label = 'Berhasil';
        break;
      case ScanStatus.failed:
        bg = const Color(0xFFFFE4E6); // soft red
        fg = const Color(0xFFBE123C);
        icon = Icons.close_rounded;
        label = 'Gagal';
        break;
      case ScanStatus.processing:
        bg = const Color(0xFFFEF3C7); // soft yellow
        fg = const Color(0xFFD97706);
        icon = Icons.hourglass_empty_rounded;
        label = 'Memproses';
        break;
      case ScanStatus.pending:
        bg = const Color(0xFFF3F4F6); // soft gray
        fg = const Color(0xFF4B5563);
        icon = Icons.schedule_rounded;
        label = 'Antrean';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 10),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
