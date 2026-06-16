// lib/presentation/pages/edit_page.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/thesis_model.dart';
import '../../data/services/api_service.dart';
import '../providers/scan_provider.dart';
import 'scanner_page.dart';
import 'dashboard_shell.dart';

class EditPage extends StatefulWidget {
  final ThesisModel thesis;
  final bool fromScanner;

  const EditPage({
    super.key,
    required this.thesis,
    this.fromScanner = false,
  });

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController _titleController;
  late TextEditingController _nameController;
  late TextEditingController _nimController;
  late TextEditingController _majorController;
  late TextEditingController _yearController;
  late TextEditingController _advisorController;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  bool _isSaving = false;
  bool _isSavedSuccess = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.thesis.title);
    _nameController = TextEditingController(text: widget.thesis.name);
    _nimController = TextEditingController(text: widget.thesis.nim);
    _majorController = TextEditingController(text: widget.thesis.major);
    _yearController = TextEditingController(text: widget.thesis.year);
    _advisorController = TextEditingController(text: widget.thesis.advisor);

    _scrollController.addListener(() {
      if (mounted) {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _nimController.dispose();
    _majorController.dispose();
    _yearController.dispose();
    _advisorController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final provider = context.read<ScanProvider>();
    final updatedThesis = widget.thesis.copyWith(
      title: _titleController.text.trim(),
      name: _nameController.text.trim(),
      nim: _nimController.text.trim(),
      major: _majorController.text.trim(),
      year: _yearController.text.trim(),
      advisor: _advisorController.text.trim(),
      status: ScanStatus.success, // Ensure it is marked as successfully processed
    );

    // 1. Update local provider state first
    provider.updateItem(updatedThesis);

    // 2. Post to Google Sheets
    final apiService = ApiService();
    final result = await apiService.sendThesis(updatedThesis);

    if (!mounted) return;

    if (result.success) {
      setState(() {
        _isSaving = false;
        _isSavedSuccess = true;
      });

      // Tampilkan SnackBar sukses di halaman tujuan setelah pop
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Berhasil Disimpan ke Google Sheets!',
                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF137333),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardShell(initialIndex: 1),
        ),
        (route) => false,
      );
    } else {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: ${result.message}'),
          backgroundColor: const Color(0xFFBA1A1A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF004532);
    const goldColor = Color(0xFF855300);
    const errorColor = Color(0xFFBA1A1A);

    double imageScale = 1.0 + (_scrollOffset.clamp(0.0, 300.0) / 1000.0);

    return Scaffold(
      backgroundColor: const Color(0xFF1E5E3A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E5E3A),
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFBEC9C2).withOpacity(0.3),
            height: 1,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SkripsiScan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Stack(
        children: [
          // Main Scrollable Content
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 120, // Space for the fixed bottom bar
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original Scanned Image Reference Card
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBEC9C2).withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                              color: Color(0xFFECEEF0),
                            ),
                            child: Transform.scale(
                              scale: imageScale,
                              child: kIsWeb
                                  ? const Center(
                                      child: Icon(
                                        Icons.image_rounded,
                                        size: 64,
                                        color: Color(0xFF6F7973),
                                      ),
                                    )
                                  : (widget.thesis.imagePath.isNotEmpty
                                      ? Image.file(
                                          File(widget.thesis.imagePath),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(
                                                Icons.broken_image_rounded,
                                                size: 64,
                                                color: Color(0xFF6F7973),
                                              ),
                                            );
                                          },
                                        )
                                      : const Center(
                                          child: Icon(
                                            Icons.image_rounded,
                                            size: 64,
                                            color: Color(0xFF6F7973),
                                          ),
                                        )),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: const Color(0xFFFEA619).withOpacity(0.1),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: goldColor,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Referensi Gambar Asli',
                                style: TextStyle(
                                  color: Color(0xFF684000), // on-secondary-container
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Section Header
                  const Text(
                    'Review & Koreksi Data',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pastikan data di bawah ini sesuai dengan dokumen fisik.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Form Inputs
                  Column(
                    children: [
                      _CustomFormCard(
                        label: 'Judul Skripsi',
                        controller: _titleController,
                        maxLines: 3,
                        placeholder: 'Judul skripsi tidak terdeteksi, ketuk untuk mengisi manual',
                      ),
                      const SizedBox(height: 16),
                      _CustomFormCard(
                        label: 'Nama Lengkap',
                        controller: _nameController,
                        placeholder: 'Nama tidak terdeteksi, ketuk untuk mengisi manual',
                      ),
                      const SizedBox(height: 16),
                      _CustomFormCard(
                        label: 'NIM',
                        controller: _nimController,
                        placeholder: 'NIM tidak terdeteksi, ketuk untuk mengisi manual',
                      ),
                      const SizedBox(height: 16),
                      _CustomFormCard(
                        label: 'Program Studi',
                        controller: _majorController,
                        placeholder: 'Program studi tidak terdeteksi, ketuk untuk mengisi manual',
                      ),
                      const SizedBox(height: 16),
                      _CustomFormCard(
                        label: 'Tahun Kelulusan',
                        controller: _yearController,
                        placeholder: 'Tahun kelulusan tidak terdeteksi, ketuk untuk mengisi manual',
                      ),
                      const SizedBox(height: 16),
                      _CustomFormCard(
                        label: 'Dosen Pembimbing',
                        controller: _advisorController,
                        placeholder: 'Nama dosen tidak terdeteksi, ketuk untuk mengisi manual',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Cancel / Re-take button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Ambil Ulang Foto?', style: TextStyle(fontWeight: FontWeight.bold)),
                            content: const Text('Data yang sedang diedit saat ini akan dihapus dan Anda akan diarahkan kembali ke kamera.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  context.read<ScanProvider>().removeItem(widget.thesis.id);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ScannerPage(fromCamera: true),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Ambil Ulang',
                                  style: TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: errorColor,
                        size: 20,
                      ),
                      label: const Text(
                        'Batal & Ambil Ulang',
                        style: TextStyle(
                          color: errorColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: errorColor,
                        side: const BorderSide(color: errorColor, width: 2.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sticky Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF133C25), // Match navigation bar background
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1.0,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                height: 54,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isSaving || _isSavedSuccess) ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFCBF48), // Gold for primary actions
                    foregroundColor: const Color(0xFF271900), // Dark gold text
                    disabledBackgroundColor: const Color(0xFFFCBF48).withOpacity(0.5),
                    disabledForegroundColor: const Color(0xFF271900).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFFFCBF48).withOpacity(0.3),
                  ),
                  child: _buildButtonContent(),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildButtonContent() {
    if (_isSaving) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Memproses...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ],
      );
    }

    if (_isSavedSuccess) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            'Tersimpan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.table_chart_rounded, size: 20),
        SizedBox(width: 8),
        Text(
          'Simpan ke Spreadsheet',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

// Custom interactive field card with focus state listener and validation state
class _CustomFormCard extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final String placeholder;
  final bool showWarningIfEmpty;

  const _CustomFormCard({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    required this.placeholder,
  });

  @override
  State<_CustomFormCard> createState() => _CustomFormCardState();
}

class _CustomFormCardState extends State<_CustomFormCard> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _hasFocus = _focusNode.hasFocus;
        });
      }
    });
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E5E3A); // Use consistent UIN Green for active focus border
    const outlineColor = Color(0xFF6F7973);
    const outlineVariantColor = Color(0xFFBEC9C2);
    const errorColor = Color(0xFFBA1A1A);
    const errorBgColor = Color(0xFFFFDAD6);

    final isEmpty = widget.controller.text.isEmpty;
    final showWarning = widget.showWarningIfEmpty && isEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: showWarning ? errorBgColor.withOpacity(0.15) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: showWarning
              ? errorColor.withOpacity(0.2)
              : (_hasFocus ? primaryColor : outlineVariantColor.withOpacity(0.3)),
          width: _hasFocus ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: widget.maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3F4944), // text-on-surface-variant
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  maxLines: widget.maxLines,
                  style: TextStyle(
                    fontSize: 16,
                    color: showWarning ? errorColor : const Color(0xFF191C1E),
                    fontFamily: 'Inter',
                    fontWeight: widget.maxLines > 1 ? FontWeight.normal : FontWeight.w500,
                    fontStyle: showWarning ? FontStyle.italic : FontStyle.normal,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    filled: false,
                    hintText: widget.placeholder,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: showWarning ? errorColor.withOpacity(0.6) : Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.edit_outlined,
            size: 18,
            color: _hasFocus ? primaryColor : outlineColor,
          ),
        ],
      ),
    );
  }
}
