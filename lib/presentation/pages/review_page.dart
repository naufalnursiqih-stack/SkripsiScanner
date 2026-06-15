// lib/presentation/pages/review_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/thesis_model.dart';
import '../providers/scan_provider.dart';
import '../widgets/thesis_card.dart';
import 'edit_page.dart';
import 'dashboard_shell.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSelectionMode = false;
  final Set<String> _selectedItemIds = {};
  
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ThesisModel> _filterItems(List<ThesisModel> originalList) {
    if (_searchQuery.isEmpty) return originalList;
    final query = _searchQuery.toLowerCase();
    return originalList.where((item) {
      return item.title.toLowerCase().contains(query) ||
             item.name.toLowerCase().contains(query) ||
             item.nim.toLowerCase().contains(query) ||
             item.major.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScanProvider>();
    final items = provider.items;

    // Reset selection mode if all items are gone
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
      backgroundColor: const Color(0xFF1E5E3A), // UIN Green Background
      appBar: _isSelectionMode
          ? AppBar(
              backgroundColor: const Color(0xFF133C25), // Match navigation bar
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
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
              title: Text(
                '${_selectedItemIds.length} Terpilih',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Inter',
                ),
              ),
              actions: [
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
                      color: Color(0xFFFCBF48), // Gold for primary actions
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'delete_all') {
                      _confirmClearAll(context, provider);
                    }
                  },
                  itemBuilder: (context) => [
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
            )
          : AppBar(
              backgroundColor: const Color(0xFF1E5E3A),
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () {
                  if (_isSearching) {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  } else if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    final shellState = context.findAncestorStateOfType<DashboardShellState>();
                    shellState?.setTabIndex(0);
                  }
                },
              ),
              title: _isSearching
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Container(
                        height: 40,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: const TextStyle(
                            color: Color(0xFF191C1E),
                            fontSize: 14,
                            fontFamily: 'Inter',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Cari hasil scan...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF6F7973),
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent,
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF6F7973),
                              size: 20,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, color: Color(0xFF6F7973), size: 20),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.trim();
                            });
                          },
                        ),
                      ),
                    )
                  : const Text(
                      'Review & Kirim',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        fontFamily: 'Inter',
                      ),
                    ),
              actions: [
                if (!_isSearching)
                  IconButton(
                    icon: const Icon(Icons.search_rounded, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _isSearching = true;
                      });
                    },
                  ),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.6),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                unselectedLabelStyle: const TextStyle(fontFamily: 'Inter'),
                indicatorColor: const Color(0xFFFCBF48), // Gold indicator!
                indicatorWeight: 3.0,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Semua'),
                  Tab(text: 'Berhasil'),
                  Tab(text: 'Gagal'),
                ],
              ),
            ),
      body: Column(
        children: [
          if (provider.state == ProviderState.scanning)
            _buildProgressBar(provider),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(context, _filterItems(provider.items), provider),
                _buildList(context, _filterItems(provider.successItems), provider),
                _buildList(context, _filterItems(provider.failedItems), provider),
              ],
            ),
          ),
          if (_isSelectionMode && items.isNotEmpty)
            _buildSendBar(context, provider),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ScanProvider provider) {
    return Container(
      color: const Color(0xFF133C25), // Match navigation bar background
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Memproses ${provider.processedCount}/${provider.totalCount}…',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  color: Colors.white,
                ),
              ),
              Text(
                '${(provider.progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFFCBF48), // Gold for progress percentage
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: provider.progress,
            backgroundColor: Colors.white.withOpacity(0.12),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFFCBF48)), // Gold progress bar
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<ThesisModel> items,
    ScanProvider provider,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 56, color: Colors.white.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text(
              'Tidak ada data',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      );
    }

    final showHelper = items.length == 1;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length + (showHelper && !_isSelectionMode ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (showHelper && !_isSelectionMode && index == items.length) {
          // Render soft warning/helper card under list
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFFCBF48), // Gold icon
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hanya ada 1 item',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gunakan fitur scan untuk menambah data baru',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        final thesis = items[index];
        final isSelected = _selectedItemIds.contains(thesis.id);

        return GestureDetector(
          onTap: () {
            if (_isSelectionMode) {
              setState(() {
                if (isSelected) {
                  _selectedItemIds.remove(thesis.id);
                  if (_selectedItemIds.isEmpty) {
                    _isSelectionMode = false;
                  }
                } else {
                  _selectedItemIds.add(thesis.id);
                }
              });
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPage(thesis: thesis),
                ),
              );
            }
          },
          onLongPress: () {
            if (!_isSelectionMode) {
              setState(() {
                _isSelectionMode = true;
                _selectedItemIds.add(thesis.id);
              });
            }
          },
          child: ThesisCard(
            thesis: thesis,
            showImage: true,
            isSelectionMode: _isSelectionMode,
            isSelected: isSelected,
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPage(thesis: thesis),
                ),
              );
            },
            onDelete: () => _confirmDelete(context, thesis.id, provider),
          ),
        );
      },
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
                        color: const Color(0xFFBA1A1A).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBA1A1A).withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Color(0xFFFFDAD6),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFFFDAD6),
                                fontSize: 13,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Gold Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: (isSending || selectedSuccessItems.isEmpty) 
                          ? null 
                          : () => _sendToSheets(context, provider, selectedSuccessItems),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFCBF48), // Gold for primary action
                        foregroundColor: const Color(0xFF271900), // Dark gold text
                        disabledBackgroundColor: const Color(0xFFFCBF48).withOpacity(0.5),
                        disabledForegroundColor: const Color(0xFF271900).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFFFCBF48).withOpacity(0.3),
                      ),
                      icon: isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF271900)),
                              ),
                            )
                          : const Icon(Icons.cloud_upload_rounded),
                      label: Text(
                        isSending
                            ? 'Mengirim ke Google Sheets…'
                            : 'Kirim ${selectedSuccessItems.length} Data ke Sheets',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Clear Selected Outlined Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: isSending ? null : () => _confirmDeleteSelected(context, provider),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFDAD6),
                        side: const BorderSide(color: Color(0xFFFFDAD6), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.delete_sweep_rounded, size: 20),
                      label: const Text(
                        'Hapus Terpilih',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
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
        color: const Color(0xFF0E9F6E).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0E9F6E).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF31C780),
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Data berhasil dikirim ke Google Sheets!',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Inter',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              provider.resetState();
              setState(() {
                _isSelectionMode = false;
                _selectedItemIds.clear();
              });
              Navigator.popUntil(context, (r) => r.isFirst);
            },
            child: const Text(
              'Selesai',
              style: TextStyle(
                fontFamily: 'Inter', 
                fontWeight: FontWeight.bold,
                color: Color(0xFFFCBF48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Dialogs ────────────────────────────────────────────────────────────────

  void _confirmDelete(BuildContext context, String id, ScanProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus item ini?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Data scan ini akan dihapus secara permanen dari daftar antrean.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              provider.removeItem(id);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSelected(BuildContext context, ScanProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data Terpilih?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus ${_selectedItemIds.length} data terpilih secara permanen dari antrean?'),
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

  void _confirmClearAll(BuildContext context, ScanProvider provider) {
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

  Future<void> _sendToSheets(
    BuildContext context,
    ScanProvider provider,
    List<ThesisModel> selectedItems,
  ) async {
    final success = await provider.sendToSheets(specificItems: selectedItems);
    if (success) {
      setState(() {
        _isSelectionMode = false;
        _selectedItemIds.clear();
      });
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Pengiriman gagal.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
