import 'package:adapter_prefs_shared_preferences/adapter_prefs_shared_preferences.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSharedPreferencesAsync extends Mock implements SharedPreferencesAsync {}

void main() {
  late _MockSharedPreferencesAsync storage;
  late SharedPreferencesAppPreferences preferences;

  setUp(() {
    storage = _MockSharedPreferencesAsync();
    preferences = SharedPreferencesAppPreferences(preferences: storage);
    when(() => storage.setString(any(), any())).thenAnswer((_) async {});
  });

  test('defaults to system theme and no language until the user chooses', () async {
    when(() => storage.getString(any())).thenAnswer((_) async => null);

    expect(await preferences.themeMode(), AppThemeMode.system);
    expect(await preferences.languageCode(), isNull);
  });

  test('ignores an unknown stored theme value', () async {
    when(() => storage.getString(any())).thenAnswer((_) async => 'sepia');

    expect(await preferences.themeMode(), AppThemeMode.system);
  });

  test('saves the theme by name and emits the change', () async {
    final changes = expectLater(preferences.themeModeChanges, emits(AppThemeMode.dark));

    await preferences.saveThemeMode(AppThemeMode.dark);

    verify(() => storage.setString('app_preferences.theme_mode', 'dark')).called(1);
    await changes;
  });

  test('saves the language code and emits the change', () async {
    final changes = expectLater(preferences.languageCodeChanges, emits('pt'));

    await preferences.saveLanguageCode('pt');

    verify(() => storage.setString('app_preferences.language_code', 'pt')).called(1);
    await changes;
  });
}
