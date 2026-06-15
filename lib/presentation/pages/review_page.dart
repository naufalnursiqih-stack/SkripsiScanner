// lib/presentation/pages/review_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/thesis_model.dart';
import '../providers/scan_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/thesis_card.dart';
import 'edit_page.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Kirim'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Berhasil'),
            Tab(text: 'Gagal'),
          ],
        ),
      ),
      body: Consumer<ScanProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              if (provider.state == ProviderState.scanning)
                _buildProgressBar(provider),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(context, provider.items, provider),
                    _buildList(context, provider.successItems, provider),
                    _buildList(context, provider.failedItems, provider),
                  ],
                ),
              ),
              if (provider.successItems.isNotEmpty)
                _buildSendBar(context, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(ScanProvider provider) {
    return Container(
      color: Colors.white,
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
                ),
              ),
              Text(
                '${(provider.progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: provider.progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
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
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text('Tidak ada data', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final thesis = items[index];
        return ThesisCard(
          thesis: thesis,
          showImage: true,
          onEdit: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditPage(thesis: thesis),
              ),
            );
          },
          onDelete: () => _confirmDelete(context, thesis.id, provider),
        );
      },
    );
  }

  Widget _buildSendBar(BuildContext context, ScanProvider provider) {
    final isSending = provider.state == ProviderState.sending;
    final isDone = provider.state == ProviderState.done;

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
        child: isDone
            ? _buildDoneBanner(context)
            : Column(
                children: [
                  if (provider.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  CustomButton(
                    label: isSending
                        ? 'Mengirim ke Google Sheets…'
                        : 'Kirim ${provider.successItems.length} Data ke Sheets',
                    icon: Icons.cloud_upload_rounded,
                    isLoading: isSending,
                    onPressed: isSending
                        ? null
                        : () => _sendToSheets(context, provider),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDoneBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0E9F6E).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF0E9F6E),
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Data berhasil dikirim ke Google Sheets!',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0E9F6E),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            child: const Text('Selesai'),
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
        title: const Text('Hapus item ini?'),
        content: const Text('Data scan ini akan dihapus dari daftar.'),
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
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendToSheets(
    BuildContext context,
    ScanProvider provider,
  ) async {
    final success = await provider.sendToSheets();
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Pengiriman gagal.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
