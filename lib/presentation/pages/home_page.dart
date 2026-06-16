// lib/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  // Konstanta Desain Global untuk Harmonisasi Visual
  static const double _globalRadius = 16.0; // Poin 2: Konsistensi Corner Radius
  static const Color _uinGreen = Color(0xFF1E5E3A);
  static const Color _uinGold = Color(0xFFFCBF48);
  static const Color _cardBgDark = Color(0xFF133C25);

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
          Positioned.fill(
            child: CustomPaint(
              painter: _DotGridPainter(),
            ),
          ),
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
                        // Poin 3: Tombol Aksi Utama naik ke atas (Hierarki Pertama setelah App Bar)
                        _buildActionGrid(context),
                        const SizedBox(height: 24),

                        _buildStatsRow(context),
                        const SizedBox(height: 28),
                        
                        // Riwayat Aktivitas beserta Search Bar di dalamnya
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

  Widget _buildTopAppBar(BuildContext context, ScanProvider provider) {
    final items = provider.items;

    if (_isSelectionMode) {
      return Container(
        height: 64,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: _cardBgDark,
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
                fontFamily: 'Inter',
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
                  fontFamily: 'Inter',
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
      height: 64,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.transparent,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SkripsiScan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Inter',
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Selamat Datang',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Poin 3: Search bar dimodifikasi agar harmonis dan diletakkan di atas list aktivitas
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_globalRadius), // Poin 2: Mengikuti radius global
        border: Border.all(
          color: const Color(0xFFBEC9C2).withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          color: Color(0xFF191C1E),
          fontSize: 14,
          fontFamily: 'Inter',
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
            color: Color(0xFF6F7973),
            fontSize: 14,
            fontFamily: 'Inter',
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF6F7973),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Color(0xFF6F7973)),
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

  Widget _buildStatsRow(BuildContext context) {
    return Consumer<ScanProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            _StatCard(
              label: 'TOTAL SCAN',
              value: '${provider.items.length}',
              icon: Icons.search_rounded,
              iconBgColor: const Color(0xFFEAF0EC),
              iconColor: _uinGreen,
              valueColor: _uinGreen,
              globalRadius: _globalRadius, // Poin 2
            ),
            const SizedBox(width: 8),
            _StatCard(
              label: 'BERHASIL',
              value: '${provider.successItems.length}',
              icon: Icons.check_circle_rounded,
              iconBgColor: const Color(0xFFD1FAE5),
              iconColor: const Color(0xFF059669),
              valueColor: const Color(0xFF059669),
              globalRadius: _globalRadius, // Poin 2
            ),
            const SizedBox(width: 8),
            _StatCard(
              label: 'GAGAL',
              value: '${provider.failedItems.length}',
              icon: Icons.cancel_rounded,
              iconBgColor: const Color(0xFFFFE4E6),
              iconColor: const Color(0xFFE11D48),
              valueColor: const Color(0xFFE11D48),
              globalRadius: _globalRadius, // Poin 2
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return Row(
      children: [
        // ====== TOMBOL IMPORT GAMBAR ======
        Expanded(
          child: AspectRatio(
            aspectRatio: 1.0,
            child: InkWell(
              onTap: () => _navigateToScanner(context, fromCamera: false),
              borderRadius: BorderRadius.circular(_globalRadius),
              child: Container(
                decoration: BoxDecoration(
                  color: _cardBgDark,
                  borderRadius: BorderRadius.circular(_globalRadius), // Poin 2: Diubah ke 16.0
                  border: Border.all(
                    color: _uinGold.withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _uinGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: _uinGold,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8), // Poin 4: Jarak dirapatkan dari 12 ke 8 agar padat
                    const Text(
                      'Import Gambar',
                      style: TextStyle(
                        color: Colors.white, // Poin 1: Diubah ke Putih Bersih demi Aksesibilitas
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // ====== TOMBOL SCAN KAMERA ======
        Expanded(
          child: AspectRatio(
            aspectRatio: 1.0,
            child: InkWell(
              onTap: () => _navigateToScanner(context, fromCamera: true),
              borderRadius: BorderRadius.circular(_globalRadius),
              child: Container(
                decoration: BoxDecoration(
                  color: _cardBgDark,
                  borderRadius: BorderRadius.circular(_globalRadius), // Poin 2: Diubah ke 16.0
                  border: Border.all(
                    color: _uinGold.withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _uinGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        color: _uinGold,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8), // Poin 4: Jarak dirapatkan dari 12 ke 8 agar padat
                    const Text(
                      'Scan Kamera',
                      style: TextStyle(
                        color: Colors.white, // Poin 1: Diubah ke Putih Bersih demi Aksesibilitas
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Poin 3 & Heuristic Layout: Penggabungan Search Bar ke dalam konteks Aktivitas Terakhir
  Widget _buildRecentActivitySection(BuildContext context) {
    final shellState = context.findAncestorStateOfType<DashboardShellState>();
    
    return Consumer<ScanProvider>(
      builder: (context, provider, _) {
        final List<ThesisModel> displayItems;
        if (_searchQuery.isEmpty) {
          final rawRecent = provider.items.length > 2
              ? provider.items.sublist(provider.items.length - 2)
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
                const Text(
                  'Aktivitas Terakhir',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Inter',
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
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _uinGold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Kolom Search diletakkan di sini agar secara konteks sinkron dengan penyaringan data di bawahnya
            _buildSearchBar(context),
            const SizedBox(height: 16),

            if (displayItems.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(_globalRadius),
                  border: Border.all(color: const Color(0xFFBEC9C2).withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _searchQuery.isEmpty
                        ? 'Belum ada aktivitas terbaru'
                        : 'Tidak ada hasil pencarian untuk "$_searchQuery"',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontFamily: 'Inter',
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
                              style: const TextStyle(color: Color(0xFFBA1A1A), fontSize: 13, fontFamily: 'Inter'),
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
                        backgroundColor: _uinGreen,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _uinGreen.withOpacity(0.8),
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        shadowColor: _uinGreen.withOpacity(0.3),
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
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
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
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
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
              style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0E9F6E), fontFamily: 'Inter'),
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
            child: const Text('Selesai', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: _uinGreen)),
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Color valueColor;
  final double globalRadius; // Poin 2

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.valueColor,
    required this.globalRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        // Poin 4: Padding atas/bawah simetris 16px untuk memastikan angka tepat di tengah vertikal
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(globalRadius), // Poin 2: Radius sinkron 16.0
          border: Border.all(color: const Color(0xFFBEC9C2).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Poin 4: Distribusi center secara vertikal
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6F7973),
                letterSpacing: 0.5,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20, // Sedikit ditingkatkan nilainya agar lebih pop-out
                fontWeight: FontWeight.bold,
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