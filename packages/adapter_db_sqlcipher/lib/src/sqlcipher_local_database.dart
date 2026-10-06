import 'package:core/core.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'sqlcipher_local_database_error.dart';

/// [LocalDatabase] over an open SQLCipher database or one of its
/// transactions. Driver exceptions never cross the port.
class SqlcipherLocalDatabase implements LocalDatabase {
  SqlcipherLocalDatabase(this._executor);

  final DatabaseExecutor _executor;

  @override
  Future<List<Map<String, Object?>>> query(String sql, {List<Object?>? args}) =>
      _guard(() => _executor.rawQuery(sql, args));

  @override
  Future<void> execute(String sql, {List<Object?>? args}) =>
      _guard(() => _executor.execute(sql, args));

  @override
  Future<T> transaction<T>(Future<T> Function(LocalDatabase txn) action) {
    final executor = _executor;
    // Already inside a transaction: join it instead of nesting.
    if (executor is! Database) return action(this);
    return _guard(
      () => executor.transaction((txn) => action(SqlcipherLocalDatabase(txn))),
    );
  }

  Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on DatabaseException catch (exception) {
      throw SqlcipherLocalDatabaseError(exception.toString());
    }
  }
}
