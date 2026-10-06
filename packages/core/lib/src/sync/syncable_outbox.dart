/// Implemented by each feature module that has an outbox (in its
/// `adapters/driven/`), and registered in the [OutboxRegistry] by the
/// module's own `register[X]ModuleDependencies`. The module knows its
/// database, endpoints and payloads; core only asks it to sync.
abstract interface class SyncableOutbox {
  /// Stable, human-readable name for logs (e.g. `item_module`) — never
  /// `runtimeType`, which is obfuscated in production builds.
  String get name;

  /// Sends the module's pending operations in `created_at` order, each with
  /// its `base_version`. A 409 moves the operation to `sync_conflicts` for
  /// the user to decide — never resolved here. Returns false when something
  /// is left to retry (technical failure), so the scheduler tries again.
  Future<bool> syncPending();
}
