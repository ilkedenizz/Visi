import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_preferences.dart';
import 'storage_provider.dart';

class PreferencesNotifier extends Notifier<UserPreferences> {
  @override
  UserPreferences build() {
    final storageService = ref.watch(storageServiceProvider);
    return storageService.getPreferences();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await ref.read(storageServiceProvider).savePreferences(state);
  }

  Future<void> updateDefaultCurrency(String currency) async {
    state = state.copyWith(defaultCurrency: currency);
    await ref.read(storageServiceProvider).savePreferences(state);
  }

  Future<void> updateDefaultViewMode(ViewMode mode) async {
    state = state.copyWith(defaultViewMode: mode);
    await ref.read(storageServiceProvider).savePreferences(state);
  }

  Future<void> toggleNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await ref.read(storageServiceProvider).savePreferences(state);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(hasCompletedOnboarding: true);
    await ref.read(storageServiceProvider).savePreferences(state);
  }
}

final preferencesProvider = NotifierProvider<PreferencesNotifier, UserPreferences>(PreferencesNotifier.new);
