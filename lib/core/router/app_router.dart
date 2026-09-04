import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/collections/collection_detail_screen.dart';
import '../../features/collections/collections_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/navigation/main_scaffold.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/wishlist/add_edit_wishlist_item_screen.dart';
import '../../features/wishlist/wishlist_item_detail_screen.dart';
import '../../features/wishlist/wishlist_screen.dart';
import '../../models/user_preferences.dart';
import '../../models/wishlist_item.dart';
import '../../providers/preferences_provider.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen<AsyncValue<UserPreferences>>(
      preferencesProvider,
      (previous, next) {
        final prevVal = previous?.asData?.value.hasCompletedOnboarding;
        final nextVal = next.asData?.value.hasCompletedOnboarding;
        if (prevVal != nextVal || previous?.isLoading != next.isLoading) {
          notifyListeners();
        }
      },
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final prefsAsync = ref.read(preferencesProvider);
      if (prefsAsync.isLoading) {
        return null;
      }
      final prefs = prefsAsync.asData?.value ?? const UserPreferences();
      final isOnboarding = state.matchedLocation == '/onboarding';
      if (!prefs.hasCompletedOnboarding && !isOnboarding) {
        return '/onboarding';
      }
      if (prefs.hasCompletedOnboarding && isOnboarding) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Home Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Branch 2: Wishlist Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wishlist',
                builder: (context, state) => const WishlistScreen(),
              ),
            ],
          ),
          // Branch 3: Collections Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/collections',
                builder: (context, state) => const CollectionsScreen(),
              ),
            ],
          ),
          // Branch 4: Profile Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Standalone Fullscreen Routes
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/add-item',
        builder: (context, state) => const AddEditWishlistItemScreen(),
      ),
      GoRoute(
        path: '/edit-item',
        builder: (context, state) {
          final item = state.extra as WishlistItem?;
          return AddEditWishlistItemScreen(initialItem: item);
        },
      ),
      GoRoute(
        path: '/item/:id',
        builder: (context, state) {
          final itemId = state.pathParameters['id']!;
          return WishlistItemDetailScreen(itemId: itemId);
        },
      ),
      GoRoute(
        path: '/collections/:id',
        builder: (context, state) {
          final colId = state.pathParameters['id']!;
          return CollectionDetailScreen(collectionId: colId);
        },
      ),
    ],
  );
});
