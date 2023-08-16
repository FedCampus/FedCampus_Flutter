import 'package:fedcampus/pigeon/data_extensions.dart';
import 'package:fedcampus/pigeon/generated.g.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseApi {
  // TODO: The start time needs to be changed when launching the app!
  final startTime = 20230700;

  Future<Database> getDataBase() async {
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'data.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE data(id INTEGER PRIMARY KEY, name TEXT, startTime INTEGER, endTime INTEGER, value REAL)',
        );
      },
      version: 2,
    );

    return database;
  }

  Future<bool> saveToDB(List<Data?> dataList, Database db) async {
    List<Future<void>> saveToDB = List.empty(growable: true);
    for (var i in dataList) {
      saveToDB.add(db.insert('data', i!.toMapWithTime(),
          conflictAlgorithm: ConflictAlgorithm.replace));
    }

    await Future.wait(saveToDB);
    return true;
  }

  Future<List<Data>> getDataFromDB(int endTime, Database db) async {
    final List<Map<String, dynamic>> maps =
        await db.query('data', where: "endTime=?", whereArgs: [endTime]);
    return List.generate(maps.length, (i) {
      return Data(
          name: maps[i]['name'],
          value: maps[i]['value'],
          startTime: maps[i]['startTime'],
          endTime: maps[i]['endTime']);
    });
  }

  Future<List<Data>> getDataList(Database db, int endTime) async {
    // get all the data from the starting time till the endTime
    final List<Map<String, dynamic>> maps = await db.query('data',
        where: "endTime >= ? AND  endTime <=?",
        whereArgs: [startTime, endTime]);
    return List.generate(maps.length, (i) {
      return Data(
          name: maps[i]['name'],
          value: maps[i]['value'],
          startTime: maps[i]['startTime'],
          endTime: maps[i]['endTime']);
    });
  }
}
