import 'outbox_registry.dart';
import 'syncable_outbox.dart';

/// Tech-free default implementation: lives in core (not in an adapter
/// package) because it wraps no technology.
class DefaultOutboxRegistry implements OutboxRegistry {
  final List<SyncableOutbox> _outboxes = [];

  @override
  void register(SyncableOutbox outbox) => _outboxes.add(outbox);

  @override
  Iterable<SyncableOutbox> get registered => List.unmodifiable(_outboxes);
}
