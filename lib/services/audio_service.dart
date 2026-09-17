import 'package:flutter/services.dart';
import 'storage_service.dart';

class AudioService {
  final StorageService storageService;
  int _lastPlayMs = 0;

  AudioService(this.storageService);

  bool _shouldPlay() {
    if (!storageService.isSoundEnabled()) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastPlayMs < 40) return false;
    _lastPlayMs = now;
    return true;
  }

  void playTap() {
    if (!_shouldPlay()) return;
    SystemSound.play(SystemSoundType.click);
  }

  void playArrowMove() {
    if (!_shouldPlay()) return;
    SystemSound.play(SystemSoundType.click);
  }

  void playArrowExit() {
    if (!_shouldPlay()) return;
    SystemSound.play(SystemSoundType.click);
  }

  void playInvalidMove() {
    if (!storageService.isSoundEnabled()) return;
    SystemSound.play(SystemSoundType.alert);
  }

  void playLevelComplete() {
    if (!storageService.isSoundEnabled()) return;
    SystemSound.play(SystemSoundType.click);
  }

  void playLevelFailed() {
    if (!storageService.isSoundEnabled()) return;
    SystemSound.play(SystemSoundType.alert);
  }

  void playHint() {
    if (!_shouldPlay()) return;
    SystemSound.play(SystemSoundType.click);
  }

  void playUndo() {
    if (!_shouldPlay()) return;
    SystemSound.play(SystemSoundType.click);
  }

  void playKeyCollect() {
    if (!storageService.isSoundEnabled()) return;
    SystemSound.play(SystemSoundType.click);
  }
}
