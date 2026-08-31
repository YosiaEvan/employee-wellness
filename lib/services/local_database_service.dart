import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

/// Service database lokal (SQLite) untuk menyimpan data aktivitas health
/// agar aplikasi tidak selalu menarik data dari backend.
/// Setiap tabel punya kolom `user_id` agar data offline per-user.
class LocalDatabaseService {
  LocalDatabaseService._init();
  static final LocalDatabaseService instance = LocalDatabaseService._init();

  static Database? _database;
  static const _storage = FlutterSecureStorage();

  static const int _version = 4;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  // =====================================================
  // USER ID HELPER
  // =====================================================

  /// Ambil user_id dari JWT token (atau SharedPreferences).
  static Future<String> getCurrentUserId() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final normalized = base64.normalize(payload);
          final decoded = jsonDecode(utf8.decode(base64.decode(normalized)));
          final id = decoded['id']?.toString() ??
              decoded['user_id']?.toString() ??
              decoded['userId']?.toString() ??
              decoded['sub']?.toString();
          if (id != null && id.isNotEmpty) return id;
        }
      }
    } catch (_) {}
    return 'unknown';
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
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL DEFAULT 'unknown',
            tanggal TEXT NOT NULL,
            total_steps INTEGER NOT NULL DEFAULT 0,
            kalori_terbakar INTEGER,
            synced INTEGER NOT NULL DEFAULT 0,
            UNIQUE(user_id, tanggal)
          )
        ''');
        await db.execute('''
          CREATE TABLE minum (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL DEFAULT 'unknown',
            tanggal TEXT NOT NULL,
            waktu_minum TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE tidur (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL DEFAULT 'unknown',
            tanggal TEXT NOT NULL,
            waktu_tidur TEXT NOT NULL,
            waktu_bangun TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE sinar_matahari (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL DEFAULT 'unknown',
            tanggal TEXT NOT NULL,
            waktu_selesai TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE tarik_napas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL DEFAULT 'unknown',
            tanggal TEXT NOT NULL,
            waktu_selesai TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE makanan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL DEFAULT 'unknown',
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
            user_id TEXT NOT NULL DEFAULT 'unknown',
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
            user_id TEXT NOT NULL DEFAULT 'unknown',
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
        await db.execute('''
          CREATE TABLE aktivitas_poin (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL DEFAULT 'unknown',
            modul TEXT NOT NULL,
            aktivitas TEXT NOT NULL,
            kategori TEXT,
            tanggal TEXT NOT NULL,
            poin INTEGER NOT NULL DEFAULT 1,
            deskripsi TEXT,
            carbon_saved REAL,
            synced INTEGER NOT NULL DEFAULT 0
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
            debugPrint('Migration v2 warning: $e');
          }
        }
        if (oldVersion < 3) {
          try {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS aktivitas_poin (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT NOT NULL DEFAULT 'unknown',
                modul TEXT NOT NULL,
                aktivitas TEXT NOT NULL,
                kategori TEXT,
                tanggal TEXT NOT NULL,
                poin INTEGER NOT NULL DEFAULT 1,
                deskripsi TEXT,
                carbon_saved REAL,
                synced INTEGER NOT NULL DEFAULT 0
              )
            ''');
          } catch (e) {
            debugPrint('Migration v3 warning: $e');
          }
        }
        if (oldVersion < 4) {
          // Tambah kolom user_id ke semua tabel yang sudah ada
          final tables = [
            'langkah', 'minum', 'tidur', 'sinar_matahari',
            'tarik_napas', 'makanan', 'tenang_sessions',
            'stress_checkin', 'aktivitas_poin',
          ];
          for (final table in tables) {
            try {
              await db.execute(
                  "ALTER TABLE $table ADD COLUMN user_id TEXT NOT NULL DEFAULT 'unknown'");
            } catch (_) {}
          }
  /// Fix langkah: tambah auto-increment id + UNIQUE constraint
          try {
            // SQLite tidak support ALTER PRIMARY KEY, jadi recreate
            await db.execute('''
              CREATE TABLE langkah_new (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT NOT NULL DEFAULT 'unknown',
                tanggal TEXT NOT NULL,
                total_steps INTEGER NOT NULL DEFAULT 0,
                kalori_terbakar INTEGER,
                synced INTEGER NOT NULL DEFAULT 0,
                UNIQUE(user_id, tanggal)
              )
            ''');
            await db.execute(
                "INSERT INTO langkah_new (user_id, tanggal, total_steps, kalori_terbakar, synced) "
                "SELECT 'unknown', tanggal, total_steps, kalori_terbakar, synced FROM langkah");
            await db.execute('DROP TABLE langkah');
            await db.execute('ALTER TABLE langkah_new RENAME TO langkah');
          } catch (e) {
            debugPrint('Migration v4 langkah warning: $e');
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
    // Auto-inject user_id jika belum ada
    if (!data.containsKey('user_id')) {
      data['user_id'] = await getCurrentUserId();
    }
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
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

  /// Ambil baris yang belum disinkronkan (synced = 0) untuk user aktif
  Future<List<Map<String, dynamic>>> getPending(String table) async {
    final userId = await getCurrentUserId();
    return await query(
      table,
      where: 'synced = 0 AND user_id = ?',
      whereArgs: [userId],
      orderBy: 'id ASC',
    );
  }

  /// Tandai satu baris sudah disinkronkan
  Future<int> markSynced(String table, int id) async {
    return await update(table, {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  /// Tandai semua baris pada tanggal tertentu sudah disinkronkan
  Future<int> markSyncedByDate(String table, String tanggal) async {
    final userId = await getCurrentUserId();
    return await update(
      table,
      {'synced': 1},
      where: 'tanggal = ? AND user_id = ? AND synced = 0',
      whereArgs: [tanggal, userId],
    );
  }

  // =====================================================
  // LANGKAH
  // =====================================================

  Future<void> upsertLangkah({
    required String tanggal,
    required int totalSteps,
    int? kaloriTerbakar,
  }) async {
    final db = await database;
    final userId = await getCurrentUserId();
    await db.insert(
      'langkah',
      {
        'user_id': userId,
        'tanggal': tanggal,
        'total_steps': totalSteps,
        'kalori_terbakar': kaloriTerbakar,
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getLangkah(String tanggal) async {
    final userId = await getCurrentUserId();
    final rows = await query(
      'langkah',
      where: 'tanggal = ? AND user_id = ?',
      whereArgs: [tanggal, userId],
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
  // KPI SUMMARY (offline)
  // =====================================================

  /// Hitung jumlah record per aktivitas dalam 1 bulan untuk modul tertentu.
  /// Mengembalikan Map of kode_aktivitas to jumlah_record.
  Future<Map<String, int>> getMonthlyCounts({
    required String table,
    required String aktivitasColumn,
    required int year,
    required int month,
  }) async {
    final userId = await getCurrentUserId();
    final start = '$year-${month.toString().padLeft(2, '0')}-01';
    final endMonth = month == 12 ? 1 : month + 1;
    final endYear = month == 12 ? year + 1 : year;
    final end = '$endYear-${endMonth.toString().padLeft(2, '0')}-01';

    final rows = await query(
      table,
      where: 'user_id = ? AND tanggal >= ? AND tanggal < ?',
      whereArgs: [userId, start, end],
    );

    final counts = <String, int>{};
    for (final row in rows) {
      final key = row[aktivitasColumn]?.toString() ?? 'unknown';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  /// Hitung jumlah gelas minum bulan ini per user
  Future<int> getMinumMonthlyCount({required int year, required int month}) async {
    final userId = await getCurrentUserId();
    final start = '$year-${month.toString().padLeft(2, '0')}-01';
    final endMonth = month == 12 ? 1 : month + 1;
    final endYear = month == 12 ? year + 1 : year;
    final end = '$endYear-${endMonth.toString().padLeft(2, '0')}-01';

    final rows = await query(
      'minum',
      where: 'user_id = ? AND tanggal >= ? AND tanggal < ?',
      whereArgs: [userId, start, end],
    );
    return rows.length;
  }

  /// Hitung jumlah hari langkah >= 10000 bulan ini
  Future<int> getLangkahMonthlyCount({required int year, required int month}) async {
    final userId = await getCurrentUserId();
    final start = '$year-${month.toString().padLeft(2, '0')}-01';
    final endMonth = month == 12 ? 1 : month + 1;
    final endYear = month == 12 ? year + 1 : year;
    final end = '$endYear-${endMonth.toString().padLeft(2, '0')}-01';

    final rows = await query(
      'langkah',
      where: 'user_id = ? AND tanggal >= ? AND tanggal < ? AND total_steps >= 10000',
      whereArgs: [userId, start, end],
    );
    return rows.length;
  }

  // =====================================================
  // DATE HELPERS
  // =====================================================

  static String todayStr() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String weekStart() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return '${monday.year.toString().padLeft(4, '0')}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }

  static String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static List<DateTime> last7Days(DateTime start) {
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  // =====================================================
  // RESET (LOGOUT)
  // =====================================================

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
    await db.execute('DELETE FROM aktivitas_poin');
    await db.execute('DELETE FROM cache');
  }
}
