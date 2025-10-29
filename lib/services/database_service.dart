import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:myapp/home/models/bmi_record.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bmi_records.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bmi_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        bmi REAL NOT NULL,
        idealWeight REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<BMIRecord> insertBMIRecord(BMIRecord record) async {
    final db = await instance.database;
    final id = await db.insert('bmi_records', record.toMap());
    return record.copyWith(id: id);
  }

  Future<List<BMIRecord>> getAllBMIRecords() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bmi_records',
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => BMIRecord.fromMap(maps[i]));
  }

  Future<void> deleteBMIRecord(int id) async {
    final db = await instance.database;
    await db.delete(
      'bmi_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
