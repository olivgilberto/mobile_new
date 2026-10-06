import 'syncable_outbox.dart';

abstract interface class OutboxRegistry {
  void register(SyncableOutbox outbox);
  Iterable<SyncableOutbox> get registered;
}
