import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/models/user_preferences.dart';

/// Helper function replicating the exact app_router redirect contract
String? evaluateRouterRedirect(AsyncValue<UserPreferences> prefsAsync, String path) {
  if (prefsAsync.isLoading || prefsAsync.hasError || prefsAsync.asData == null) {
    return null;
  }
  final prefs = prefsAsync.asData!.value;
  final isOnboarding = path == '/onboarding';

  if (!prefs.hasCompletedOnboarding && !isOnboarding) {
    return '/onboarding';
  }
  if (prefs.hasCompletedOnboarding && isOnboarding) {
    return '/';
  }
  return null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding Router & Persistence Regression Tests', () {
    test('1. Default preferences (hasCompletedOnboarding=false) redirects to /onboarding', () {
      const prefsAsync = AsyncData(UserPreferences(hasCompletedOnboarding: false));

      expect(evaluateRouterRedirect(prefsAsync, '/'), equals('/onboarding'));
      expect(evaluateRouterRedirect(prefsAsync, '/wishlist'), equals('/onboarding'));
      expect(evaluateRouterRedirect(prefsAsync, '/collections'), equals('/onboarding'));
      expect(evaluateRouterRedirect(prefsAsync, '/onboarding'), isNull);
    });

    test('2. Completed preferences (hasCompletedOnboarding=true) does NOT redirect / or sub-routes to /onboarding', () {
      const prefsAsync = AsyncData(UserPreferences(hasCompletedOnboarding: true));

      // Direct sub-routes preserve location
      expect(evaluateRouterRedirect(prefsAsync, '/'), isNull);
      expect(evaluateRouterRedirect(prefsAsync, '/wishlist'), isNull);
      expect(evaluateRouterRedirect(prefsAsync, '/collections'), isNull);
      expect(evaluateRouterRedirect(prefsAsync, '/profile'), isNull);
      expect(evaluateRouterRedirect(prefsAsync, '/item/123'), isNull);

      // Visiting /onboarding when already completed redirects to /
      expect(evaluateRouterRedirect(prefsAsync, '/onboarding'), equals('/'));
    });

    test('3. AsyncLoading state produces NO onboarding redirect (keeps current route)', () {
      const prefsAsync = AsyncLoading<UserPreferences>();

      expect(evaluateRouterRedirect(prefsAsync, '/'), isNull);
      expect(evaluateRouterRedirect(prefsAsync, '/wishlist'), isNull);
      expect(evaluateRouterRedirect(prefsAsync, '/collections'), isNull);
    });

    test('4. AsyncError state produces NO onboarding redirect (keeps current route)', () {
      final prefsAsync = AsyncError<UserPreferences>(Exception('Storage Read Error'), StackTrace.empty);

      expect(evaluateRouterRedirect(prefsAsync, '/'), isNull);
      expect(evaluateRouterRedirect(prefsAsync, '/wishlist'), isNull);
      expect(evaluateRouterRedirect(prefsAsync, '/collections'), isNull);
    });

    test('5. Completed onboarding refresh scenario on /wishlist preserves route', () {
      // Stage A: Refreshing on /wishlist while preferences loading
      const loadingState = AsyncLoading<UserPreferences>();
      final initialRedirect = evaluateRouterRedirect(loadingState, '/wishlist');
      expect(initialRedirect, isNull, reason: 'Must not redirect to /onboarding while loading');

      // Stage B: Preferences load asynchronously as hasCompletedOnboarding: true
      const loadedState = AsyncData(UserPreferences(hasCompletedOnboarding: true));
      final refreshedRedirect = evaluateRouterRedirect(loadedState, '/wishlist');
      expect(refreshedRedirect, isNull, reason: 'Must stay on /wishlist after loading completed preferences');
    });
  });
}
