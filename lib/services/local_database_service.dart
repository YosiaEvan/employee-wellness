import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Service database lokal (SQLite) untuk menyimpan data aktivitas health
/// agar aplikasi tidak selalu menarik data dari backend.
class LocalDatabaseService {
  LocalDatabaseService._init();
  static final LocalDatabaseService instance = LocalDatabaseService._init();

  static Database? _database;

  static const int _version = 2;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'employee_wellness.db');
    return await openDatabase(
      path,
      version: _version,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE langkah (
            tanggal TEXT PRIMARY KEY,
            total_steps INTEGER NOT NULL DEFAULT 0,
            kalori_terbakar INTEGER,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE minum (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tanggal TEXT NOT NULL,
            waktu_minum TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE tidur (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tanggal TEXT NOT NULL,
            waktu_tidur TEXT NOT NULL,
            waktu_bangun TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE sinar_matahari (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tanggal TEXT NOT NULL,
            waktu_selesai TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE tarik_napas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tanggal TEXT NOT NULL,
            waktu_selesai TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE makanan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tanggal TEXT NOT NULL,
            id_food_nutrition INTEGER,
            jenis_makan TEXT NOT NULL,
            porsi REAL NOT NULL DEFAULT 1,
            nama_makanan TEXT,
            kalori REAL NOT NULL DEFAULT 0,
            protein REAL NOT NULL DEFAULT 0,
            karbohidrat REAL NOT NULL DEFAULT 0,
            lemak REAL NOT NULL DEFAULT 0,
            serat REAL NOT NULL DEFAULT 0,
            berminyak INTEGER NOT NULL DEFAULT 0,
            bergula INTEGER NOT NULL DEFAULT 0,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE tenang_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tanggal TEXT NOT NULL,
            kategori TEXT NOT NULL,
            sub_kategori TEXT NOT NULL,
            durasi_detik INTEGER NOT NULL DEFAULT 0,
            selesai_at TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE stress_checkin (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tanggal TEXT NOT NULL,
            stress_level INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE cache (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute(
                'ALTER TABLE makanan ADD COLUMN berminyak INTEGER NOT NULL DEFAULT 0');
            await db.execute(
                'ALTER TABLE makanan ADD COLUMN bergula INTEGER NOT NULL DEFAULT 0');
          } catch (e) {
            print('⚠️ Migration warning: $e');
          }
        }
      },
    );
  }

  // =====================================================
  // GENERIC CRUD
  // =====================================================

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    final rows = await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
    return rows;
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> count(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as c FROM $table${where != null ? ' WHERE $where' : ''}',
      whereArgs ?? [],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // =====================================================
  // SYNC STATE HELPERS
  // =====================================================

  /// Ambil baris yang belum disinkronkan (synced = 0)
  Future<List<Map<String, dynamic>>> getPending(String table) async {
    return await query(table, where: 'synced = 0', orderBy: 'id ASC');
  }

  /// Tandai satu baris sudah disinkronkan
  Future<int> markSynced(String table, int id) async {
    return await update(table, {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  /// Tandai semua baris pada tanggal tertentu sudah disinkronkan
  Future<int> markSyncedByDate(String table, String tanggal) async {
    return await update(
      table,
      {'synced': 1},
      where: 'tanggal = ? AND synced = 0',
      whereArgs: [tanggal],
    );
  }

  // =====================================================
  // LANGKAH
  // =====================================================

  /// Upsert data langkah harian (per tanggal) ke SQLite
  Future<void> upsertLangkah({
    required String tanggal,
    required int totalSteps,
    int? kaloriTerbakar,
  }) async {
    final db = await database;
    await db.insert(
      'langkah',
      {
        'tanggal': tanggal,
        'total_steps': totalSteps,
        'kalori_terbakar': kaloriTerbakar,
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Ambil data langkah untuk satu tanggal
  Future<Map<String, dynamic>?> getLangkah(String tanggal) async {
    final rows = await query(
      'langkah',
      where: 'tanggal = ?',
      whereArgs: [tanggal],
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  // =====================================================
  // CACHE (JSON snapshot dari API)
  // =====================================================

  Future<void> cachePut(String key, String value) async {
    final db = await database;
    await db.insert(
      'cache',
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> cacheGet(String key) async {
    final db = await database;
    final rows = await db.query('cache', where: 'key = ?', whereArgs: [key]);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  // =====================================================
  // DATE HELPERS
  // =====================================================

  /// Tanggal hari ini dalam format YYYY-MM-DD (waktu lokal)
  static String todayStr() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Tanggal awal minggu (Senin) format YYYY-MM-DD
  static String weekStart() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return '${monday.year.toString().padLeft(4, '0')}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }

  /// Format tanggal ke YYYY-MM-DD
  static String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Daftar 7 hari terakhir mulai dari `start` (inklusif)
  static List<DateTime> last7Days(DateTime start) {
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  // =====================================================
  // RESET (LOGOUT)
  // =====================================================

  /// Hapus semua data lokal
  Future<void> clearAll() async {
    final db = await database;
    await db.execute('DELETE FROM langkah');
    await db.execute('DELETE FROM minum');
    await db.execute('DELETE FROM tidur');
    await db.execute('DELETE FROM sinar_matahari');
    await db.execute('DELETE FROM tarik_napas');
    await db.execute('DELETE FROM makanan');
    await db.execute('DELETE FROM tenang_sessions');
    await db.execute('DELETE FROM stress_checkin');
    await db.execute('DELETE FROM cache');
  }
}
