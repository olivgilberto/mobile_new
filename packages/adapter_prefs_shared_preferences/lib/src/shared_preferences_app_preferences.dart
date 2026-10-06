import 'dart:async';

import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [AppPreferences] backed by shared_preferences (`SharedPreferencesAsync`).
/// Holds non-sensitive values only (theme, language) — never tokens,
/// personal or business data. Every save is also emitted on the matching
/// change stream, so the host app applies it without restarting.
class SharedPreferencesAppPreferences implements AppPreferences {
  SharedPreferencesAppPreferences({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  static const _themeModeKey = 'app_preferences.theme_mode';
  static const _languageCodeKey = 'app_preferences.language_code';

  final SharedPreferencesAsync _preferences;
  final _themeModeChanges = StreamController<AppThemeMode>.broadcast();
  final _languageCodeChanges = StreamController<String>.broadcast();

  @override
  Future<AppThemeMode> themeMode() async {
    final stored = await _preferences.getString(_themeModeKey);
    return AppThemeMode.values.asNameMap()[stored] ?? AppThemeMode.system;
  }

  @override
  Future<void> saveThemeMode(AppThemeMode mode) async {
    await _preferences.setString(_themeModeKey, mode.name);
    _themeModeChanges.add(mode);
  }

  @override
  Stream<AppThemeMode> get themeModeChanges => _themeModeChanges.stream;

  @override
  Future<String?> languageCode() => _preferences.getString(_languageCodeKey);

  @override
  Future<void> saveLanguageCode(String languageCode) async {
    await _preferences.setString(_languageCodeKey, languageCode);
    _languageCodeChanges.add(languageCode);
  }

  @override
  Stream<String> get languageCodeChanges => _languageCodeChanges.stream;
}
