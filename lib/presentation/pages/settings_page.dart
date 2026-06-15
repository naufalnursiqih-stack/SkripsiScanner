// lib/presentation/pages/settings_page.dart

import 'package:flutter/material.dart';
import '../../data/services/storage_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
  }

  Future<void> _loadSavedUrl() async {
    final url = await StorageService.getSpreadsheetUrl();
    setState(() {
      _urlController.text = url;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveUrl() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await StorageService.saveSpreadsheetUrl(_urlController.text.trim());
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL Spreadsheet berhasil disimpan!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _clearUrl() {
    setState(() {
      _urlController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kolom input dibersihkan.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Header: API Configuration
                    _buildSectionHeader(
                      context,
                      title: 'Konfigurasi Spreadsheet',
                      icon: Icons.settings_ethernet_rounded,
                    ),
                    const SizedBox(height: 16),
                    
                    // TextFormField
                    TextFormField(
                      controller: _urlController,
                      maxLines: 3,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Google Apps Script Web App URL',
                        hintText: 'https://script.google.com/macros/s/.../exec',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'URL tidak boleh kosong';
                        }
                        final trimmed = value.trim();
                        if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
                          return 'Format URL harus dimulai dengan http:// atau https://';
                        }
                        if (!trimmed.contains('script.google.com')) {
                          return 'Pastikan ini adalah URL Google Apps Script yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Buttons: Save & Clear
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _clearUrl,
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            label: const Text('Kosongkan'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saveUrl,
                            icon: const Icon(Icons.save_rounded, size: 18),
                            label: const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Section Header: Developer Profile
                    _buildSectionHeader(
                      context,
                      title: 'Profil Kelompok Pengembang',
                      icon: Icons.people_alt_rounded,
                    ),
                    const SizedBox(height: 16),

                    // Developer Card
                    _buildDeveloperCard(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDeveloperCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Proyek Akhir PPB',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Aplikasi verifikasi kelulusan & scan cover skripsi berbasis OCR.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const Divider(height: 24),
          _buildTeamMember(name: 'Naufal Nurfiqih', role: 'Developer Utama / PPB'),
          const SizedBox(height: 10),
          _buildTeamMember(name: 'Anggota Kelompok 2', role: 'Desain UI / Dokumentasi'),
          const SizedBox(height: 10),
          _buildTeamMember(name: 'Anggota Kelompok 3', role: 'Penguji Aplikasi / QA'),
        ],
      ),
    );
  }

  Widget _buildTeamMember({required String name, required String role}) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Icon(
            Icons.person_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            Text(
              role,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
