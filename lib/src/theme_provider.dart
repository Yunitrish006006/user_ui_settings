import 'package:flutter/material.dart';

class UserThemeDefinition {
  const UserThemeDefinition({
    required this.id,
    required this.name,
    required this.lightTheme,
    required this.darkTheme,
    required this.primary,
    required this.secondary,
  });

  final String id;
  final String name;
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final Color primary;
  final Color secondary;
}

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({
    String defaultThemeMode = 'system',
    String defaultThemeId = 'default',
    List<UserThemeDefinition> themes = const [],
  }) : _themeModeText = _normalizeThemeMode(defaultThemeMode),
       _themes = List.unmodifiable(themes),
       _themeId = _normalizeThemeId(defaultThemeId, themes);

  String _themeModeText;
  String _themeId;
  List<UserThemeDefinition> _themes;
  int? _syncedUserId;
  _RememberedThemeSettings? _remembered;

  String get themeModeText => _themeModeText;

  String get themeId => _themeId;

  List<UserThemeDefinition> get availableThemes => _themes;

  UserThemeDefinition? get selectedTheme {
    for (final theme in _themes) {
      if (theme.id == _themeId) {
        return theme;
      }
    }
    return _themes.isEmpty ? null : _themes.first;
  }

  ThemeData get lightTheme =>
      selectedTheme?.lightTheme ??
      ThemeData(brightness: Brightness.light, useMaterial3: true);

  ThemeData get darkTheme =>
      selectedTheme?.darkTheme ??
      ThemeData(brightness: Brightness.dark, useMaterial3: true);

  ThemeMode get themeMode => switch (_themeModeText) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  /// 當 user 切換時同步設定。userId 為 null 代表登出。
  void syncForUser(int? userId, {String? themeMode, String? themeId}) {
    if (userId == _syncedUserId) {
      return;
    }
    _syncedUserId = userId;
    final nextMode = _normalizeThemeMode(themeMode);
    final nextThemeId = themeId == null
        ? _themeId
        : _normalizeThemeId(themeId, _themes);
    if (_themeModeText == nextMode && _themeId == nextThemeId) {
      return;
    }
    _themeModeText = nextMode;
    _themeId = nextThemeId;
    notifyListeners();
  }

  void setThemeModeText(String value) {
    final next = _normalizeThemeMode(value);
    if (_themeModeText == next) return;
    _themeModeText = next;
    notifyListeners();
  }

  void setThemeId(String value) {
    final next = _normalizeThemeId(value, _themes);
    if (_themeId == next) return;
    _themeId = next;
    notifyListeners();
  }

  void setAvailableThemes(
    List<UserThemeDefinition> themes, {
    String? fallbackThemeId,
  }) {
    final nextThemes = List<UserThemeDefinition>.unmodifiable(themes);
    final nextThemeId = _normalizeThemeId(
      _themeId,
      nextThemes,
      fallbackThemeId: fallbackThemeId,
    );
    if (_themes == nextThemes && _themeId == nextThemeId) return;
    _themes = nextThemes;
    _themeId = nextThemeId;
    notifyListeners();
  }

  void rememberCurrent() {
    _remembered = _RememberedThemeSettings(_themeModeText, _themeId);
  }

  void restoreRemembered() {
    final remembered = _remembered;
    if (remembered == null) return;
    _themeModeText = remembered.themeModeText;
    _themeId = _normalizeThemeId(remembered.themeId, _themes);
    _remembered = null;
    notifyListeners();
  }
}

class _RememberedThemeSettings {
  const _RememberedThemeSettings(this.themeModeText, this.themeId);

  final String themeModeText;
  final String themeId;
}

String _normalizeThemeMode(String? value) {
  return switch ((value ?? '').trim().toLowerCase()) {
    'light' => 'light',
    'dark' => 'dark',
    _ => 'system',
  };
}

String _normalizeThemeId(
  String? value,
  List<UserThemeDefinition> themes, {
  String? fallbackThemeId,
}) {
  if (themes.isEmpty) {
    return (fallbackThemeId ?? value ?? 'default').trim();
  }
  final normalized = (value ?? '').trim();
  for (final theme in themes) {
    if (theme.id == normalized) {
      return theme.id;
    }
  }
  if (fallbackThemeId != null) {
    for (final theme in themes) {
      if (theme.id == fallbackThemeId) {
        return theme.id;
      }
    }
  }
  return themes.first.id;
}
