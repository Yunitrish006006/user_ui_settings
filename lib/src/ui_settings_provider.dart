import 'package:flutter/foundation.dart';

class UiSettingsProvider extends ChangeNotifier {
  UiSettingsProvider({double defaultFontScale = 1.0})
      : _fontScale = defaultFontScale.clamp(0.8, 1.6);

  double _fontScale;
  int? _syncedUserId;
  double? _remembered;

  double get fontScale => _fontScale;

  /// 當 user 切換時同步設定。userId 為 null 代表登出。
  void syncForUser(int? userId, {double? fontScale}) {
    if (userId == _syncedUserId) return;
    _syncedUserId = userId;
    final next = (fontScale ?? 1.0).clamp(0.8, 1.6).toDouble();
    if (_fontScale == next) return;
    _fontScale = next;
    notifyListeners();
  }

  void setFontScale(double value) {
    final next = value.clamp(0.8, 1.6).toDouble();
    if (_fontScale == next) return;
    _fontScale = next;
    notifyListeners();
  }

  void rememberCurrent() {
    _remembered = _fontScale;
  }

  void restoreRemembered() {
    if (_remembered == null) return;
    _fontScale = _remembered!;
    _remembered = null;
    notifyListeners();
  }
}
