// lib/presentation/pages/edit_page.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/thesis_model.dart';
import '../../data/services/api_service.dart';
import '../providers/scan_provider.dart';

class EditPage extends StatefulWidget {
  final ThesisModel thesis;

  const EditPage({super.key, required this.thesis});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController _titleController;
  late TextEditingController _nameController;
  late TextEditingController _nimController;
  late TextEditingController _yearController;
  late TextEditingController _advisorController;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  bool _isSaving = false;
  bool _isSavedSuccess = false;
  bool _showToast = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.thesis.title);
    _nameController = TextEditingController(text: widget.thesis.name);
    _nimController = TextEditingController(text: widget.thesis.nim);
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
        _showToast = true;
      });

      // Hide toast and navigate back after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showToast = false;
          });
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      });
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
    const primaryColor = Color(0xFF004625);
    const goldColor = Color(0xFFFCBF48);
    const errorColor = Color(0xFFBA1A1A);
    const surfaceDimColor = Color(0xFFECEEEB);

    // Compute parallax image scale based on scroll offset
    double imageScale = 1.0 + (_scrollOffset.clamp(0.0, 300.0) / 1000.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SkripsiScan',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
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
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Academic gold accent border
                        Container(
                          height: 4,
                          color: goldColor,
                        ),
                        // Image wrapper with square aspect ratio and parallax scale zoom
                        AspectRatio(
                          aspectRatio: 1.0,
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                              color: Color(0xFFECEEEB),
                            ),
                            child: Transform.scale(
                              scale: imageScale,
                              child: kIsWeb
                                  ? const Center(
                                      child: Icon(
                                        Icons.image_rounded,
                                        size: 64,
                                        color: Color(0xFF707971),
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
                                                color: Color(0xFF707971),
                                              ),
                                            );
                                          },
                                        )
                                      : const Center(
                                          child: Icon(
                                            Icons.image_rounded,
                                            size: 64,
                                            color: Color(0xFF707971),
                                          ),
                                        )),
                            ),
                          ),
                        ),
                        // Label bottom bar
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.visibility_rounded,
                                color: goldColor,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Referensi Gambar Asli',
                                style: TextStyle(
                                  color: Color(0xFF7D5800), // on-secondary-container-like gold
                                  fontSize: 12,
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

                  // Section Header
                  const Text(
                    'Review & Koreksi Data',
                    style: TextStyle(
                      color: Color(0xFF191C1B),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pastikan data di bawah ini sesuai dengan dokumen fisik.',
                    style: TextStyle(
                      color: Color(0xFF404941),
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Form Inputs
                  Column(
                    children: [
                      _CustomFormCard(
                        label: 'Judul Skripsi',
                        icon: Icons.description_rounded,
                        controller: _titleController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _CustomFormCard(
                        label: 'Nama Lengkap',
                        icon: Icons.person_rounded,
                        controller: _nameController,
                      ),
                      const SizedBox(height: 16),
                      _CustomFormCard(
                        label: 'NIM',
                        icon: Icons.badge_rounded,
                        controller: _nimController,
                      ),
                      const SizedBox(height: 16),
                      _CustomFormCard(
                        label: 'Tahun Kelulusan',
                        icon: Icons.calendar_today_rounded,
                        controller: _yearController,
                      ),
                      const SizedBox(height: 16),
                      _CustomFormCard(
                        label: 'Dosen Pembimbing',
                        icon: Icons.work_rounded,
                        controller: _advisorController,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Cancel / Re-take button
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context),
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
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: const Border(
                  top: BorderSide(
                    color: Color(0xFFC0C9BF),
                    width: 1.0,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isSaving || _isSavedSuccess) ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _isSavedSuccess
                        ? primaryColor.withOpacity(0.8)
                        : primaryColor.withOpacity(0.6),
                    disabledForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _buildButtonContent(),
                ),
              ),
            ),
          ),

          // Floating Success Toast (Fade-in and Slide animation)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            bottom: _showToast ? 108 : -100,
            left: 20,
            right: 20,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showToast ? 1.0 : 0.0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EA), // soft green
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCEEAD6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF137333),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Berhasil Disimpan!',
                            style: TextStyle(
                              color: Color(0xFF137333),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Data telah masuk ke Google Sheets.',
                            style: TextStyle(
                              color: Color(0xFF137333),
                              fontSize: 12,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
          SizedBox(width: 8),
          Text(
            'Tersimpan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

// Custom interactive field card with focus state listener
class _CustomFormCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final int maxLines;

  const _CustomFormCard({
    required this.label,
    required this.icon,
    required this.controller,
    this.maxLines = 1,
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
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _hasFocus = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF004625);
    const outlineVariantColor = Color(0xFFC0C9BF);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hasFocus ? primaryColor : outlineVariantColor,
          width: _hasFocus ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(30, 94, 58, 0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: _hasFocus ? primaryColor : const Color(0xFF404941),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _hasFocus ? primaryColor : const Color(0xFF404941),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            maxLines: widget.maxLines,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF191C1B),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              filled: false,
            ),
          ),
        ],
      ),
    );
  }
}
