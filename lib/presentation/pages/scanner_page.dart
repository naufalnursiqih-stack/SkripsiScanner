// lib/presentation/pages/scanner_page.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../core/constants/app_constants.dart';
import '../providers/scan_provider.dart';
import 'review_page.dart';

class ScannerPage extends StatefulWidget {
  final bool fromCamera;

  const ScannerPage({super.key, required this.fromCamera});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with SingleTickerProviderStateMixin {
  final _picker = ImagePicker();
  final List<String> _selectedPaths = [];
  bool _isPicking = false;
  bool _isMultiPage = false; // Toggles between 1 Page vs Multi Page
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _isMultiPage = !widget.fromCamera; // default to multi-page if gallery, single if camera

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Automatically trigger initial action based on home page tap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.fromCamera) {
        _captureImage();
      } else {
        _importFromGallery();
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (photo != null) {
        setState(() {
          _selectedPaths.add(photo.path);
        });

        if (!_isMultiPage) {
          // Single page: immediately start processing
          await _startProcessing();
        } else {
          // Multi page: show quick toast feedback
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Halaman berhasil ditambahkan!'),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Color(0xFF004625),
              ),
            );
          }
        }
      }
    } catch (e) {
      _showError('Gagal mengakses kamera: $e');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _importFromGallery() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      if (!_isMultiPage) {
        // Single page mode: Pick single image
        final photo = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 90,
        );
        if (photo != null) {
          setState(() => _selectedPaths.add(photo.path));
          await _startProcessing();
        }
      } else {
        // Multi page mode: Pick multiple assets
        final assets = await AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            maxAssets: AppConstants.maxBatchSize - _selectedPaths.length,
            requestType: RequestType.image,
            gridCount: 3,
            pageSize: 80,
          ),
        );

        if (assets != null && assets.isNotEmpty) {
          final paths = <String>[];
          for (final asset in assets) {
            final file = await asset.originFile;
            if (file != null) paths.add(file.path);
          }
          setState(() => _selectedPaths.addAll(paths));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${assets.length} foto ditambahkan dari galeri.'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF004625),
              ),
            );
          }
        }
      }
    } catch (e) {
      _showError('Gagal membuka galeri: $e');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _startProcessing() async {
    if (!mounted) return;
    if (_selectedPaths.isEmpty) return;

    final provider = context.read<ScanProvider>();
    await provider.scanImages(_selectedPaths);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ReviewPage()),
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _removeImage(int index) {
    setState(() => _selectedPaths.removeAt(index));
  }

  void _showCapturedImagesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A100D), // dark matching viewfinder
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Halaman Terpilih (${_selectedPaths.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_selectedPaths.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Text(
                          'Belum ada halaman yang difoto',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 130,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedPaths.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: kIsWeb
                                    ? Container(
                                        width: 90,
                                        height: 130,
                                        color: Colors.grey.shade800,
                                        child: const Center(
                                          child: Icon(Icons.image_rounded, color: Colors.white70),
                                        ),
                                      )
                                    : Image.file(
                                        File(_selectedPaths[index]),
                                        width: 90,
                                        height: 130,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _removeImage(index));
                                    setModalState(() {});
                                    if (_selectedPaths.isEmpty) {
                                      Navigator.pop(ctx);
                                    }
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black87,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF004625),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                  if (_selectedPaths.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _startProcessing();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFCBF48),
                          foregroundColor: const Color(0xFF004625),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.document_scanner_rounded),
                        label: const Text(
                          'Mulai Ekstraksi OCR Sekarang',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Pindai Sampul',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Camera Viewfinder Mockup
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Dark Camera Overlay Background
                Container(
                  color: const Color(0xFF070B08),
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white.withOpacity(0.04),
                          size: 96,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lensa Kamera Aktif',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.15),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Rule-of-Thirds Grid Overlay
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GridPainter(),
                  ),
                ),

                // Dotted Document Frame Guide
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
                  child: Container(
                    child: Stack(
                      children: [
                        // Dotted Border Box
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        // Corner Brackets
                        const Positioned(top: 0, left: 0, child: _CornerBracket(top: true, left: true)),
                        const Positioned(top: 0, right: 0, child: _CornerBracket(top: true, left: false)),
                        const Positioned(bottom: 0, left: 0, child: _CornerBracket(top: false, left: true)),
                        const Positioned(bottom: 0, right: 0, child: _CornerBracket(top: false, left: false)),

                        // Animated Gold Laser Line
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedBuilder(
                              animation: _scanController,
                              builder: (context, child) {
                                return Align(
                                  alignment: Alignment(0.0, -1.0 + (_scanController.value * 2.0)),
                                  child: child!,
                                );
                              },
                              child: Container(
                                height: 3,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xFFFCBF48).withOpacity(0.9),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFCBF48).withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Header Guidance Overlay
                Positioned(
                  top: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Posisikan cover skripsi di dalam bingkai',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Shutter Control Area
          Container(
            color: const Color(0xFF0F172A), // Slate 900
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mode Toggle Switch
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModeToggleItem(
                        label: '1 Halaman',
                        active: !_isMultiPage,
                        onTap: () => setState(() => _isMultiPage = false),
                      ),
                      _buildModeToggleItem(
                        label: 'Banyak Halaman',
                        active: _isMultiPage,
                        onTap: () => setState(() => _isMultiPage = true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Shutter Control Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Import Gallery Button (Left)
                    _buildGalleryButton(),

                    // Shutter Trigger (Center)
                    _buildShutterButton(),

                    // Process/Review Thumbnail (Right)
                    _buildReviewDoneButton(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggleItem({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFCBF48) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF004625) : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _importFromGallery,
          icon: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 28),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Galeri',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildShutterButton() {
    return GestureDetector(
      onTap: _captureImage,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFCBF48), // Gold shutter
          ),
          child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF004625), size: 28),
        ),
      ),
    );
  }

  Widget _buildReviewDoneButton() {
    final hasImages = _selectedPaths.isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: hasImages ? _showCapturedImagesSheet : null,
              icon: hasImages
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: kIsWeb
                          ? Container(
                              width: 28,
                              height: 28,
                              color: Colors.grey.shade800,
                              child: const Center(
                                child: Icon(Icons.image_rounded, color: Colors.white70, size: 14),
                              ),
                            )
                          : Image.file(
                              File(_selectedPaths.last),
                              width: 28,
                              height: 28,
                              fit: BoxFit.cover,
                            ),
                    )
                  : const Icon(Icons.check_circle_outline_rounded, color: Colors.grey, size: 28),
              style: IconButton.styleFrom(
                backgroundColor: hasImages ? Colors.transparent : Colors.white.withOpacity(0.05),
                padding: hasImages ? const EdgeInsets.all(8) : const EdgeInsets.all(12),
                side: hasImages ? const BorderSide(color: Color(0xFFFCBF48), width: 1.5) : null,
              ),
            ),
            if (hasImages)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Color(0xFF004625),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${_selectedPaths.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Selesai',
          style: TextStyle(
            color: hasImages ? Colors.white : Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1.0;

    // Draw grid rule-of-thirds lines
    canvas.drawLine(Offset(size.width / 3, 0), Offset(size.width / 3, size.height), paint);
    canvas.drawLine(Offset(size.width * 2 / 3, 0), Offset(size.width * 2 / 3, size.height), paint);

    canvas.drawLine(Offset(0, size.height / 3), Offset(size.width, size.height / 3), paint);
    canvas.drawLine(Offset(0, size.height * 2 / 3), Offset(size.width, size.height * 2 / 3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CornerBracket extends StatelessWidget {
  final bool top;
  final bool left;
  const _CornerBracket({required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFFCBF48);
    const double length = 24.0;
    const double thickness = 3.0;

    return SizedBox(
      width: length,
      height: length,
      child: Stack(
        children: [
          Positioned(
            top: top ? 0 : null,
            bottom: !top ? 0 : null,
            left: 0,
            right: 0,
            child: Container(
              height: thickness,
              decoration: BoxDecoration(
                color: goldColor,
                borderRadius: BorderRadius.circular(thickness / 2),
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: left ? 0 : null,
            right: !left ? 0 : null,
            child: Container(
              width: thickness,
              decoration: BoxDecoration(
                color: goldColor,
                borderRadius: BorderRadius.circular(thickness / 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
