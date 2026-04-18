/// user_ui_settings
///
/// Reusable theme, locale, and font-scale state management for Flutter apps.
///
/// Usage:
/// ```dart
/// LocaleProvider(
///   defaultLocale: 'en',
///   translationResolver: myTranslationForLocale,
/// )
/// ThemeProvider()
/// UiSettingsProvider()
/// ```
/// All three providers expose a `syncForUser(int? userId, {...})` method
/// to be called from a ProxyProvider when auth state changes.
library user_ui_settings;

export 'src/locale_provider.dart';
export 'src/theme_provider.dart';
export 'src/ui_settings_provider.dart';
