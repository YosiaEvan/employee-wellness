/// Model untuk satu sesi Tenang yang diselesaikan user
class TenangSession {
  final int? id;
  final String userId;
  final String kategori;       // 'meditasi' | 'mindfulness' | 'manajemen_stress'
  final String subKategori;    // 'body_scan' | 'loving_kindness' | 'pernapasan_mindful' | dst
  final int durasiDetik;       // durasi sesi dalam detik
  final DateTime selesaiAt;
  final bool isSynced;

  const TenangSession({
    this.id,
    required this.userId,
    required this.kategori,
    required this.subKategori,
    required this.durasiDetik,
    required this.selesaiAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'kategori': kategori,
        'sub_kategori': subKategori,
        'durasi_detik': durasiDetik,
        'selesai_at': selesaiAt.toIso8601String(),
      };

  factory TenangSession.fromJson(Map<String, dynamic> json) => TenangSession(
        id: json['id'] as int?,
        userId: json['user_id'] as String,
        kategori: json['kategori'] as String,
        subKategori: json['sub_kategori'] as String,
        durasiDetik: json['durasi_detik'] as int,
        selesaiAt: DateTime.parse(json['selesai_at'] as String),
        isSynced: (json['is_synced'] as int? ?? 0) == 1,
      );
}

/// Model untuk stress check-in
class StressCheckIn {
  final int? id;
  final String userId;
  final int stressLevel;       // 1–5
  final DateTime createdAt;

  const StressCheckIn({
    this.id,
    required this.userId,
    required this.stressLevel,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'stress_level': stressLevel,
        'created_at': createdAt.toIso8601String(),
      };

  factory StressCheckIn.fromJson(Map<String, dynamic> json) => StressCheckIn(
        id: json['id'] as int?,
        userId: json['user_id'] as String,
        stressLevel: json['stress_level'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

/// Ringkasan statistik Tenang untuk satu user
class TenangStats {
  final int totalSessions;
  final int totalMinutes;
  final int uniqueDays;
  final int streakDays;
  final int sessionsThisWeek;
  final int minutesThisWeek;
  final int weeklyProgressPct;

  const TenangStats({
    required this.totalSessions,
    required this.totalMinutes,
    required this.uniqueDays,
    required this.streakDays,
    required this.sessionsThisWeek,
    required this.minutesThisWeek,
    required this.weeklyProgressPct,
  });

  factory TenangStats.fromJson(Map<String, dynamic> json) => TenangStats(
        totalSessions: json['total_sessions'] as int? ?? 0,
        totalMinutes: json['total_minutes'] as int? ?? 0,
        uniqueDays: json['unique_days'] as int? ?? 0,
        streakDays: json['streak_days'] as int? ?? 0,
        sessionsThisWeek: json['sessions_this_week'] as int? ?? 0,
        minutesThisWeek: json['minutes_this_week'] as int? ?? 0,
        weeklyProgressPct: json['weekly_progress_pct'] as int? ?? 0,
      );

  factory TenangStats.empty() => const TenangStats(
        totalSessions: 0,
        totalMinutes: 0,
        uniqueDays: 0,
        streakDays: 0,
        sessionsThisWeek: 0,
        minutesThisWeek: 0,
        weeklyProgressPct: 0,
      );
}
