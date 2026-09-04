import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'models/user_preferences.dart';
import 'providers/preferences_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: VisiApp()));
}


class VisiApp extends ConsumerWidget {
  const VisiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final prefsAsync = ref.watch(preferencesProvider);
    final preferences = prefsAsync.asData?.value ?? const UserPreferences();

    return MaterialApp.router(
      title: 'Visi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: preferences.themeMode,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
    );
  }
}
