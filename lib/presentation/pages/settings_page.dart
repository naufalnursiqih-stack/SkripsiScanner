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
      // KETERANGAN (Perbaikan Bug): 
      // Jika URL yang tersimpan adalah Google Spreadsheet, tampilkan di kolom input.
      // Jika bernilai bawaan/default (berupa Web App Apps Script URL), tampilkan kosong (blank).
      if (url.contains('docs.google.com/spreadsheets')) {
        _urlController.text = url;
      } else {
        _urlController.text = '';
      }
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
    await StorageService.saveSpreadsheetUrl(_urlController.text.trim()); // Memanggil fungsi dari storage service untuk menyimpan URL
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL Spreadsheet berhasil disimpan!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      backgroundColor: const Color(0xFF1E5E3A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E5E3A),
        scrolledUnderElevation: 0,
        title: const Text(
          'Pengaturan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
                    // Bagian Judul: Konfigurasi API
                    _buildSectionHeader(
                      context,
                      title: 'Konfigurasi Spreadsheet',
                      icon: Icons.settings_ethernet_rounded,
                    ),
                    const SizedBox(height: 16),
                    
                    // Kolom input teks untuk URL
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFBEC9C2).withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _urlController,
                        maxLines: 3,
                        keyboardType: TextInputType.url,
                        style: const TextStyle(
                          color: Color(0xFF191C1E),
                          fontSize: 15,
                          fontFamily: 'Inter',
                        ),
                        cursorColor: const Color(0xFF1E5E3A),
                        decoration: InputDecoration(
                          labelText: 'Google Spreadsheet URL',
                          labelStyle: const TextStyle(
                            color: Color(0xFF3F4944),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          hintText: 'https://docs.google.com/spreadsheets/d/...',
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                          alignLabelWithHint: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: const Color(0xFFBEC9C2).withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF1E5E3A), width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        validator: (value) {
                          // KETERANGAN (Perbaikan Bug):
                          // Diperbolehkan kosong agar user bisa menghapus kustomisasi
                          // dan kembali menggunakan spreadsheet bawaan aplikasi.
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          final trimmed = value.trim();
                          if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
                            return 'Format URL harus dimulai dengan http:// atau https://';
                          }
                          // Validasi memastikan input adalah URL Google Spreadsheet biasa (kustom), bukan Apps Script.
                          if (!trimmed.contains('docs.google.com/spreadsheets')) {
                            return 'Pastikan ini adalah URL Google Spreadsheet yang valid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Tombol: Simpan & Bersihkan
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _clearUrl,
                            icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.white),
                            label: const Text('Kosongkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saveUrl,
                            icon: const Icon(Icons.save_rounded, size: 18, color: Color(0xFF271900)),
                            label: const Text('Simpan', style: TextStyle(color: Color(0xFF271900), fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFCBF48), // Gold
                              foregroundColor: const Color(0xFF271900),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Bagian Judul: Profil Kelompok Pengembang
                    _buildSectionHeader(
                      context,
                      title: 'Profil Kelompok Pengembang',
                      icon: Icons.people_alt_rounded,
                    ),
                    const SizedBox(height: 16),

                    // Kartu Profil Pengembang
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
        Icon(icon, color: const Color(0xFFFCBF48), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
        border: Border.all(color: const Color(0xFFBEC9C2).withOpacity(0.3)),
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
          backgroundColor: const Color(0xFF1E5E3A).withOpacity(0.1),
          child: const Icon(
            Icons.person_rounded,
            size: 16,
            color: Color(0xFF1E5E3A),
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
