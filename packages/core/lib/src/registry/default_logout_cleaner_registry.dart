import 'clearable_on_logout.dart';
import 'logout_cleaner_registry.dart';

/// Tech-free default implementation: lives in core (not in an adapter
/// package) because it wraps no technology.
class DefaultLogoutCleanerRegistry implements LogoutCleanerRegistry {
  final List<ClearableOnLogout> _cleaners = [];

  @override
  void register(ClearableOnLogout cleaner) => _cleaners.add(cleaner);

  @override
  Future<void> clearAll() async {
    for (final cleaner in _cleaners) {
      await cleaner.clearLocalData();
    }
  }
}
