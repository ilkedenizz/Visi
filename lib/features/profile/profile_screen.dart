import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_preferences.dart';
import '../../models/wish_status.dart';
import '../../providers/collection_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/section_header.dart';
import '../../widgets/visi_cherry_logo.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final prefs = ref.watch(preferencesProvider).asData?.value ?? const UserPreferences();
    final wishes = ref.watch(wishlistProvider).asData?.value ?? [];
    final collections = ref.watch(collectionProvider).asData?.value ?? [];

    final totalWishes = wishes.length;
    final fulfilledWishes = wishes.where((w) => w.status == WishStatus.fulfilled).length;
    final totalCollections = collections.length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Brand Section
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.blushPink,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cherryAccent.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: VisiCherryLogo(size: 42, color: AppColors.cherryAccent),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      AppConstants.appName,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppConstants.appTagline,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Wish Journal Summary Stats Card
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(child: _buildStatColumn(context, '$totalWishes', 'Toplam Dilek')),
                    Container(height: 36, width: 1, color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                    Expanded(child: _buildStatColumn(context, '$fulfilledWishes', 'Gerçek Oldu ✨')),
                    Container(height: 36, width: 1, color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                    Expanded(child: _buildStatColumn(context, '$totalCollections', 'Koleksiyon')),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Ayarlar (Settings) Section
              const SectionHeader(title: 'Hesap & Tercihler'),
              const SizedBox(height: 8),
              Material(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.settings_outlined, color: AppColors.cherryAccent),
                        title: const Text('Uygulama Ayarları'),
                        subtitle: Text('Tema: ${_getThemeLabel(prefs.themeMode)} • Para Birimi: ${prefs.defaultCurrency}'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context.push('/settings');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Hakkında (About) Section
              const SectionHeader(title: 'Uygulama'),
              const SizedBox(height: 8),
              Material(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(Icons.info_outline_rounded, color: AppColors.cherryAccent),
                        title: Text('Visi Hakkında'),
                        subtitle: Text('Minimalist ve estetik kişisel dilek defteri.'),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(Icons.auto_awesome_outlined, color: AppColors.cherryAccent),
                        title: const Text('Tanıtım Turunu Gör'),
                        subtitle: const Text('Visi\'nin temellerini yeniden incele'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context.push('/onboarding');
                        },
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(Icons.verified_outlined, color: AppColors.cherryAccent),
                        title: const Text('Sürüm'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.blushPink,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'v1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.cherryAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.cherryAccent,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Aydınlık';
      case ThemeMode.dark:
        return 'Karanlık';
      case ThemeMode.system:
        return 'Sistem';
    }
  }
}
