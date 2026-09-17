abstract class AdsService {
  Future<void> initialize();
  Future<bool> showRewardedAd();
  Future<bool> showInterstitialAd();
  bool isAdAvailable();
}

class OfflineAdsService implements AdsService {
  @override
  Future<void> initialize() async {
    // Offline / Mock initialization
  }

  @override
  Future<bool> showRewardedAd() async {
    // Graceful offline fallback: returns true to simulate ad reward or false if unavailable
    return false;
  }

  @override
  Future<bool> showInterstitialAd() async {
    return false;
  }

  @override
  bool isAdAvailable() {
    return false;
  }
}
