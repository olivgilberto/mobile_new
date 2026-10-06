/// Implemented by each module (data/database/) to declare its own database.
abstract interface class DatabaseSchema {
  String get name;
  int get version;
  List<String> get createStatements;

  /// Additive migrations keyed by the version they upgrade to.
  Map<int, List<String>> get migrations;
}
