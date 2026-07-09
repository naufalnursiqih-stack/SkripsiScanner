import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../providers/scan_provider.dart';
import '../../data/models/thesis_model.dart';
import 'scanner_page.dart';
import 'review_page.dart';
import 'dashboard_shell.dart';
import 'edit_page.dart';
import '../widgets/thesis_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSelectionMode = false;
  final Set<String> _selectedItemIds = {};

  // Konstanta Desain Global sesuai UI mockup gambar
  static const double _globalRadius = 16.0; 
  static const Color _uinGreen = Color(0xFF1E5E3A); // Disamakan dengan warna hijau halaman lainnya
  static const Color _uinGold = Color(0xFFFCBF48);
  static const Color _cardBgDark = Color(0xFF144627); // Warna hijau kontainer tombol utama
  static const Color _actionIconBg = Color(0xFFEAB308); // Warna kuning emas ikon box atas

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScanProvider>();
    final items = provider.items;

    if (items.isEmpty && _isSelectionMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isSelectionMode = false;
            _selectedItemIds.clear();
          });
        }
      });
    }

    return Scaffold(
      backgroundColor: _uinGreen,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildTopAppBar(context, provider),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildActionGrid(context),
                        const SizedBox(height: 20),
                        _buildStatsRow(context),
                        const SizedBox(height: 28),
                        _buildRecentActivitySection(context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                if (_isSelectionMode && items.isNotEmpty)
                  _buildSendBar(context, provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Bagian Atas: Teks rata kiri + Lonceng Notifikasi di pojok kanan (Bebas Error Const)
  Widget _buildTopAppBar(BuildContext context, ScanProvider provider) {
    final items = provider.items;

    if (_isSelectionMode) {
      return Container(
        height: 64,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: const Color(0xFF133C25),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () {
                if (provider.state == ProviderState.done) {
                  provider.resetState();
                }
                setState(() {
                  _isSelectionMode = false;
                  _selectedItemIds.clear();
                });
              },
            ),
            const SizedBox(width: 8),
            Text(
              '${_selectedItemIds.length} Terpilih',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selectedItemIds.length == items.length) {
                    _selectedItemIds.clear();
                    _isSelectionMode = false;
                  } else {
                    _selectedItemIds.addAll(items.map((e) => e.id));
                  }
                });
              },
              child: Text(
                _selectedItemIds.length == items.length ? 'Batal Semua' : 'Pilih Semua',
                style: const TextStyle(
                  color: _uinGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
              onSelected: (value) {
                if (value == 'delete_all') {
                  _showClearDialog(context, provider);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'delete_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever_rounded, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Hapus Semua'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SkripsiScan',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Selamat Datang ',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text('👋', style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF114223),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFBEC9C2).withOpacity(0.1),
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim();
          });
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.transparent,
          hintText: 'Cari riwayat dokumen...',
          hintStyle: const TextStyle(
            color: Colors.white60,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Colors.white60,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.white60),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  // 2. Statistik: Box putih utuh tunggal dibagi 3 kolom dengan Divider garis vertikal tipis
  Widget _buildStatsRow(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_globalRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Consumer<ScanProvider>(
        builder: (context, provider, _) {
          return Row(
            children: [
              Expanded(
                child: _buildSingleStatItem(
                  label: 'TOTAL SCAN',
                  value: '${provider.items.length}',
                  icon: Icons.search,
                  iconBgColor: const Color(0xFFEAF5EE),
                  iconColor: const Color(0xFF0C3A1D),
                  valueColor: const Color(0xFF0C3A1D),
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
              Expanded(
                child: _buildSingleStatItem(
                  label: 'BERHASIL',
                  value: '${provider.successItems.length}',
                  icon: Icons.check_circle_rounded,
                  iconBgColor: const Color(0xFFE6F7ED),
                  iconColor: const Color(0xFF10B981),
                  valueColor: const Color(0xFF10B981),
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
              Expanded(
                child: _buildSingleStatItem(
                  label: 'GAGAL',
                  value: '${provider.failedItems.length}',
                  icon: Icons.cancel_rounded,
                  iconBgColor: const Color(0xFFFFEAEB),
                  iconColor: const Color(0xFFEF4444),
                  valueColor: const Color(0xFFEF4444),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSingleStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required Color valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // 3. Tombol Utama Grid: Kotak vertikal berlatar hijau tua, berikon kuning, berpanah pojok kanan bawah
  Widget _buildActionGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            title: 'Scan Kamera',
            description: 'Scan cover secara langsung',
            icon: Icons.camera_alt_outlined,
            onTap: () => _navigateToScanner(context, fromCamera: true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            title: 'Import dari Galeri',
            description: 'Pilih gambar dari galeri',
            icon: Icons.image_outlined,
            onTap: () => _importFromGalleryDirect(context),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_globalRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 175,
        decoration: BoxDecoration(
          color: _cardBgDark,
          borderRadius: BorderRadius.circular(_globalRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _actionIconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF0C3A1D), size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                Icons.arrow_forward_rounded,
                color: Colors.amber,
                size: 18,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    final shellState = context.findAncestorStateOfType<DashboardShellState>();
    
    return Consumer<ScanProvider>(
      builder: (context, provider, _) {
        final List<ThesisModel> displayItems;
        if (_searchQuery.isEmpty) {
          final rawRecent = provider.items.length > 3
              ? provider.items.sublist(provider.items.length - 3)
              : provider.items;
          displayItems = rawRecent.reversed.toList();
        } else {
          final rawFiltered = provider.items.where((item) {
            final query = _searchQuery.toLowerCase();
            return item.title.toLowerCase().contains(query) ||
                   item.name.toLowerCase().contains(query) ||
                   item.nim.toLowerCase().contains(query);
          }).toList();
          displayItems = rawFiltered.reversed.toList();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aktivitas Terakhir',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
                TextButton(
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
                  child: const Row(
                    children: [
                      Text(
                        'Lihat Semua ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _uinGold,
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 12, color: _uinGold),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _buildSearchBar(context),
            const SizedBox(height: 16),

            if (displayItems.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF114223),
                  borderRadius: BorderRadius.circular(_globalRadius),
                ),
                child: Center(
                  child: Text(
                    _searchQuery.isEmpty
                        ? 'Belum ada aktivitas terbaru'
                        : 'Tidak ada hasil pencarian untuk "$_searchQuery"',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayItems.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = displayItems[index];
                  final isSelected = _selectedItemIds.contains(item.id);
                  return GestureDetector(
                    onTap: () {
                      if (_isSelectionMode) {
                        setState(() {
                          if (isSelected) {
                            _selectedItemIds.remove(item.id);
                            if (_selectedItemIds.isEmpty) {
                              _isSelectionMode = false;
                            }
                          } else {
                            _selectedItemIds.add(item.id);
                          }
                        });
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditPage(thesis: item),
                          ),
                        );
                      }
                    },
                    onLongPress: () {
                      if (!_isSelectionMode) {
                        setState(() {
                          _isSelectionMode = true;
                          _selectedItemIds.add(item.id);
                        });
                      }
                    },
                    child: ThesisCard(
                      thesis: item,
                      showImage: true,
                      isSelectionMode: _isSelectionMode,
                      isSelected: isSelected,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditPage(thesis: item),
                          ),
                        );
                      },
                      onDelete: () => _showDeleteConfirmDialog(context, item, provider),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  void _navigateToScanner(BuildContext context, {required bool fromCamera}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScannerPage(fromCamera: fromCamera),
      ),
    );
    if (result == true && context.mounted) {
      final shellState = context.findAncestorStateOfType<DashboardShellState>();
      shellState?.setTabIndex(1);
    }
  }

  Future<void> _importFromGalleryDirect(BuildContext context) async {
    try {
      final provider = context.read<ScanProvider>();
      final assets = await AssetPicker.pickAssets(
        context,
        pickerConfig: const AssetPickerConfig(
          maxAssets: 20,
          requestType: RequestType.image,
          gridCount: 3,
          pageSize: 90,
        ),
      );

      if (assets != null && assets.isNotEmpty) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const Center(
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF0C3A1D)),
                    SizedBox(height: 16),
                    Text(
                      'Mengekstrak teks skripsi...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0C3A1D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        final paths = <String>[];
        for (final asset in assets) {
          var file = await asset.originFile;
          file ??= await asset.file;
          if (file != null) {
            paths.add(file.path);
          }
        }

        if (paths.isEmpty) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal memuat file gambar dari galeri.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        await provider.scanImages(paths);

        if (!context.mounted) return;
        Navigator.pop(context);

        if (paths.length == 1) {
          final newlyScannedItem = provider.items.last;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditPage(
                thesis: newlyScannedItem,
                fromScanner: true,
              ),
            ),
          );
        } else {
          final shellState = context.findAncestorStateOfType<DashboardShellState>();
          if (shellState != null) {
            shellState.setTabIndex(1);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReviewPage()),
            );
          }
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka galeri: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showDeleteConfirmDialog(BuildContext context, ThesisModel thesis, ScanProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus data "${thesis.title.isNotEmpty ? thesis.title : 'Dokumen'}" dari riwayat?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              provider.removeItem(thesis.id);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
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
              setState(() {
                _isSelectionMode = false;
                _selectedItemIds.clear();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Hapus Semua', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showBatchDeleteDialog(BuildContext context, ScanProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data Terpilih?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus ${_selectedItemIds.length} data scan terpilih dari riwayat?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              for (final id in _selectedItemIds) {
                provider.removeItem(id);
              }
              setState(() {
                _isSelectionMode = false;
                _selectedItemIds.clear();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSendBar(BuildContext context, ScanProvider provider) {
    final isSending = provider.state == ProviderState.sending;
    final isDone = provider.state == ProviderState.done;
    final selectedSuccessItems = provider.items
        .where((t) => _selectedItemIds.contains(t.id) && t.status == ScanStatus.success)
        .toList();

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: const Color(0xFFBEC9C2).withOpacity(0.3))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: isDone
            ? _buildDoneBanner(context, provider)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (provider.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDAD6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBA1A1A).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Color(0xFFBA1A1A), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.errorMessage!,
                              style: const TextStyle(color: Color(0xFFBA1A1A), fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: (isSending || selectedSuccessItems.isEmpty) 
                          ? null 
                          : () => _sendToSheets(context, provider, selectedSuccessItems),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C3A1D),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF0C3A1D).withOpacity(0.8),
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        shadowColor: const Color(0xFF0C3A1D).withOpacity(0.3),
                      ),
                      icon: isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.cloud_upload_rounded),
                      label: Text(
                        isSending ? 'Mengirim ke Google Sheets…' : 'Kirim ${selectedSuccessItems.length} Data ke Sheets',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: isSending ? null : () => _showBatchDeleteDialog(context, provider),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFBA1A1A),
                        side: const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.delete_sweep_rounded, size: 20),
                      label: const Text(
                        'Hapus Terpilih',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDoneBanner(BuildContext context, ScanProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0E9F6E).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF0E9F6E), size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Data berhasil dikirim ke Google Sheets!',
              style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0E9F6E)),
            ),
          ),
          TextButton(
            onPressed: () {
              provider.resetState();
              setState(() {
                _isSelectionMode = false;
                _selectedItemIds.clear();
              });
            },
            child: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0C3A1D))),
          ),
        ],
      ),
    );
  }

  Future<void> _sendToSheets(BuildContext context, ScanProvider provider, List<ThesisModel> selectedItems) async {
    final success = await provider.sendToSheets(specificItems: selectedItems);
    if (success) {
      setState(() {
        _isSelectionMode = false;
        _selectedItemIds.clear();
      });
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Pengiriman gagal.'), backgroundColor: Colors.red),
      );
    }
  }
}
