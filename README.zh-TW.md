# user_ui_settings

> 📖 [English README →](README.md)

可重複使用的主題、語系與字體縮放狀態管理套件，支援 Flutter 應用程式的每位使用者同步設定。

## 功能特色

- **ThemeProvider** — 管理 light / dark / system 主題模式，依使用者 ID 進行同步
- **LocaleProvider** — 管理應用程式語系，依使用者 ID 進行同步；翻譯表由使用端 app 注入
- **UiSettingsProvider** — 管理字體縮放比例（0.8x–1.6x），依使用者 ID 進行同步

三個 Provider 共用相同模式：
- `syncForUser(int? userId, {...})` — 從 `ProxyProvider` 在認證狀態變更時呼叫；若使用者 ID 未改變則為 no-op，避免 API 重新整理覆蓋本地預覽
- `rememberCurrent()` / `restoreRemembered()` — 樂觀 UI 輔助：在套用變更前儲存狀態，發生錯誤時還原

## 快速開始

```yaml
dependencies:
  user_ui_settings: ^0.1.0
```

## 使用方式

```dart
import 'package:user_ui_settings/user_ui_settings.dart';

// 在 MultiProvider 設定中：
MultiProvider(
  providers: [
    ChangeNotifierProxyProvider<AuthService, ThemeProvider>(
      create: (_) => ThemeProvider(),
      update: (_, auth, provider) {
        final p = provider ?? ThemeProvider();
        p.syncForUser(auth.user?.id, themeMode: auth.user?.themeMode);
        return p;
      },
    ),
    ChangeNotifierProxyProvider<AuthService, UiSettingsProvider>(
      create: (_) => UiSettingsProvider(),
      update: (_, auth, provider) {
        final p = provider ?? UiSettingsProvider();
        p.syncForUser(auth.user?.id, fontScale: auth.user?.fontScale);
        return p;
      },
    ),
    ChangeNotifierProxyProvider<AuthService, LocaleProvider>(
      create: (_) => LocaleProvider(
        defaultLocale: 'zh',
        translationResolver: myTranslationForLocale, // 你自己的翻譯函式
      ),
      update: (_, auth, provider) {
        final p = provider ?? LocaleProvider(
          defaultLocale: 'zh',
          translationResolver: myTranslationForLocale,
        );
        p.syncForUser(auth.user?.id, locale: auth.user?.locale);
        return p;
      },
    ),
  ],
  child: MyApp(),
);

// 使用翻譯擴充語法：
final t = context.watch<LocaleProvider>().translation;
Text(t.text('Hello'));       // 回傳翻譯值，找不到 key 時直接回傳 key 本身
```

---

## 翻譯資源要放在哪裡？

**本套件本身不內含任何翻譯字串**，翻譯表需由使用端 app 自行提供並透過 `translationResolver` 注入。

建議的做法是將翻譯內容存成 **JSON 檔案**，放在 `assets/i18n/` 目錄下。

### 目錄結構

```
your_app/
├── assets/
│   └── i18n/
│       ├── en.json
│       ├── zh-Hant.json
│       └── ja.json
├── lib/
│   ├── l10n/
│   │   └── translations.dart   ← 快取與 resolver
│   └── main.dart
└── pubspec.yaml
```

### 註冊 assets（`pubspec.yaml`）

```yaml
flutter:
  assets:
    - assets/i18n/
```

### JSON 檔案範例（`assets/i18n/zh-Hant.json`）

```json
{
  "Hello": "哈囉",
  "Settings": "設定",
  "Theme": "主題",
  "Language": "語言",
  "Font size": "字體大小"
}
```

### 快取與 resolver（`lib/l10n/translations.dart`）

由於 `translationResolver` 是**同步函式**，JSON 必須在 app 啟動時預先載入並快取：

```dart
import 'dart:convert';
import 'package:flutter/services.dart';

// app 啟動時載入的快取
final Map<String, Map<String, String>> _cache = {};

/// 在 main() 中呼叫一次，於 runApp() 之前
Future<void> loadTranslations(List<String> locales) async {
  for (final locale in locales) {
    final raw = await rootBundle.loadString('assets/i18n/$locale.json');
    _cache[locale] = Map<String, String>.from(jsonDecode(raw));
  }
}

/// 同步的 resolver，注入給 LocaleProvider
Map<String, String> myTranslationForLocale(String locale) {
  return _cache[locale] ?? _cache['en'] ?? {};
}
```

### 啟動時載入（`lib/main.dart`）

```dart
import 'l10n/translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadTranslations(['en', 'zh-Hant', 'ja']);
  runApp(MyApp());
}
```

### 在 Widget 中取用翻譯

```dart
final t = context.watch<LocaleProvider>().translation;
Text(t.text('Settings')); // → '設定'
```

---

## API 參考

### ThemeProvider
| 成員 | 說明 |
|---|---|
| `themeMode` | `ThemeMode`，用於 `MaterialApp.themeMode` |
| `themeModeText` | `'light'`、`'dark'` 或 `'system'` |
| `syncForUser(int? userId, {String? themeMode})` | 從認證狀態同步 |
| `setThemeModeText(String)` | 更新主題 |
| `rememberCurrent()` / `restoreRemembered()` | 樂觀 UI 輔助方法 |

### UiSettingsProvider
| 成員 | 說明 |
|---|---|
| `fontScale` | `double`，範圍 0.8 ~ 1.6 |
| `syncForUser(int? userId, {double? fontScale})` | 從認證狀態同步 |
| `setFontScale(double)` | 更新縮放比例（自動 clamp） |
| `rememberCurrent()` / `restoreRemembered()` | 樂觀 UI 輔助方法 |

### LocaleProvider
| 成員 | 說明 |
|---|---|
| `locale` | 目前語系字串 |
| `translation` | 從 resolver 取得的 `Map<String, String>` |
| `syncForUser(int? userId, {String? locale})` | 從認證狀態同步 |
| `setLocale(String)` | 更新語系 |
| `rememberCurrent()` / `restoreRemembered()` | 樂觀 UI 輔助方法 |

### LocaleTranslationMap 擴充
```dart
Map<String, String>.text(String key)  // 找不到 key 時直接回傳 key 本身
```
