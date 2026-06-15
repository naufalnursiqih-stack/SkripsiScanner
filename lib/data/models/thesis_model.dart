// lib/data/models/thesis_model.dart

import 'package:flutter/foundation.dart';

enum ScanStatus { pending, processing, success, failed }

@immutable
class ThesisModel {
  final String id;
  final String imagePath;
  final String title;
  final String name;
  final String nim;
  final String major;
  final String faculty;
  final String university;
  final String year;
  final String advisor;
  final String rawOcrText;
  final ScanStatus status;
  final String? errorMessage;
  final DateTime scannedAt;

  const ThesisModel({
    required this.id,
    required this.imagePath,
    this.title = '',
    this.name = '',
    this.nim = '',
    this.major = '',
    this.faculty = '',
    this.university = '',
    this.year = '',
    this.advisor = '',
    this.rawOcrText = '',
    this.status = ScanStatus.pending,
    this.errorMessage,
    required this.scannedAt,
  });

  factory ThesisModel.fromJson(Map<String, dynamic> json) {
    return ThesisModel(
      id: json['id'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      title: json['title'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nim: json['nim'] as String? ?? '',
      major: json['major'] as String? ?? '',
      faculty: json['faculty'] as String? ?? '',
      university: json['university'] as String? ?? '',
      year: json['year'] as String? ?? '',
      advisor: json['advisor'] as String? ?? '',
      rawOcrText: json['rawOcrText'] as String? ?? '',
      status: ScanStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ScanStatus.pending,
      ),
      errorMessage: json['errorMessage'] as String?,
      scannedAt: json['scannedAt'] != null
          ? DateTime.parse(json['scannedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'title': title,
      'name': name,
      'nim': nim,
      'major': major,
      'faculty': faculty,
      'university': university,
      'year': year,
      'advisor': advisor,
      'rawOcrText': rawOcrText,
      'status': status.name,
      'errorMessage': errorMessage,
      'scannedAt': scannedAt.toIso8601String(),
    };
  }

  /// Produces the payload sent to Google Apps Script (no internal fields).
  Map<String, dynamic> toApiPayload() {
    return {
      'title': title,
      'name': name,
      'nim': nim,
      'major': major,
      'faculty': faculty,
      'university': university,
      'year': year,
      'advisor': advisor,
      'scannedAt': scannedAt.toIso8601String(),
    };
  }

  ThesisModel copyWith({
    String? id,
    String? imagePath,
    String? title,
    String? name,
    String? nim,
    String? major,
    String? faculty,
    String? university,
    String? year,
    String? advisor,
    String? rawOcrText,
    ScanStatus? status,
    String? errorMessage,
    DateTime? scannedAt,
  }) {
    return ThesisModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      title: title ?? this.title,
      name: name ?? this.name,
      nim: nim ?? this.nim,
      major: major ?? this.major,
      faculty: faculty ?? this.faculty,
      university: university ?? this.university,
      year: year ?? this.year,
      advisor: advisor ?? this.advisor,
      rawOcrText: rawOcrText ?? this.rawOcrText,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }

  bool get hasRequiredFields => nim.isNotEmpty || name.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ThesisModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ThesisModel(id: $id, name: $name, nim: $nim, status: ${status.name})';
}
