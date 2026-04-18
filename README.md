# user_ui_settings

> 📖 [繁體中文說明請看這裡 →](README.zh-TW.md)

Reusable theme, locale, and font-scale state management for Flutter apps with per-user sync.

## Features

- **ThemeProvider** — manages light/dark/system theme mode, syncs per user ID
- **LocaleProvider** — manages app locale, syncs per user ID, translation table injected by the consuming app
- **UiSettingsProvider** — manages font scale (0.8x–1.6x), syncs per user ID

All three providers share the same pattern:
- `syncForUser(int? userId, {...})` — called from a `ProxyProvider` when auth state changes; no-ops if the user ID hasn't changed, preventing API refreshes from overwriting local previews
- `rememberCurrent()` / `restoreRemembered()` — for optimistic UI: save state before applying a change, restore on error

## Getting started

```yaml
dependencies:
  user_ui_settings: ^0.1.0
```

## Usage

```dart
import 'package:user_ui_settings/user_ui_settings.dart';

// In your MultiProvider setup:
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
        defaultLocale: 'en',
        translationResolver: myTranslationForLocale, // your own function
      ),
      update: (_, auth, provider) {
        final p = provider ?? LocaleProvider(
          defaultLocale: 'en',
          translationResolver: myTranslationForLocale,
        );
        p.syncForUser(auth.user?.id, locale: auth.user?.locale);
        return p;
      },
    ),
  ],
  child: MyApp(),
);

// Using translation with the extension:
final t = context.watch<LocaleProvider>().translation;
Text(t.text('Hello'));       // returns 'Hello' or key itself if missing
```

---

## Where to put translation resources

**This package does not bundle any translation strings.** You provide them in your own app via `translationResolver`.

The recommended approach is to store translations as **JSON files** under `assets/i18n/`.

### Directory structure

```
your_app/
├── assets/
│   └── i18n/
│       ├── en.json
│       ├── zh-Hant.json
│       └── ja.json
├── lib/
│   ├── l10n/
│   │   └── translations.dart   ← cache + resolver
│   └── main.dart
└── pubspec.yaml
```

### Register assets (`pubspec.yaml`)

```yaml
flutter:
  assets:
    - assets/i18n/
```

### JSON file example (`assets/i18n/en.json`)

```json
{
  "Hello": "Hello",
  "Settings": "Settings",
  "Theme": "Theme",
  "Language": "Language",
  "Font size": "Font size"
}
```

### Cache + resolver (`lib/l10n/translations.dart`)

Because `translationResolver` is **synchronous**, JSON files must be pre-loaded and cached before use:

```dart
import 'dart:convert';
import 'package:flutter/services.dart';

// Cache loaded at app startup
final Map<String, Map<String, String>> _cache = {};

/// Call this once in main() before runApp()
Future<void> loadTranslations(List<String> locales) async {
  for (final locale in locales) {
    final raw = await rootBundle.loadString('assets/i18n/$locale.json');
    _cache[locale] = Map<String, String>.from(jsonDecode(raw));
  }
}

/// Synchronous resolver to inject into LocaleProvider
Map<String, String> myTranslationForLocale(String locale) {
  return _cache[locale] ?? _cache['en'] ?? {};
}
```

### Load at startup (`lib/main.dart`)

```dart
import 'l10n/translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadTranslations(['en', 'zh-Hant', 'ja']);
  runApp(MyApp());
}
```

### Using in a widget

```dart
final t = context.watch<LocaleProvider>().translation;
Text(t.text('Settings')); // → 'Settings'
```

---

## API

### ThemeProvider
| Member | Description |
|---|---|
| `themeMode` | `ThemeMode` for `MaterialApp.themeMode` |
| `themeModeText` | `'light'`, `'dark'`, or `'system'` |
| `syncForUser(int? userId, {String? themeMode})` | Sync from auth state |
| `setThemeModeText(String)` | Update theme |
| `rememberCurrent()` / `restoreRemembered()` | Optimistic UI helpers |

### UiSettingsProvider
| Member | Description |
|---|---|
| `fontScale` | `double` between 0.8 and 1.6 |
| `syncForUser(int? userId, {double? fontScale})` | Sync from auth state |
| `setFontScale(double)` | Update scale (auto-clamped) |
| `rememberCurrent()` / `restoreRemembered()` | Optimistic UI helpers |

### LocaleProvider
| Member | Description |
|---|---|
| `locale` | Current locale string |
| `translation` | `Map<String, String>` from your resolver |
| `syncForUser(int? userId, {String? locale})` | Sync from auth state |
| `setLocale(String)` | Update locale |
| `rememberCurrent()` / `restoreRemembered()` | Optimistic UI helpers |

### LocaleTranslationMap extension
```dart
Map<String, String>.text(String key)  // returns key itself if not found
```
