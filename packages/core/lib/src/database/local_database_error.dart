/// Thrown by every [LocalDatabase] method on failure, so no driver-specific
/// exception (e.g. sqflite's `DatabaseException`) ever crosses the port.
abstract interface class LocalDatabaseError implements Exception {
  String get message;
}
