import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/collections/collection_detail_screen.dart';
import '../../features/collections/collections_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/navigation/main_scaffold.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/wishlist/add_edit_wishlist_item_screen.dart';
import '../../features/wishlist/wishlist_item_detail_screen.dart';
import '../../features/wishlist/wishlist_screen.dart';
import '../../models/wishlist_item.dart';
import '../../providers/preferences_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(preferencesProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
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
