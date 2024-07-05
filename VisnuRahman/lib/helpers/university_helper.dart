import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:visnurahman/models/university.dart';

class UniversityHelper {
  static Database? _db;
  static final UniversityHelper instance = UniversityHelper._constructor();
  UniversityHelper._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  final String _universityTableName = 'universities';
  final String _universityNameColumn = 'name';
  final String _universityUrlColumn = 'url';
  final String _universityCountryColumn = 'country';

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'university.db');
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $_universityTableName (
            id INTEGER PRIMARY KEY,
            $_universityNameColumn TEXT NULL,
            $_universityUrlColumn TEXT NULL,
            $_universityCountryColumn TEXT NULL
          )
        ''');
      },
    );

    return database;
  }

  void insertData(String? name, String? url, String? country) async {
    final db = await database;
    await db.insert(_universityTableName, {
      _universityNameColumn: name,
      _universityUrlColumn: url,
      _universityCountryColumn: country
    });
  }

  void deleteData(int id) async {
    final db = await database;
    await db.delete(_universityTableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<University>> getAll() async {
    final db = await database;
    final data = await db.query(_universityTableName, orderBy: 'id DESC');

    List<University> listData = data
      .map((e) => University(
          id: e['id'] as int,
          name: e['name'] as String,
          url: e['url'] as String,
          country: e['country'] as String
        ))
      .toList();

    return listData;
  }
}