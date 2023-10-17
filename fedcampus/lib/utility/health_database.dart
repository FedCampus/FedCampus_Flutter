import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class HealthDatabase {
  late final Database db;
  HealthDatabase._();

  // https://stackoverflow.com/a/59304510
  static Future<HealthDatabase> create() async {
    // Call the private constructor
    var component = HealthDatabase._();

    // Do initialization that requires async
    await component.init();

    // Return the fully initialized object
    return component;
  }

  init() async {
    db = await openDatabase(
      join(await getDatabasesPath(), 'health_data.db'),
      onCreate: (db, version) {
        return db.execute(
          """CREATE TABLE data(
                time INTEGER, 
                name TEXT, 
                value REAL, 
                time_modified INTEGER,
                CONSTRAINT pk_health_data PRIMARY KEY (time, name)
            );""",
        );
      },
      version: 1,
    );
  }

  Future<void> insert(HealthDBData data) async {
    await db.insert(
      'data',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HealthDBData>> getDataList() async {
    final List<Map<String, dynamic>> maps = await db.query('data');

    return List.generate(maps.length, (i) {
      return HealthDBData(
        time: maps[i]['time'],
        name: maps[i]['name'],
        value: maps[i]['value'],
        timeModified: maps[i]['time_modified'],
      );
    });
  }

  Future<List<Map<String, Object?>>> getData(int time, String name) async {
    return await db.query(
      'data',
      where: 'time = ? and name = ?',
      whereArgs: [time, name],
    );
  }

  Future<void> updateData(HealthDBData data) async {
    await db.update(
      'data',
      data.toMap(),
      where: 'time = ? and name = ?',
      whereArgs: [data.time, data.name],
    );
  }

  Future<void> deleteData(int time, String name) async {
    await db.delete(
      'data',
      where: 'time = ? and name = ?',
      whereArgs: [time, name],
    );
  }

  Future<void> clear() async {
    await db.delete(
      'data',
      where: '1 = 1',
    );
  }
}

class HealthDBData {
  final int time;
  final String name;
  final double value;
  final int timeModified;

  const HealthDBData({
    required this.time,
    required this.name,
    required this.value,
    required this.timeModified,
  });

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'name': name,
      'value': value,
      'time_modified': timeModified,
    };
  }

  @override
  String toString() {
    return 'Data{time: $time, name: $name, value: $value, time_modified: $timeModified}';
  }
}
