import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({String defaultThemeMode = 'system'})
      : _themeModeText = defaultThemeMode;

  String _themeModeText;
  int? _syncedUserId;
  String? _remembered;

  String get themeModeText => _themeModeText;

  ThemeMode get themeMode => switch (_themeModeText) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  /// 當 user 切換時同步設定。userId 為 null 代表登出。
  void syncForUser(int? userId, {String? themeMode}) {
    if (userId == _syncedUserId) return;
    _syncedUserId = userId;
    final next = themeMode ?? 'system';
    if (_themeModeText == next) return;
    _themeModeText = next;
    notifyListeners();
  }

  void setThemeModeText(String value) {
    if (_themeModeText == value) return;
    _themeModeText = value;
    notifyListeners();
  }

  void rememberCurrent() {
    _remembered = _themeModeText;
  }

  void restoreRemembered() {
    if (_remembered == null) return;
    _themeModeText = _remembered!;
    _remembered = null;
    notifyListeners();
  }
}
