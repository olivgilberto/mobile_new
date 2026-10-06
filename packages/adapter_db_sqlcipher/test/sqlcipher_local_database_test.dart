import 'package:adapter_db_sqlcipher/src/sqlcipher_local_database.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  Future<LocalDatabase> open() async => SqlcipherLocalDatabase(
      await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
          options: OpenDatabaseOptions(singleInstance: false)));

  test('execute + query round-trip', () async {
    final db = await open();
    await db.execute('CREATE TABLE items(id TEXT, name TEXT)');
    await db.execute('INSERT INTO items VALUES(?, ?)', args: ['1', 'rope']);
    expect(await db.query('SELECT name FROM items'), [{'name': 'rope'}]);
  });

  test('transaction rolls back on failure and joins when nested', () async {
    final db = await open();
    await db.execute('CREATE TABLE items(id TEXT PRIMARY KEY)');
    await expectLater(
      db.transaction((txn) async {
        await txn.execute("INSERT INTO items VALUES('1')");
        await txn.transaction((inner) => inner.execute("INSERT INTO items VALUES('2')"));
        throw StateError('boom');
      }),
      throwsStateError,
    );
    expect(await db.query('SELECT * FROM items'), isEmpty);
  });

  test('driver errors are translated into LocalDatabaseError', () async {
    final db = await open();
    await expectLater(db.query('SELECT * FROM missing'), throwsA(isA<LocalDatabaseError>()));
  });
}
