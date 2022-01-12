import 'package:flutter_wallet/model/transaction.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbService {
  static final DbService _singleton = DbService._internal();

  factory DbService() {
    return _singleton;
  }

  DbService._internal();

  Future<Database> openDb() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'wallet_dieptv.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE transactions(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, point REAL, createdMillis INTEGER, status INTEGER)',
        );
      },
      version: 1,
    );
    return database;
  }

  Future<void> insertTransaction(TransactionCustom tx) async {
    final db = await openDb();

    await db.insert(
      'transactions',
      tx.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransactionCustom>> transactions() async {
    final db = await openDb();

    final List<Map<String, dynamic>> maps = await db.query('transactions');

    return List.generate(maps.length, (i) {
      return TransactionCustom(
        id: maps[i]['id'],
        name: maps[i]['name'],
        point: maps[i]['point'],
        createdMillis: maps[i]['createdMillis'],
        status: maps[i]['status'],
      );
    });
  }

  Future<void> updateDog(TransactionCustom tx) async {
    final db = await openDb();

    await db.update(
      'transactions',
      tx.toMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }
}