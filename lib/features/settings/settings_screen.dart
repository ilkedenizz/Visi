import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/user_preferences.dart';
import '../../providers/preferences_provider.dart';
import '../../widgets/section_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final prefsAsync = ref.watch(preferencesProvider);
    final prefs = prefsAsync.asData?.value ?? const UserPreferences();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        trailing: FittedBox(
                          child: SegmentedButton<ViewMode>(
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
