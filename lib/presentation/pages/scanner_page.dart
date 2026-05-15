// lib/presentation/pages/scanner_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../core/constants/app_constants.dart';
import '../providers/scan_provider.dart';
import '../widgets/custom_button.dart';
import 'review_page.dart';

class ScannerPage extends StatefulWidget {
  final bool fromCamera;

  const ScannerPage({super.key, required this.fromCamera});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final _picker = ImagePicker();
  final List<String> _selectedPaths = [];
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.fromCamera) {
        _pickFromCamera();
      } else {
        _pickFromGallery();
      }
    });
  }

  Future<void> _pickFromGallery() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final assets = await AssetPicker.pickAssets(
        context,
        pickerConfig: const AssetPickerConfig(
          maxAssets: AppConstants.maxBatchSize,
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
        if (mounted) setState(() => _selectedPaths.addAll(paths));
      }
    } catch (e) {
      _showError('Gagal membuka galeri: $e');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _pickFromCamera() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      while (true) {
        final photo = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 90,
        );

        if (photo == null) break;

        setState(() => _selectedPaths.add(photo.path));

        if (!mounted) break;

        final continueCapture = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Foto ditambahkan!'),
            content: Text('${_selectedPaths.length} foto dipilih. Ambil foto lagi?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Selesai')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Foto Lagi')),
            ],
          ),
        );

        if (continueCapture != true) break;
      }
    } catch (e) {
      _showError('Gagal mengakses kamera: $e');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _startProcessing() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fromCamera ? 'Kamera' : 'Pilih Foto'),
        actions: [
          if (_selectedPaths.isNotEmpty)
            TextButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.add_photo_alternate_rounded),
              label: const Text('Tambah'),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedPaths.isEmpty)
            Expanded(child: _buildEmptyState())
          else
            Expanded(child: _buildImageGrid()),
          if (_selectedPaths.isNotEmpty) _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isPicking ? Icons.hourglass_top_rounded : Icons.image_search_rounded,
            size: 72,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _isPicking ? 'Membuka…' : 'Belum ada foto dipilih',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
          const SizedBox(height: 24),
          if (!_isPicking)
            CustomButton(
              label: widget.fromCamera ? 'Buka Kamera' : 'Pilih dari Galeri',
              icon: widget.fromCamera ? Icons.camera_alt_rounded : Icons.photo_library_rounded,
              fullWidth: false,
              onPressed: widget.fromCamera ? _pickFromCamera : _pickFromGallery,
            ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '${_selectedPaths.length} foto dipilih',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _selectedPaths.length,
            itemBuilder: (context, index) => _buildThumbnail(index),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail(int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(_selectedPaths[index]),
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Consumer<ScanProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: CustomButton(
              label: provider.isProcessing
                  ? 'Memproses…'
                  : 'Mulai Scan (${_selectedPaths.length} foto)',
              icon: Icons.document_scanner_rounded,
              isLoading: provider.isProcessing,
              onPressed: provider.isProcessing ? null : _startProcessing,
            ),
          ),
        );
      },
    );
  }
}
