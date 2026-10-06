import 'database_schema.dart';

/// Encrypted local database port (sqflite_sqlcipher in adapter_db_sqlcipher).
/// Every method throws a [LocalDatabaseError] on failure.
abstract interface class LocalDatabase {
  Future<List<Map<String, Object?>>> query(String sql, {List<Object?>? args});
  Future<void> execute(String sql, {List<Object?>? args});
  Future<T> transaction<T>(Future<T> Function(LocalDatabase txn) action);
}

abstract interface class LocalDatabaseFactory {
  /// Opens (creating/migrating as needed) the database a module declares.
  Future<LocalDatabase> open(DatabaseSchema schema);
}
