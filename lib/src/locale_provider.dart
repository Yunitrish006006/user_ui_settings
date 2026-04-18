import 'package:flutter/foundation.dart';

/// 擴充方法：讓 Map<String, String> 支援 t.text('key') 語法。
/// 找不到 key 時直接回傳 key 本身，避免 null 問題。
extension LocaleTranslationMap on Map<String, String> {
  String text(String key) => this[key] ?? key;
}

/// 管理目前語系，並透過注入的 [translationResolver] 查詢翻譯表。
/// 翻譯內容本身留在各 app，package 只管狀態。
class LocaleProvider extends ChangeNotifier {
  LocaleProvider({
    required String defaultLocale,
    required Map<String, String> Function(String locale) translationResolver,
  })  : _locale = defaultLocale,
        _defaultLocale = defaultLocale,
        _resolver = translationResolver;

  final String _defaultLocale;
  final Map<String, String> Function(String) _resolver;

  String _locale;
  int? _syncedUserId;
  String? _remembered;

  String get locale => _locale;

  Map<String, String> get translation => _resolver(_locale);

  /// 當 user 切換時同步設定。userId 為 null 代表登出（重設回預設語系）。
  void syncForUser(int? userId, {String? locale}) {
    if (userId == _syncedUserId) return;
    _syncedUserId = userId;
    final next = locale ?? _defaultLocale;
    if (_locale == next) return;
    _locale = next;
    notifyListeners();
  }

  void setLocale(String value) {
    if (_locale == value) return;
    _locale = value;
    notifyListeners();
  }

  void rememberCurrent() {
    _remembered = _locale;
  }

  void restoreRemembered() {
    if (_remembered == null) return;
    _locale = _remembered!;
    _remembered = null;
    notifyListeners();
  }
}
