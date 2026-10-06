import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'sqlcipher_local_database.dart';
import 'sqlcipher_local_database_error.dart';

/// Opens one encrypted database per module schema with sqflite_sqlcipher.
/// Each database has its own random 256-bit key, generated on first open and
/// kept in flutter_secure_storage — never hardcoded. Fresh installs run
/// `createStatements` (the latest schema); upgrades run every pending entry
/// of `migrations`, in version order.
///
/// Databases live in their own [directoryName] folder inside the app's
/// Application Support directory — never `Documents`, which becomes visible
/// in the Files app if file sharing is ever enabled. The host app's iOS
/// `AppDelegate` excludes that folder from iCloud/computer backups
/// (`isExcludedFromBackup`); on Android it is the app's private `files`
/// directory, which the manifest's backup rules already exclude. Keys never leave the device either ([keychainOptions]).
class SqlcipherLocalDatabaseFactory implements LocalDatabaseFactory {
  SqlcipherLocalDatabaseFactory({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(iOptions: keychainOptions);

  /// Folder inside `getApplicationSupportDirectory()` (iOS:
  /// `Library/Application Support`; Android: the app's `files`). Must match
  /// the name the host app's `AppDelegate.swift` excludes from backup. Moving it in an already released app needs a data migration.
  static const directoryName = 'local_databases';

  /// `first_unlock_this_device`: readable after the first unlock since
  /// boot — so the background sync can open the database while the device
  /// is locked — and never included in backups nor migrated to another
  /// device.
  static const keychainOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  final FlutterSecureStorage _secureStorage;
  final Map<String, Future<LocalDatabase>> _opened = {};

  @override
  Future<LocalDatabase> open(DatabaseSchema schema) =>
      _opened[schema.name] ??= _open(schema).catchError(
        (Object error, StackTrace stackTrace) {
          _opened.remove(schema.name); // let the next call try again
          Error.throwWithStackTrace(error, stackTrace);
        },
      );

  Future<LocalDatabase> _open(DatabaseSchema schema) async {
    try {
      final directory = Directory(
        '${(await getApplicationSupportDirectory()).path}/$directoryName',
      );
      await directory.create(recursive: true);
      final database = await openDatabase(
        '${directory.path}/${schema.name}',
        password: await _keyFor(schema.name),
        version: schema.version,
        onCreate: (db, _) async {
          for (final statement in schema.createStatements) {
            await db.execute(statement);
          }
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          for (var version = oldVersion + 1; version <= newVersion; version++) {
            for (final statement in schema.migrations[version] ?? const <String>[]) {
              await db.execute(statement);
            }
          }
        },
      );
      return SqlcipherLocalDatabase(database);
    } on DatabaseException catch (exception) {
      throw SqlcipherLocalDatabaseError(exception.toString());
    }
  }

  Future<String> _keyFor(String databaseName) async {
    final storageKey = 'local_database_key.$databaseName';
    final existing = await _secureStorage.read(key: storageKey);
    if (existing != null) return existing;

    final random = Random.secure();
    final key = base64UrlEncode(List<int>.generate(32, (_) => random.nextInt(256)));
    await _secureStorage.write(key: storageKey, value: key);
    return key;
  }
}
