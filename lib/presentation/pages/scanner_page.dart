// lib/presentation/pages/scanner_page.dart

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../core/constants/app_constants.dart';
import '../providers/scan_provider.dart';
import 'review_page.dart';
import 'edit_page.dart';
import 'dashboard_shell.dart';

class ScannerPage extends StatefulWidget {
  final bool fromCamera;

  const ScannerPage({super.key, required this.fromCamera});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _picker = ImagePicker();
  final List<String> _selectedPaths = [];
  bool _isPicking = false;
  bool _isMultiPage = false; // Mode single atau multi halaman
  late AnimationController _scanController;

  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCameraInitializing = false;
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isMultiPage = !widget.fromCamera; // Pilih mode multi-page otomatis jika dari galeri

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _initializeCamera();

    // Jalankan aksi otomatis pertama kali halaman dibuka jika dari galeri
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.fromCamera) {
        _importFromGallery();
      }
    });
  }

  Future<void> _initializeCamera() async {
    if (_isCameraInitializing) return;
    setState(() {
      _isCameraInitializing = true;
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('No cameras found.');
        setState(() {
          _isCameraInitializing = false;
        });
        return;
      }

      // Cari kamera belakang
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.max,
        enableAudio: false, // Menghindari meminta izin mikrofon
      );

      await controller.initialize();
      
      // Aktifkan autofocus secara otomatis agar gambar teks tajam dan akurat untuk OCR
      try {
        await controller.setFocusMode(FocusMode.auto);
      } catch (e) {
        debugPrint('Autofocus tidak didukung: $e');
      }
      
      if (!mounted) return;

      setState(() {
        _cameraController = controller;
        _isCameraInitialized = true;
        _isCameraInitializing = false;
      });
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _isCameraInitializing = false;
        });
        _showError('Gagal mengaktifkan kamera: $e');
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_isCameraInitialized) return;

    final newMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    try {
      await _cameraController!.setFlashMode(newMode);
      setState(() {
        _flashMode = newMode;
      });
    } catch (e) {
      debugPrint('Gagal menyetel flash: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
      setState(() {
        _isCameraInitialized = false;
      });
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_isPicking) return;

    if (_isCameraInitialized && _cameraController != null) {
      setState(() => _isPicking = true);
      try {
        final photo = await _cameraController!.takePicture();
        setState(() {
          _selectedPaths.add(photo.path);
        });

        if (!_isMultiPage) {
          // Mode single: langsung mulai proses
          await _startProcessing();
        } else {
          // Mode multi: tampilkan toast pesan singkat
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
      } catch (e) {
        _showError('Gagal mengambil foto: $e');
      } finally {
        if (mounted) setState(() => _isPicking = false);
      }
    } else {
      // Fallback ke ImagePicker jika kamera internal gagal diinisialisasi
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
            await _startProcessing();
          } else {
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
  }

  Future<void> _importFromGallery() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      if (!_isMultiPage) {
        // Mode single: pilih satu gambar saja
        final photo = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 90,
        );
        if (photo != null) {
          setState(() => _selectedPaths.add(photo.path));
          await _startProcessing();
        }
      } else {
        // Mode multi: pilih banyak gambar
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
      if (_selectedPaths.length == 1) {
        // Mode single: langsung arahkan ke EditPage untuk item ini
        final newlyScannedItem = provider.items.last;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EditPage(
              thesis: newlyScannedItem,
              fromScanner: true,
            ),
          ),
        );
      } else {
        // Mode batch/multi: setelah selesai scan batch, kita kembali ke Dashboard tab Review
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const DashboardShell(initialIndex: 1),
          ),
          (route) => false,
        );
      }
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
      backgroundColor: const Color(0xFF0A100D), // warna gelap mirip kamera
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
        actions: [
          if (_isCameraInitialized && _cameraController != null)
            IconButton(
              icon: Icon(
                _flashMode == FlashMode.torch
                    ? Icons.flash_on_rounded
                    : Icons.flash_off_rounded,
                color: _flashMode == FlashMode.torch
                    ? const Color(0xFFFCBF48)
                    : Colors.white,
              ),
              onPressed: _toggleFlash,
            ),
        ],
      ),
      body: Column(
        children: [
          // Preview Kamera Terintegrasi
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Live Camera Preview atau Loading State
                Container(
                  color: const Color(0xFF070B08),
                  width: double.infinity,
                  height: double.infinity,
                  child: _isCameraInitialized && _cameraController != null
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            final camera = _cameraController!.value;
                            // Rasio aspek kamera (lanskap, e.g. 1.777) diubah ke potret (1 / 1.777 = 0.5625)
                            final cameraRatio = 1 / camera.aspectRatio;
                            
                            // Rasio aspek dari area tampilan container
                            final containerRatio = constraints.maxWidth / constraints.maxHeight;
                            
                            // Hitung skala perbesaran agar memenuhi layar tanpa merusak rasio (tidak penyok)
                            double scale = 1.0;
                            if (containerRatio > cameraRatio) {
                              scale = containerRatio / cameraRatio;
                            } else {
                              scale = cameraRatio / containerRatio;
                            }
                            
                            return ClipRect(
                              child: Transform.scale(
                                scale: scale,
                                child: Center(
                                  child: AspectRatio(
                                    aspectRatio: cameraRatio,
                                    child: CameraPreview(_cameraController!),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isCameraInitializing)
                                const CircularProgressIndicator(
                                  color: Color(0xFFFCBF48),
                                )
                              else ...[
                                Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white.withOpacity(0.04),
                                  size: 96,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Kamera sedang bersiap...',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.15),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                ),

                // Garis bantu pemosisian gambar (grid)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GridPainter(),
                  ),
                ),

                // Bingkai penanda letak dokumen
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
                  child: Container(
                    child: Stack(
                      children: [
                        // Kotak dengan garis putus-putus
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        // Siku-siku di setiap sudut bingkai
                        const Positioned(top: 0, left: 0, child: _CornerBracket(top: true, left: true)),
                        const Positioned(top: 0, right: 0, child: _CornerBracket(top: true, left: false)),
                        const Positioned(bottom: 0, left: 0, child: _CornerBracket(top: false, left: true)),
                        const Positioned(bottom: 0, right: 0, child: _CornerBracket(top: false, left: false)),

                        // Animasi garis laser berwarna emas
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

                // Teks petunjuk di atas kamera
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

          // Area tombol shutter kamera
          Container(
            color: const Color(0xFF0F172A), // Slate 900
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Switch pilihan mode scan
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

                // Baris tombol kontrol utama
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tombol Galeri (Kiri)
                    _buildGalleryButton(),

                    // Tombol Jepret Foto (Tengah)
                    _buildShutterButton(),

                    // Tombol Selesai / Review (Kanan)
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
            color: Color(0xFFFCBF48), // Tombol shutter warna emas
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

    // Menggambar garis bantu grid
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
