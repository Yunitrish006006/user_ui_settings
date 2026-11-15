import 'package:flutter/material.dart';

/// Host-owned settings exposed to a hosted game.
///
/// This is a value object and does not persist anything. The Taiwan Brawl
/// host creates it from its providers and publishes it through
/// [GameUiSettingsScope]. Games may inject a value directly in tests or
/// standalone previews.
class GameUiSettings {
  const GameUiSettings({
    required this.locale,
    required this.themeId,
    required this.themeMode,
    required this.activeTheme,
    required this.fontScale,
    required this.disableAnimations,
    required this.accessibleNavigation,
    this.translations = const <String, String>{},
  });

  final String locale;
  final String themeId;
  final ThemeMode themeMode;
  final ThemeData activeTheme;
  final double fontScale;
  final bool disableAnimations;
  final bool accessibleNavigation;
  final Map<String, String> translations;

  String text(String key) => translations[key] ?? key;
}

/// Inherited host boundary for bundled games.
class GameUiSettingsScope extends InheritedWidget {
  const GameUiSettingsScope({
    super.key,
    required this.settings,
    required super.child,
  });

  final GameUiSettings settings;

  static GameUiSettings? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<GameUiSettingsScope>()
      ?.settings;

  static GameUiSettings of(BuildContext context) =>
      maybeOf(context) ??
      (throw FlutterError(
        'GameUiSettingsScope.of() called without a host settings scope.',
      ));

  @override
  bool updateShouldNotify(GameUiSettingsScope oldWidget) =>
      settings.locale != oldWidget.settings.locale ||
      settings.themeId != oldWidget.settings.themeId ||
      settings.themeMode != oldWidget.settings.themeMode ||
      settings.activeTheme != oldWidget.settings.activeTheme ||
      settings.fontScale != oldWidget.settings.fontScale ||
      settings.disableAnimations != oldWidget.settings.disableAnimations ||
      settings.accessibleNavigation !=
          oldWidget.settings.accessibleNavigation ||
      settings.translations != oldWidget.settings.translations;
}
