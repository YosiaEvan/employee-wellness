-- =============================================================
--  TENANG MODULE – DATABASE SCHEMA
--  Employee Wellness App
--  Run this script in your SQL editor (MySQL / MariaDB)
-- =============================================================

-- -------------------------------------------------------------
-- 1. TENANG SESSIONS
--    Menyimpan setiap sesi yang diselesaikan user
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tenang_sessions (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT UNSIGNED NOT NULL,

    -- 'meditasi' | 'mindfulness' | 'manajemen_stress'
    kategori        VARCHAR(50) NOT NULL,

    -- e.g. 'body_scan', 'loving_kindness', 'pernapasan_mindful',
    --      'visualisasi_positif', 'panca_indra', 'pernapasan_4_7_8',
    --      'kesadaran_tubuh', 'momen_sekarang', 'teknik_pernapasan',
    --      'teknik_grounding', 'relaksasi_otot_progresif', 'strategi_coping'
    sub_kategori    VARCHAR(60) NOT NULL,

    durasi_detik    INT UNSIGNED NOT NULL DEFAULT 0,
    selesai_at      DATETIME NOT NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_user_id   (user_id),
    INDEX idx_kategori  (kategori),
    INDEX idx_selesai   (selesai_at),

    CONSTRAINT fk_ts_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- -------------------------------------------------------------
-- 2. STRESS CHECK-IN
--    Menyimpan level stres yang dimasukkan user lewat slider
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tenang_stress_checkin (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT UNSIGNED NOT NULL,

    -- Nilai 1–5 (1 = Sangat Rendah, 5 = Sangat Tinggi)
    stress_level    TINYINT UNSIGNED NOT NULL CHECK (stress_level BETWEEN 1 AND 5),

    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_user_id  (user_id),
    INDEX idx_created  (created_at),

    CONSTRAINT fk_sc_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- -------------------------------------------------------------
-- 3. TENANG GOALS
--    Target meditasi & rencana manajemen stres per user (1 baris per user)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tenang_goals (
    id                          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id                     BIGINT UNSIGNED NOT NULL UNIQUE,

    daily_meditation_minutes    INT UNSIGNED NOT NULL DEFAULT 10,
    weekly_session_target       INT UNSIGNED NOT NULL DEFAULT 5,

    -- Catatan bebas rencana manajemen stres
    stress_management_plan      TEXT NULL,

    updated_at                  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                                    ON UPDATE CURRENT_TIMESTAMP,
    created_at                  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_tg_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================================
--  VIEWS (opsional – memudahkan query di backend)
-- =============================================================

-- Statistik ringkasan per user
CREATE OR REPLACE VIEW v_tenang_stats AS
SELECT
    u.id                                                AS user_id,
    COUNT(ts.id)                                        AS total_sesi,
    COALESCE(SUM(ts.durasi_detik) / 60, 0)             AS total_menit_meditasi,
    COALESCE(AVG(sc.stress_level), 0)                  AS rata_rata_stress,

    -- Sesi dalam 7 hari terakhir
    COUNT(
        CASE WHEN ts.selesai_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
             THEN 1 END
    )                                                   AS sesi_minggu_ini,

    -- Streak: jumlah hari berturut-turut dengan minimal 1 sesi
    -- (kalkulasi streak yang lebih akurat sebaiknya dilakukan di aplikasi layer)
    (
        SELECT COUNT(DISTINCT DATE(ts2.selesai_at))
        FROM   tenang_sessions ts2
        WHERE  ts2.user_id = u.id
          AND  ts2.selesai_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
    )                                                   AS hari_aktif_30d

FROM users u
LEFT JOIN tenang_sessions       ts ON ts.user_id = u.id
LEFT JOIN tenang_stress_checkin sc ON sc.user_id = u.id
GROUP BY u.id;


-- =============================================================
--  API ENDPOINTS YANG DIBUTUHKAN BACKEND
-- =============================================================
--
--  GET    /api/tenang/dashboard
--         Kembalikan: stats (dari v_tenang_stats) + 5 sesi terbaru
--
--  POST   /api/tenang/sessions
--         Body: { user_id, kategori, sub_kategori, durasi_detik, selesai_at }
--         Action: INSERT ke tenang_sessions
--
--  GET    /api/tenang/sessions
--         Query params: kategori?, start_date?, end_date?, page, limit
--         Kembalikan: list sesi + pagination meta
--
--  POST   /api/tenang/stress-checkin
--         Body: { user_id, stress_level, created_at }
--         Action: INSERT ke tenang_stress_checkin
--
--  GET    /api/tenang/stress-checkin
--         Query params: start_date?, end_date?
--         Kembalikan: riwayat check-in user yang login
--
--  GET    /api/tenang/goals
--         Kembalikan: baris tenang_goals milik user
--
--  PUT    /api/tenang/goals
--         Body: { daily_meditation_minutes?, weekly_session_target?, stress_management_plan? }
--         Action: UPSERT ke tenang_goals
--
-- =============================================================
