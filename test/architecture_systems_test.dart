import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_escape/core/theme/app_design_system.dart';
import 'package:arrow_escape/models/special_mechanics.dart';
import 'package:arrow_escape/services/dynamic_showcase_manager.dart';
import 'package:arrow_escape/services/storage_service.dart';
import 'package:arrow_escape/services/analytics_service.dart';
import 'package:arrow_escape/services/monetization_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Architecture & Systems Verification Suite', () {
    test('AppDesignSystem tokens are valid', () {
      expect(AppDesignSystem.spaceMd, 16.0);
      expect(AppDesignSystem.radiusLg, 24.0);
      expect(AppDesignSystem.primaryIndigo.toARGB32(), 0xFF6366F1);
    });

    test('ArrowSpecialType required worlds resolve properly', () {
      expect(ArrowSpecialType.normal.requiredWorld, 1);
      expect(ArrowSpecialType.locked.requiredWorld, 2);
      expect(ArrowSpecialType.ice.requiredWorld, 3);
      expect(ArrowSpecialType.rotator.requiredWorld, 4);
      expect(ArrowSpecialType.switchArrow.requiredWorld, 5);
      expect(ArrowSpecialType.portal.requiredWorld, 6);
    });

    test('DynamicShowcaseManager resolves showcase card data', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();

      final showcase = DynamicShowcaseManager.resolveCurrentShowcase(storage);
      expect(showcase.ctaText.contains('LEVEL') || showcase.ctaText.contains('PLAY'), true);
    });

    test('Analytics & Monetization services execute without exceptions', () async {
      AnalyticsService.logLevelStarted(1);
      AnalyticsService.logLevelCompleted(1, 500, 0);

      final monetization = OfflineMonetizationService();
      final isAd = await monetization.isAdAvailable();
      expect(isAd, false);
    });
  });
}
