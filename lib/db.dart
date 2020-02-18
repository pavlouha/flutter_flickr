import 'dart:async';
import 'package:flutter_flickr/sql.dart';
import 'package:sqflite/sqflite.dart';

abstract class DB {

  static Database _db;

  static int get _version => 1;

  static Future<void> init() async {

    if (_db != null) { return; }

    try {
      String _path = await getDatabasesPath() + 'favs';
      _db = await openDatabase(_path, version: _version, onCreate: onCreate);
    }
    catch(ex) {
      print(ex);
    }
  }

  static void onCreate(Database db, int version) async =>
      await db.execute('CREATE TABLE favs (key INTEGER PRIMARY KEY AUTOINCREMENT, id INTEGER , owner STRING, title String)');

  static Future<List<Map<String, dynamic>>> query(String table) async => _db.query(table);

  static Future<int> insert(String table, TodoItem item) async =>
      await _db.insert(table, item.toMap());

  static Future<int> update(String table, TodoItem item) async =>
      await _db.update(table, item.toMap(), where: 'id = ?', whereArgs: [item.id]);

  static Future<int> delete(String table, TodoItem item) async =>
      await _db.delete(table, where: 'id = ?', whereArgs: [item.id]);
}