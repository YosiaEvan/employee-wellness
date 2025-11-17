-- =====================================================
-- SEHAT KPI TRACKING SCHEMA
-- Untuk menghitung poin wellness bulanan
-- =====================================================

-- 1. Table untuk Menu Makanan (Reference data)
-- Structure sesuai dengan Gemini API response
CREATE TABLE menu_makanan (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nama_makanan TEXT NOT NULL,
    kategori TEXT CHECK (kategori IN ('sarapan', 'makan_siang', 'makan_malam', 'snack')),

    -- Nutrisi dalam PERSENTASE (sesuai KPI requirement)
    persentase_serat DECIMAL(5,2) NOT NULL, -- dalam % (target: 25%)
    persentase_protein DECIMAL(5,2) NOT NULL, -- dalam % (target: 30%)
    persentase_karbo DECIMAL(5,2) NOT NULL, -- dalam % (target: 35-50%)

    -- Nutrisi dalam GRAM (untuk display)
    serat_gram DECIMAL(6,2), -- dalam gram
    protein_gram DECIMAL(6,2), -- dalam gram
    karbo_gram DECIMAL(6,2), -- dalam gram
    lemak_gram DECIMAL(6,2), -- dalam gram

    -- Additional info
    kalori INTEGER NOT NULL,
    ukuran_porsi TEXT DEFAULT 'porsi standar',
    deskripsi TEXT,

    -- Flags
    mengandung_minyak BOOLEAN DEFAULT FALSE,
    mengandung_gula BOOLEAN DEFAULT FALSE,

    -- Source tracking
    sumber TEXT DEFAULT 'manual', -- 'manual', 'gemini', 'gemini_image', 'verified'
    gemini_raw_response TEXT, -- Store original Gemini response (JSON)

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraint: persentase total harus 100%
    CONSTRAINT valid_percentage CHECK (
        persentase_serat + persentase_protein + persentase_karbo <= 100.5 AND
        persentase_serat + persentase_protein + persentase_karbo >= 99.5
    )
);

-- 2. Table untuk tracking aktivitas harian
CREATE TABLE sehat_daily_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    tanggal DATE NOT NULL DEFAULT CURRENT_DATE,

    -- Berjemur (1x/minggu = 20 poin)
    berjemur_done BOOLEAN DEFAULT FALSE,
    berjemur_waktu TIME,
    berjemur_durasi INTEGER, -- dalam menit

    -- Jalan 10.000 langkah (5x/minggu = 20 poin per hari)
    langkah_total INTEGER DEFAULT 0,
    langkah_target_tercapai BOOLEAN DEFAULT FALSE,

    -- Hirup udara segar (5x/minggu = 20 poin per hari)
    hirup_udara_count INTEGER DEFAULT 0,
    hirup_udara_done BOOLEAN DEFAULT FALSE,
    hirup_udara_times TIMESTAMPTZ[],

    -- Minum air 8 gelas (7x/minggu = 28 poin per hari)
    minum_air_count INTEGER DEFAULT 0,
    minum_air_done BOOLEAN DEFAULT FALSE,
    minum_air_times TIMESTAMPTZ[],

    -- Tidur cukup (7-8 jam) (7x/minggu = 28 poin per hari)
    tidur_mulai TIME,
    tidur_selesai TIME,
    tidur_durasi DECIMAL(4,2), -- dalam jam
    tidur_done BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, tanggal)
);

-- 3. Table untuk tracking pola makan
CREATE TABLE sehat_pola_makan (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    tanggal DATE NOT NULL DEFAULT CURRENT_DATE,
    waktu_makan TIMESTAMPTZ DEFAULT NOW(),
    jenis_makan TEXT CHECK (jenis_makan IN ('sarapan', 'makan_siang', 'makan_malam', 'snack')),

    -- Menu yang dimakan
    menu_makanan_id UUID REFERENCES menu_makanan(id),
    nama_makanan_custom TEXT, -- Jika tidak ada di database

    -- Nutrisi (dihitung dari menu atau input manual)
    persentase_serat DECIMAL(5,2),
    persentase_protein DECIMAL(5,2),
    persentase_karbo DECIMAL(5,2),

    -- Foto makanan
    foto_url TEXT,

    -- Sumber data
    sumber TEXT DEFAULT 'manual', -- 'manual', 'gemini', 'database'
    gemini_analysis TEXT, -- JSON result dari Gemini API

    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Table untuk KPI Summary (per minggu)
CREATE TABLE sehat_kpi_weekly (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    tahun INTEGER NOT NULL,
    minggu_ke INTEGER NOT NULL, -- 1-52
    tanggal_mulai DATE NOT NULL,
    tanggal_akhir DATE NOT NULL,

    -- Poin per aktivitas
    poin_berjemur INTEGER DEFAULT 0, -- Max 20/minggu
    poin_olahraga INTEGER DEFAULT 0, -- Max 20/minggu (5 hari x 4 poin)
    poin_udara INTEGER DEFAULT 0, -- Max 20/minggu (5 hari x 4 poin)
    poin_minum INTEGER DEFAULT 0, -- Max 28/minggu (7 hari x 4 poin)
    poin_tidur INTEGER DEFAULT 0, -- Max 28/minggu (7 hari x 4 poin)
    poin_makan INTEGER DEFAULT 0, -- Max 36/minggu (dihitung dari nutrisi)

    -- Total
    total_poin INTEGER DEFAULT 0, -- Max 152/minggu
    persentase_pencapaian DECIMAL(5,2), -- %

    -- Statistik
    hari_berjemur INTEGER DEFAULT 0,
    hari_olahraga INTEGER DEFAULT 0,
    hari_udara INTEGER DEFAULT 0,
    hari_minum INTEGER DEFAULT 0,
    hari_tidur INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, tahun, minggu_ke)
);

-- 5. Table untuk KPI Summary (per bulan)
CREATE TABLE sehat_kpi_monthly (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    tahun INTEGER NOT NULL,
    bulan INTEGER NOT NULL, -- 1-12

    -- Poin per aktivitas (total bulanan)
    poin_berjemur INTEGER DEFAULT 0, -- Max 80/bulan (4 minggu)
    poin_olahraga INTEGER DEFAULT 0, -- Max 80/bulan
    poin_udara INTEGER DEFAULT 0, -- Max 80/bulan
    poin_minum INTEGER DEFAULT 0, -- Max 112/bulan
    poin_tidur INTEGER DEFAULT 0, -- Max 112/bulan
    poin_makan INTEGER DEFAULT 0, -- Max 144/bulan

    -- Total
    total_poin INTEGER DEFAULT 0, -- Max 608/bulan (4 minggu x 152)
    persentase_pencapaian DECIMAL(5,2), -- %

    -- Rata-rata mingguan
    rata_rata_poin_mingguan DECIMAL(10,2),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, tahun, bulan)
);

-- =====================================================
-- INDEXES
-- =====================================================

CREATE INDEX idx_daily_activities_user_date ON sehat_daily_activities(user_id, tanggal DESC);
CREATE INDEX idx_pola_makan_user_date ON sehat_pola_makan(user_id, tanggal DESC);
CREATE INDEX idx_kpi_weekly_user_period ON sehat_kpi_weekly(user_id, tahun DESC, minggu_ke DESC);
CREATE INDEX idx_kpi_monthly_user_period ON sehat_kpi_monthly(user_id, tahun DESC, bulan DESC);
CREATE INDEX idx_menu_makanan_nama ON menu_makanan(nama_makanan);

-- =====================================================
-- ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE sehat_daily_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE sehat_pola_makan ENABLE ROW LEVEL SECURITY;
ALTER TABLE sehat_kpi_weekly ENABLE ROW LEVEL SECURITY;
ALTER TABLE sehat_kpi_monthly ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_makanan ENABLE ROW LEVEL SECURITY;

-- Policies untuk daily_activities
CREATE POLICY "Users can manage own daily_activities"
    ON sehat_daily_activities FOR ALL
    USING (auth.uid() = user_id);

-- Policies untuk pola_makan
CREATE POLICY "Users can manage own pola_makan"
    ON sehat_pola_makan FOR ALL
    USING (auth.uid() = user_id);

-- Policies untuk KPI
CREATE POLICY "Users can view own kpi_weekly"
    ON sehat_kpi_weekly FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can view own kpi_monthly"
    ON sehat_kpi_monthly FOR SELECT
    USING (auth.uid() = user_id);

-- Menu makanan bisa dibaca semua user
CREATE POLICY "Everyone can read menu_makanan"
    ON menu_makanan FOR SELECT
    USING (true);

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Function untuk calculate poin olahraga
CREATE OR REPLACE FUNCTION calculate_poin_olahraga(langkah INTEGER)
RETURNS INTEGER AS $$
BEGIN
    IF langkah >= 10000 THEN
        RETURN 4; -- Full point
    ELSIF langkah >= 7500 THEN
        RETURN 3;
    ELSIF langkah >= 5000 THEN
        RETURN 2;
    ELSIF langkah >= 2500 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function untuk calculate poin makan (berdasarkan nutrisi)
CREATE OR REPLACE FUNCTION calculate_poin_makan(
    serat DECIMAL,
    protein DECIMAL,
    karbo DECIMAL
)
RETURNS INTEGER AS $$
DECLARE
    poin INTEGER := 0;
BEGIN
    -- Serat (minimal 25%)
    IF serat >= 25 THEN
        poin := poin + 2;
    ELSIF serat >= 15 THEN
        poin := poin + 1;
    END IF;

    -- Protein (minimal 30%)
    IF protein >= 30 THEN
        poin := poin + 2;
    ELSIF protein >= 20 THEN
        poin := poin + 1;
    END IF;

    -- Karbo (35-50% ideal)
    IF karbo >= 35 AND karbo <= 50 THEN
        poin := poin + 2;
    ELSIF karbo >= 25 AND karbo <= 60 THEN
        poin := poin + 1;
    END IF;

    RETURN poin;
END;
$$ LANGUAGE plpgsql;

-- Function untuk update KPI weekly
CREATE OR REPLACE FUNCTION update_sehat_kpi_weekly(p_user_id UUID, p_date DATE)
RETURNS VOID AS $$
DECLARE
    v_tahun INTEGER;
    v_minggu INTEGER;
    v_tanggal_mulai DATE;
    v_tanggal_akhir DATE;
    v_poin_berjemur INTEGER;
    v_poin_olahraga INTEGER;
    v_poin_udara INTEGER;
    v_poin_minum INTEGER;
    v_poin_tidur INTEGER;
    v_poin_makan INTEGER;
    v_hari_berjemur INTEGER;
    v_hari_olahraga INTEGER;
    v_hari_udara INTEGER;
    v_hari_minum INTEGER;
    v_hari_tidur INTEGER;
BEGIN
    -- Get week info
    v_tahun := EXTRACT(YEAR FROM p_date);
    v_minggu := EXTRACT(WEEK FROM p_date);
    v_tanggal_mulai := DATE_TRUNC('week', p_date);
    v_tanggal_akhir := v_tanggal_mulai + INTERVAL '6 days';

    -- Calculate berjemur (1x/minggu = 20 poin)
    SELECT
        CASE WHEN COUNT(*) > 0 THEN 20 ELSE 0 END,
        COUNT(*)
    INTO v_poin_berjemur, v_hari_berjemur
    FROM sehat_daily_activities
    WHERE user_id = p_user_id
    AND tanggal BETWEEN v_tanggal_mulai AND v_tanggal_akhir
    AND berjemur_done = TRUE;

    -- Calculate olahraga (5x/minggu @ 4 poin = 20 poin)
    SELECT
        SUM(calculate_poin_olahraga(langkah_total)),
        COUNT(*) FILTER (WHERE langkah_target_tercapai = TRUE)
    INTO v_poin_olahraga, v_hari_olahraga
    FROM sehat_daily_activities
    WHERE user_id = p_user_id
    AND tanggal BETWEEN v_tanggal_mulai AND v_tanggal_akhir;

    -- Calculate udara (5x/minggu @ 4 poin = 20 poin)
    SELECT
        COUNT(*) * 4,
        COUNT(*)
    INTO v_poin_udara, v_hari_udara
    FROM sehat_daily_activities
    WHERE user_id = p_user_id
    AND tanggal BETWEEN v_tanggal_mulai AND v_tanggal_akhir
    AND hirup_udara_done = TRUE
    LIMIT 5;

    -- Calculate minum (7x/minggu @ 4 poin = 28 poin)
    SELECT
        COUNT(*) * 4,
        COUNT(*)
    INTO v_poin_minum, v_hari_minum
    FROM sehat_daily_activities
    WHERE user_id = p_user_id
    AND tanggal BETWEEN v_tanggal_mulai AND v_tanggal_akhir
    AND minum_air_done = TRUE;

    -- Calculate tidur (7x/minggu @ 4 poin = 28 poin)
    SELECT
        COUNT(*) * 4,
        COUNT(*)
    INTO v_poin_tidur, v_hari_tidur
    FROM sehat_daily_activities
    WHERE user_id = p_user_id
    AND tanggal BETWEEN v_tanggal_mulai AND v_tanggal_akhir
    AND tidur_done = TRUE;

    -- Calculate makan (max 36/minggu)
    SELECT
        LEAST(SUM(calculate_poin_makan(persentase_serat, persentase_protein, persentase_karbo)), 36)
    INTO v_poin_makan
    FROM sehat_pola_makan
    WHERE user_id = p_user_id
    AND tanggal BETWEEN v_tanggal_mulai AND v_tanggal_akhir;

    -- Insert or update KPI
    INSERT INTO sehat_kpi_weekly (
        user_id, tahun, minggu_ke, tanggal_mulai, tanggal_akhir,
        poin_berjemur, poin_olahraga, poin_udara, poin_minum, poin_tidur, poin_makan,
        total_poin, persentase_pencapaian,
        hari_berjemur, hari_olahraga, hari_udara, hari_minum, hari_tidur
    ) VALUES (
        p_user_id, v_tahun, v_minggu, v_tanggal_mulai, v_tanggal_akhir,
        COALESCE(v_poin_berjemur, 0),
        COALESCE(v_poin_olahraga, 0),
        COALESCE(v_poin_udara, 0),
        COALESCE(v_poin_minum, 0),
        COALESCE(v_poin_tidur, 0),
        COALESCE(v_poin_makan, 0),
        COALESCE(v_poin_berjemur, 0) + COALESCE(v_poin_olahraga, 0) + COALESCE(v_poin_udara, 0) +
        COALESCE(v_poin_minum, 0) + COALESCE(v_poin_tidur, 0) + COALESCE(v_poin_makan, 0),
        ((COALESCE(v_poin_berjemur, 0) + COALESCE(v_poin_olahraga, 0) + COALESCE(v_poin_udara, 0) +
          COALESCE(v_poin_minum, 0) + COALESCE(v_poin_tidur, 0) + COALESCE(v_poin_makan, 0))::DECIMAL / 152) * 100,
        COALESCE(v_hari_berjemur, 0),
        COALESCE(v_hari_olahraga, 0),
        COALESCE(v_hari_udara, 0),
        COALESCE(v_hari_minum, 0),
        COALESCE(v_hari_tidur, 0)
    )
    ON CONFLICT (user_id, tahun, minggu_ke)
    DO UPDATE SET
        poin_berjemur = EXCLUDED.poin_berjemur,
        poin_olahraga = EXCLUDED.poin_olahraga,
        poin_udara = EXCLUDED.poin_udara,
        poin_minum = EXCLUDED.poin_minum,
        poin_tidur = EXCLUDED.poin_tidur,
        poin_makan = EXCLUDED.poin_makan,
        total_poin = EXCLUDED.total_poin,
        persentase_pencapaian = EXCLUDED.persentase_pencapaian,
        hari_berjemur = EXCLUDED.hari_berjemur,
        hari_olahraga = EXCLUDED.hari_olahraga,
        hari_udara = EXCLUDED.hari_udara,
        hari_minum = EXCLUDED.hari_minum,
        hari_tidur = EXCLUDED.hari_tidur,
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- TRIGGERS
-- =====================================================

-- Trigger untuk auto-update updated_at
CREATE TRIGGER update_daily_activities_updated_at
    BEFORE UPDATE ON sehat_daily_activities
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_kpi_weekly_updated_at
    BEFORE UPDATE ON sehat_kpi_weekly
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_kpi_monthly_updated_at
    BEFORE UPDATE ON sehat_kpi_monthly
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- SAMPLE DATA untuk menu_makanan
-- Structure sesuai dengan Gemini API response
-- =====================================================

INSERT INTO menu_makanan (
    nama_makanan,
    kategori,
    persentase_serat,
    persentase_protein,
    persentase_karbo,
    serat_gram,
    protein_gram,
    karbo_gram,
    lemak_gram,
    kalori,
    ukuran_porsi,
    deskripsi,
    mengandung_minyak,
    mengandung_gula,
    sumber
) VALUES
(
    'Nasi Putih + Ayam + Sayur',
    'makan_siang',
    25.0, 35.0, 40.0,
    12.5, 17.5, 20.0, 10.0,
    500,
    '1 piring (300g)',
    'Nasi putih dengan ayam panggang dan sayuran rebus',
    FALSE, FALSE,
    'manual'
),
(
    'Oatmeal + Buah',
    'sarapan',
    30.0, 20.0, 50.0,
    9.0, 6.0, 15.0, 5.0,
    300,
    '1 mangkuk (250g)',
    'Oatmeal dengan potongan buah segar',
    FALSE, FALSE,
    'manual'
),
(
    'Salad Sayur + Tuna',
    'makan_malam',
    40.0, 35.0, 25.0,
    14.0, 12.3, 8.8, 8.0,
    350,
    '1 mangkuk besar (350g)',
    'Salad sayuran hijau dengan tuna kalengan',
    FALSE, FALSE,
    'manual'
),
(
    'Roti Gandum + Telur',
    'sarapan',
    28.0, 30.0, 42.0,
    7.8, 8.4, 11.8, 6.0,
    280,
    '2 lembar roti + 2 telur',
    'Roti gandum dengan telur rebus atau orak-arik',
    FALSE, FALSE,
    'manual'
),
(
    'Nasi Merah + Ikan + Tempe',
    'makan_siang',
    30.0, 35.0, 35.0,
    13.5, 15.8, 15.8, 10.0,
    450,
    '1 piring (350g)',
    'Nasi merah dengan ikan bakar dan tempe goreng',
    TRUE, FALSE,
    'manual'
),
(
    'Nasi Goreng',
    'makan_siang',
    18.5, 22.3, 59.2,
    8.3, 10.0, 26.6, 15.0,
    450,
    '1 piring (300g)',
    'Nasi goreng standar dengan telur dan sayuran',
    TRUE, FALSE,
    'manual'
),
(
    'Gado-Gado',
    'makan_siang',
    35.0, 25.0, 40.0,
    14.0, 10.0, 16.0, 12.0,
    400,
    '1 piring (350g)',
    'Sayuran rebus dengan bumbu kacang',
    FALSE, TRUE,
    'manual'
),
(
    'Soto Ayam',
    'makan_siang',
    20.0, 30.0, 50.0,
    8.0, 12.0, 20.0, 8.0,
    380,
    '1 mangkuk (400ml)',
    'Sup ayam dengan nasi dan bumbu rempah',
    FALSE, FALSE,
    'manual'
);

