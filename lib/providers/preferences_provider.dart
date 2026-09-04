import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_preferences.dart';
import 'storage_provider.dart';

class PreferencesNotifier extends AsyncNotifier<UserPreferences> {
  @override
  Future<UserPreferences> build() async {
    final repository = ref.watch(storageRepositoryProvider);
    return await repository.loadPreferences();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    final updated = (state.asData?.value ?? const UserPreferences()).copyWith(themeMode: mode);
    state = AsyncData(updated);
    await ref.read(storageRepositoryProvider).savePreferences(updated);
  }

  Future<void> updateDefaultCurrency(String currency) async {
    final updated = (state.asData?.value ?? const UserPreferences()).copyWith(defaultCurrency: currency);
    state = AsyncData(updated);
    await ref.read(storageRepositoryProvider).savePreferences(updated);
  }

  Future<void> updateDefaultViewMode(ViewMode mode) async {
    final updated = (state.asData?.value ?? const UserPreferences()).copyWith(defaultViewMode: mode);
    state = AsyncData(updated);
    await ref.read(storageRepositoryProvider).savePreferences(updated);
  }

  Future<void> toggleNotifications(bool enabled) async {
    final updated = (state.asData?.value ?? const UserPreferences()).copyWith(notificationsEnabled: enabled);
    state = AsyncData(updated);
    await ref.read(storageRepositoryProvider).savePreferences(updated);
  }

  Future<void> completeOnboarding() async {
    final updated = (state.asData?.value ?? const UserPreferences()).copyWith(hasCompletedOnboarding: true);
    state = AsyncData(updated);
    await ref.read(storageRepositoryProvider).savePreferences(updated);
  }

  Future<void> updateLastSelectedCollectionId(String collectionId) async {
    final updated = (state.asData?.value ?? const UserPreferences()).copyWith(lastSelectedCollectionId: collectionId);
    state = AsyncData(updated);
    await ref.read(storageRepositoryProvider).savePreferences(updated);
  }
}

final preferencesProvider = AsyncNotifierProvider<PreferencesNotifier, UserPreferences>(PreferencesNotifier.new);
