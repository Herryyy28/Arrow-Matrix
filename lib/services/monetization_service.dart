import 'package:flutter/foundation.dart';

abstract class MonetizationService {
  Future<bool> isAdAvailable();
  Future<bool> showRewardedAdForHint();
  Future<bool> showRewardedAdForContinue();
}

/// Offline implementation of MonetizationService.
class OfflineMonetizationService implements MonetizationService {
  @override
  Future<bool> isAdAvailable() async => false;

  @override
  Future<bool> showRewardedAdForHint() async {
    if (kDebugMode) {
      debugPrint('[Monetization] Offline mode: Ad unavailable');
    }
    return false;
  }

  @override
  Future<bool> showRewardedAdForContinue() async {
    if (kDebugMode) {
      debugPrint('[Monetization] Offline mode: Ad unavailable');
    }
    return false;
  }
}
