import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/podcast.dart';

class PodcastProvider with ChangeNotifier {
  static const String _dbName = 'podcast.db';
  static const String _tableName = 'podcasts';
  Database? _database;
  List<Podcast> _podcasts = [];

  List<Podcast> get podcasts => [..._podcasts];

  final List<String> _defaultCategories = [
    'Technology – เทคโนโลยี',
    'Education – การศึกษา',
    'Music – ดนตรี',
    'Business – ธุรกิจ',
    'Lifestyle – ไลฟ์สไตล์',
    'Health – สุขภาพ',
    'Entertainment – บันเทิง',
  ];

  List<String> get categories => [..._defaultCategories];

  // โหลดข้อมูลทันทีเมื่อ Provider ถูกสร้าง
  PodcastProvider() {
    fetchAndSetPodcasts();
  }

  // เปิดหรือสร้างฐานข้อมูล
  Future<Database> _initDatabase() async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    //  ใช้แค่ครั้งแรกถ้าฐานข้อมูลมีปัญหา (ล้างฐานข้อมูล)
    //await deleteDatabase(path);

    _database = await openDatabase(
      path,
      version: 1, //
      onCreate: (db, version) async {
        print('Creating table $_tableName...');
        await db.execute('''
          CREATE TABLE $_tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            category TEXT,
            channel TEXT,
            link TEXT,
            thumbnailUrl TEXT,
            rating INTEGER
          )
        ''');
        print('Table $_tableName created successfully.');
      },
    );

    print('Database ready at: $path');
    return _database!;
  }

  // เพิ่มข้อมูลใหม่
  Future<void> addPodcast(Podcast podcast) async {
    final db = await _initDatabase();

    await db.insert(
      _tableName,
      podcast.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await fetchAndSetPodcasts(); // โหลดข้อมูลใหม่
  }

  //  โหลดข้อมูลทั้งหมด
  Future<void> fetchAndSetPodcasts() async {
    final db = await _initDatabase();

    final dataList = await db.query(_tableName, orderBy: 'id DESC');

    _podcasts = dataList.map((item) => Podcast.fromMap(item)).toList();
    notifyListeners();
  }

  // อัปเดตข้อมูล
  Future<void> updatePodcast(int id, Podcast newPodcast) async {
    final db = await _initDatabase();

    await db.update(
      _tableName,
      newPodcast.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );

    await fetchAndSetPodcasts();
  }

  // ลบข้อมูล
  Future<void> deletePodcast(int id) async {
    final db = await _initDatabase();

    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);

    await fetchAndSetPodcasts();
  }
}
