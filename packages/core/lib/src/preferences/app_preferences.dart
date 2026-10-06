import 'app_theme_mode.dart';

/// Non-sensitive user preferences (theme, language), read at boot right
/// after dependency injection. Never holds tokens, personal or business
/// data — those go to secure storage or a module's encrypted database.
///
/// Modules (e.g. a settings screen) only save; the host app listens to the
/// change streams and applies the new value without restarting.
abstract interface class AppPreferences {
  /// [AppThemeMode.system] until the user chooses one.
  Future<AppThemeMode> themeMode();
  Future<void> saveThemeMode(AppThemeMode mode);
  Stream<AppThemeMode> get themeModeChanges;

  /// Null until the user chooses a language — it is never inferred from
  /// the system language.
  Future<String?> languageCode();
  Future<void> saveLanguageCode(String languageCode);
  Stream<String> get languageCodeChanges;
}
