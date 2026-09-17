import 'package:flutter/services.dart';
import 'storage_service.dart';

class HapticService {
  final StorageService storageService;
  int _lastHapticMs = 0;

  HapticService(this.storageService);

  bool _shouldTrigger() {
    if (!storageService.isHapticEnabled()) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastHapticMs < 50) return false;
    _lastHapticMs = now;
    return true;
  }

  void lightImpact() {
    if (!_shouldTrigger()) return;
    HapticFeedback.lightImpact();
  }

  void mediumImpact() {
    if (!_shouldTrigger()) return;
    HapticFeedback.mediumImpact();
  }

  void heavyImpact() {
    if (!storageService.isHapticEnabled()) return;
    HapticFeedback.heavyImpact();
  }

  void errorVibration() {
    if (!storageService.isHapticEnabled()) return;
    HapticFeedback.vibrate();
  }
}
