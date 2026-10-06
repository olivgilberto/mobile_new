import 'package:adapter_db_sqlcipher/adapter_db_sqlcipher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('database keys never leave the device and are readable while locked', () {
    expect(
      SqlcipherLocalDatabaseFactory.keychainOptions.accessibility,
      KeychainAccessibility.first_unlock_this_device,
    );
    expect(SqlcipherLocalDatabaseFactory.keychainOptions.synchronizable, isFalse);
  });

  test('databases live in the Application Support folder the iOS AppDelegate excludes from backup', () {
    // Must match `localDatabasesDirectory` in [project]_app/ios/Runner/AppDelegate.swift.
    expect(SqlcipherLocalDatabaseFactory.directoryName, 'local_databases');
  });
}
