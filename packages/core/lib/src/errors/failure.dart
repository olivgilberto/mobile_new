/// Business error type implemented by every module's `[Name]Failure`: an
/// expected business deviation (invalid input, broken rule) the user can
/// act on. Never a technical failure — those stay core exceptions
/// (`ApiError`, `LocalDatabaseError`) and are never converted into a
/// Failure.
abstract interface class Failure {
  String get message;
}
