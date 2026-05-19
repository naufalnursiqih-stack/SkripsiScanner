// lib/core/utils/regex_helper.dart

class RegexHelper {
  RegexHelper._();

  // ─── NIM ────────────────────────────────────────────────────────────────────
  // Matches 10–12 consecutive digits, often prefixed by "NIM", "NPM", etc.
  static final _nimPrefixed = RegExp(
    r'(?:NIM|NPM|NRP|NIRM)[^\d]*(\d{10,12})',
    caseSensitive: false,
  );
  static final _nimBare = RegExp(r'\b(\d{10,12})\b');

  // ─── Name ───────────────────────────────────────────────────────────────────
  // Indonesian thesis convention: name appears after "Oleh", "Disusun Oleh", etc.
  static final _namePrefixed = RegExp(
    r"(?:Disusun\s+Oleh|Oleh\s*:?)\s*\n?\s*([A-Z][a-zA-Z .']{3,60})",
    caseSensitive: false,
  );
  // Name line that appears just ABOVE or BELOW a NIM line (heuristic fallback)
  static final _nameNearNim = RegExp(
    r"([A-Z][a-zA-Z .']{3,60})\s*\n\s*(?:NIM|NPM|NRP)[^\d]*\d{10,12}",
    caseSensitive: false,
  );

  // ─── Major ──────────────────────────────────────────────────────────────────
  static final _majorPrefixed = RegExp(
    r'(?:Program\s+Studi|Jurusan|Departemen|Prodi)\s*[:\-]?\s*([^\n]{5,80})',
    caseSensitive: false,
  );

  // ─── Faculty ─────────────────────────────────────────────────────────────────
  static final _facultyPrefixed = RegExp(
    r'(?:Fakultas)\s*[:\-]?\s*([^\n]{5,80})',
    caseSensitive: false,
  );

  // ─── Year ───────────────────────────────────────────────────────────────────
  static final _year = RegExp(r'\b(20\d{2})\b');

  // ─── University ──────────────────────────────────────────────────────────────
  static final _university = RegExp(
    r'(?:Universitas|Institut|Sekolah Tinggi|Politeknik|STMIK|STIE|STIKES)[^\n]{2,60}',
    caseSensitive: false,
  );

  /// Extracts all thesis-related fields from raw OCR text.
  static Map<String, String> extractAll(String rawText) {
    final cleaned = _cleanText(rawText);
    final lines = cleaned.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    return {
      'nim': _extractNim(cleaned),
      'name': _extractName(cleaned),
      'major': _extractMajor(cleaned),
      'faculty': _extractByRegex(cleaned, _facultyPrefixed),
      'university': _extractUniversity(cleaned),
      'year': _extractYear(cleaned),
      'title': _extractTitle(lines),
    };
  }

  // ─── Private helpers ────────────────────────────────────────────────────────

  static String _cleanText(String text) {
    // Normalize whitespace while preserving newlines for line-based parsing
    return text
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  static String _extractNim(String text) {
    final prefixed = _nimPrefixed.firstMatch(text);
    if (prefixed != null) return prefixed.group(1)?.trim() ?? '';

    final bare = _nimBare.firstMatch(text);
    return bare?.group(1)?.trim() ?? '';
  }

  static String _extractName(String text) {
    // Try "Oleh:" pattern first
    final prefixed = _namePrefixed.firstMatch(text);
    if (prefixed != null) {
      final candidate = prefixed.group(1)?.trim() ?? '';
      if (candidate.isNotEmpty) return _titleCase(candidate);
    }

    // Try name above NIM pattern
    final nearNim = _nameNearNim.firstMatch(text);
    if (nearNim != null) {
      final candidate = nearNim.group(1)?.trim() ?? '';
      if (candidate.isNotEmpty) return _titleCase(candidate);
    }

    return '';
  }

  static String _extractMajor(String text) {
    return _extractByRegex(text, _majorPrefixed);
  }

  static String _extractYear(String text) {
    final match = _year.firstMatch(text);
    return match?.group(1) ?? '';
  }

  static String _extractUniversity(String text) {
    final match = _university.firstMatch(text);
    return _titleCase(match?.group(0)?.trim() ?? '');
  }

  static String _extractByRegex(String text, RegExp pattern) {
    final match = pattern.firstMatch(text);
    return _titleCase(match?.group(1)?.trim() ?? '');
  }

  /// Identifies the thesis title heuristically:
  /// - Skips short lines and known header keywords
  /// - Returns the longest or first "ALL CAPS" multi-word block
  static String _extractTitle(List<String> lines) {
    final skipKeywords = RegExp(
      r'^(SKRIPSI|TUGAS AKHIR|LAPORAN|PROPOSAL|UNIVERSITAS|INSTITUT|'
      r'SEKOLAH TINGGI|POLITEKNIK|FAKULTAS|JURUSAN|PROGRAM STUDI|'
      r'PRODI|OLEH|NIM|NPM|NRP|NIRM|DISUSUN)',
      caseSensitive: false,
    );

    final candidates = lines
        .where((l) =>
            l.length > 15 &&
            !skipKeywords.hasMatch(l) &&
            !RegExp(r'^\d+$').hasMatch(l))
        .toList();

    if (candidates.isEmpty) return '';

    // Prefer ALL-CAPS lines (common for thesis titles in Indonesia)
    final allCaps = candidates.where((l) => l == l.toUpperCase() && l.contains(' ')).toList();
    if (allCaps.isNotEmpty) {
      // Join consecutive all-caps lines into one title
      return allCaps.take(3).join(' ').trim();
    }

    // Fallback: longest line
    candidates.sort((a, b) => b.length.compareTo(a.length));
    return candidates.first.trim();
  }

  static String _titleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .toLowerCase()
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
