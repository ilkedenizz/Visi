import 'dart:convert';
import 'package:flutter/material.dart';

enum ViewMode { grid, list }

class UserPreferences {
  final ThemeMode themeMode;
  final String defaultCurrency;
  final ViewMode defaultViewMode;
  final bool notificationsEnabled;
  final bool hasCompletedOnboarding;
  final String? lastSelectedCollectionId;

  const UserPreferences({
    this.themeMode = ThemeMode.system,
    this.defaultCurrency = '₺',
    this.defaultViewMode = ViewMode.grid,
    this.notificationsEnabled = true,
    this.hasCompletedOnboarding = false,
    this.lastSelectedCollectionId,
  });

  UserPreferences copyWith({
    ThemeMode? themeMode,
    String? defaultCurrency,
    ViewMode? defaultViewMode,
    bool? notificationsEnabled,
    bool? hasCompletedOnboarding,
    String? lastSelectedCollectionId,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      defaultViewMode: defaultViewMode ?? this.defaultViewMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      lastSelectedCollectionId: lastSelectedCollectionId ?? this.lastSelectedCollectionId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.name,
      'defaultCurrency': defaultCurrency,
      'defaultViewMode': defaultViewMode.name,
      'notificationsEnabled': notificationsEnabled,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'lastSelectedCollectionId': lastSelectedCollectionId,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    ThemeMode mode;
    switch (map['themeMode'] as String?) {
      case 'light':
        mode = ThemeMode.light;
        break;
      case 'dark':
        mode = ThemeMode.dark;
        break;
      default:
        mode = ThemeMode.system;
    }

    ViewMode view;
    switch (map['defaultViewMode'] as String?) {
      case 'list':
        view = ViewMode.list;
        break;
      default:
        view = ViewMode.grid;
    }

    return UserPreferences(
      themeMode: mode,
      defaultCurrency: (map['defaultCurrency'] as String?) ?? '₺',
      defaultViewMode: view,
      notificationsEnabled: (map['notificationsEnabled'] as bool?) ?? true,
      hasCompletedOnboarding: (map['hasCompletedOnboarding'] as bool?) ?? false,
      lastSelectedCollectionId: map['lastSelectedCollectionId'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserPreferences.fromJson(String source) =>
      UserPreferences.fromMap(json.decode(source) as Map<String, dynamic>);
}
