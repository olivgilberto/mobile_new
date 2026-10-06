import 'clearable_on_logout.dart';

abstract interface class LogoutCleanerRegistry {
  void register(ClearableOnLogout cleaner);
  Future<void> clearAll();
}
