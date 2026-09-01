import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_preferences.dart';
import '../../providers/preferences_provider.dart';
import '../../widgets/section_header.dart';
import '../../widgets/visi_cherry_logo.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final prefs = ref.watch(preferencesProvider);

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
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 28),
                  ],
                ),
              ),

              // Görünüm (Appearance) Section
              const SectionHeader(title: 'Görünüm'),
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
                        leading: const Icon(Icons.wb_sunny_outlined, size: 20),
                        title: const Text('Aydınlık Tema'),
                        trailing: prefs.themeMode == ThemeMode.light
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.cherryAccent)
                            : null,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(preferencesProvider.notifier).updateThemeMode(ThemeMode.light);
                        },
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(Icons.nightlight_round, size: 20),
                        title: const Text('Karanlık Tema (Vişi Plum)'),
                        trailing: prefs.themeMode == ThemeMode.dark
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.cherryAccent)
                            : null,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(preferencesProvider.notifier).updateThemeMode(ThemeMode.dark);
                        },
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(Icons.brightness_auto_rounded, size: 20),
                        title: const Text('Sistem Teması'),
                        trailing: prefs.themeMode == ThemeMode.system
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.cherryAccent)
                            : null,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(preferencesProvider.notifier).updateThemeMode(ThemeMode.system);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tercihler (Preferences) Section
              const SectionHeader(title: 'Tercihler'),
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
                        title: const Text('Varsayılan Para Birimi'),
                        subtitle: Text(prefs.defaultCurrency),
                        trailing: DropdownButton<String>(
                          value: prefs.defaultCurrency,
                          underline: const SizedBox(),
                          items: ['₺', '\$', '€', '£', '¥'].map((c) {
                            return DropdownMenuItem(value: c, child: Text(c));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              HapticFeedback.selectionClick();
                              ref.read(preferencesProvider.notifier).updateDefaultCurrency(val);
                            }
                          },
                        ),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        title: const Text('Varsayılan Görünüm'),
                        subtitle: Text(prefs.defaultViewMode == ViewMode.grid ? 'Grid (Izgara)' : 'Liste'),
                        trailing: SegmentedButton<ViewMode>(
                          segments: const [
                            ButtonSegment(value: ViewMode.grid, icon: Icon(Icons.grid_view_rounded, size: 16)),
                            ButtonSegment(value: ViewMode.list, icon: Icon(Icons.format_list_bulleted_rounded, size: 16)),
                          ],
                          selected: {prefs.defaultViewMode},
                          onSelectionChanged: (selected) {
                            HapticFeedback.selectionClick();
                            ref.read(preferencesProvider.notifier).updateDefaultViewMode(selected.first);
                          },
                        ),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      SwitchListTile(
                        title: const Text('Bildirimler'),
                        subtitle: const Text('Hatırlatıcılar ve fiyat güncellemeleri'),
                        value: prefs.notificationsEnabled,
                        activeTrackColor: AppColors.cherryAccent,
                        onChanged: (enabled) {
                          HapticFeedback.selectionClick();
                          ref.read(preferencesProvider.notifier).toggleNotifications(enabled);
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
                        title: Text('Vişi Hakkında'),
                        subtitle: Text('Minimalist ve estetik kişisel dilek defteri.'),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(Icons.auto_awesome_outlined, color: AppColors.cherryAccent),
                        title: const Text('Tanıtım Turunu Gör'),
                        subtitle: const Text('Vişi\'nin temellerini yeniden incele'),
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
}
