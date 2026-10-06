import 'package:core/core.dart';

/// Translation of sqflite's `DatabaseException` into core's
/// [LocalDatabaseError]: the only error type that leaves this package.
class SqlcipherLocalDatabaseError implements LocalDatabaseError {
  const SqlcipherLocalDatabaseError(this.message);

  @override
  final String message;

  @override
  String toString() => 'SqlcipherLocalDatabaseError($message)';
}
