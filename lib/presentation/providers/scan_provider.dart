// lib/presentation/providers/scan_provider.dart

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/thesis_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/ml_kit_service.dart';

enum ProviderState { idle, scanning, sending, done }

class ScanProvider extends ChangeNotifier {
  final _mlKit = MLKitService();
  final _api = ApiService();
  final _uuid = const Uuid();

  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  final List<ThesisModel> _items = [];
  List<ThesisModel> get items => List.unmodifiable(_items);

  int _processedCount = 0;
  int get processedCount => _processedCount;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ThesisModel> get successItems =>
      _items.where((t) => t.status == ScanStatus.success).toList();

  List<ThesisModel> get failedItems =>
      _items.where((t) => t.status == ScanStatus.failed).toList();

  bool get isProcessing =>
      _state == ProviderState.scanning || _state == ProviderState.sending;

  double get progress => _totalCount == 0 ? 0 : _processedCount / _totalCount;

  // ─── Scanning ────────────────────────────────────────────────────────────────

  /// Takes a list of image file paths and runs OCR on each.
  Future<void> scanImages(List<String> imagePaths) async {
    if (imagePaths.isEmpty) return;

    _state = ProviderState.scanning;
    _processedCount = 0;
    _totalCount = imagePaths.length;
    _errorMessage = null;
    notifyListeners();

    // Create pending models
    final newModels = imagePaths
        .map(
          (path) => ThesisModel(
            id: _uuid.v4(),
            imagePath: path,
            status: ScanStatus.pending,
            scannedAt: DateTime.now(),
          ),
        )
        .toList();

    _items.addAll(newModels);
    notifyListeners();

    // Process each image
    for (int i = 0; i < newModels.length; i++) {
      final idx = _items.indexWhere((t) => t.id == newModels[i].id);
      if (idx == -1) continue;

      // Mark as processing
      _items[idx] = _items[idx].copyWith(status: ScanStatus.processing);
      notifyListeners();

      final result = await _mlKit.processImage(_items[idx]);
      _items[idx] = result;
      _processedCount++;
      notifyListeners();
    }

    _state = ProviderState.idle;
    notifyListeners();
  }

  // ─── Editing ─────────────────────────────────────────────────────────────────

  void updateItem(ThesisModel updated) {
    final idx = _items.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      _items[idx] = updated;
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    _processedCount = 0;
    _totalCount = 0;
    _state = ProviderState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Sending ─────────────────────────────────────────────────────────────────

  /// Sends all successfully-scanned items to Google Sheets via batch POST.
  Future<bool> sendToSheets() async {
    final toSend = successItems;
    if (toSend.isEmpty) return false;

    _state = ProviderState.sending;
    _errorMessage = null;
    notifyListeners();

    final result = await _api.sendBatch(toSend);

    if (result.success) {
      _state = ProviderState.done;
    } else {
      _state = ProviderState.idle;
      _errorMessage = result.message;
    }

    notifyListeners();
    return result.success;
  }

  /// Sends a single item — useful for retry.
  Future<bool> retrySend(ThesisModel thesis) async {
    final result = await _api.sendThesis(thesis);
    if (!result.success) _errorMessage = result.message;
    notifyListeners();
    return result.success;
  }

  @override
  void dispose() {
    _mlKit.dispose();
    _api.dispose();
    super.dispose();
  }
}
