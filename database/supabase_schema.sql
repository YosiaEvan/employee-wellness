-- =====================================================
-- EMPLOYEE WELLNESS DATABASE SCHEMA
-- For Supabase PostgreSQL
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. PROFILES TABLE
-- =====================================================
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
    name TEXT NOT NULL,
    phone TEXT,
    address TEXT,
    birth_date DATE,
    gender TEXT CHECK (gender IN ('male', 'female', 'other')),
    avatar TEXT,
    bio TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Row Level Security for profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
    ON profiles FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = user_id);

-- =====================================================
-- 2. HEALTH DATA TABLES (SEHAT)
-- =====================================================

-- Health Steps
CREATE TABLE health_steps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    date DATE NOT NULL,
    steps INTEGER NOT NULL DEFAULT 0,
    distance DECIMAL(10,2), -- in km
    calories INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- Health Metrics (weight, BP, etc)
CREATE TABLE health_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    weight DECIMAL(5,2),
    height DECIMAL(5,2),
    heart_rate INTEGER,
    bp_systolic INTEGER,
    bp_diastolic INTEGER,
    blood_sugar DECIMAL(5,2),
    notes TEXT,
    measured_at TIMESTAMPTZ DEFAULT NOW()
);

-- Health Goals
CREATE TABLE health_goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
    daily_steps_goal INTEGER DEFAULT 10000,
    weekly_exercise_goal INTEGER DEFAULT 5,
    weight_goal DECIMAL(5,2),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for health tables
ALTER TABLE health_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_goals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own health_steps"
    ON health_steps FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own health_metrics"
    ON health_metrics FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own health_goals"
    ON health_goals FOR ALL
    USING (auth.uid() = user_id);

-- =====================================================
-- 3. ENVIRONMENTAL DATA TABLES (HIJAU)
-- =====================================================

-- Green Activities
CREATE TABLE green_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    activity_type TEXT NOT NULL,
    description TEXT,
    carbon_saved DECIMAL(10,2), -- in kg CO2
    points INTEGER DEFAULT 0,
    date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Transportation Log
CREATE TABLE transportation_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    transport_type TEXT NOT NULL CHECK (transport_type IN ('walking', 'bicycle', 'public_transport', 'motorbike', 'car')),
    distance DECIMAL(10,2) NOT NULL, -- in km
    carbon_emission DECIMAL(10,2), -- in kg CO2
    date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Environmental Goals
CREATE TABLE environmental_goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
    monthly_carbon_goal DECIMAL(10,2) DEFAULT 100.0,
    weekly_green_activities_goal INTEGER DEFAULT 3,
    preferred_transport TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for environmental tables
ALTER TABLE green_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE transportation_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE environmental_goals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own green_activities"
    ON green_activities FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own transportation_log"
    ON transportation_log FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own environmental_goals"
    ON environmental_goals FOR ALL
    USING (auth.uid() = user_id);

-- =====================================================
-- 4. MENTAL WELLNESS TABLES (TENANG)
-- =====================================================

-- Mood Tracker
CREATE TABLE mood_tracker (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    mood_score INTEGER NOT NULL CHECK (mood_score BETWEEN 1 AND 5),
    emotions TEXT[], -- Array of emotions
    notes TEXT,
    date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Meditation Sessions
CREATE TABLE meditation_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    meditation_type TEXT NOT NULL,
    duration INTEGER NOT NULL, -- in minutes
    notes TEXT,
    date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Journal Entries
CREATE TABLE journal_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    mood_score INTEGER CHECK (mood_score BETWEEN 1 AND 5),
    tags TEXT[],
    date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Mental Wellness Goals
CREATE TABLE mental_wellness_goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
    daily_meditation_minutes INTEGER DEFAULT 20,
    weekly_journal_entries INTEGER DEFAULT 5,
    stress_management_plan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for mental wellness tables
ALTER TABLE mood_tracker ENABLE ROW LEVEL SECURITY;
ALTER TABLE meditation_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE mental_wellness_goals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own mood_tracker"
    ON mood_tracker FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own meditation_sessions"
    ON meditation_sessions FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own journal_entries"
    ON journal_entries FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own mental_wellness_goals"
    ON mental_wellness_goals FOR ALL
    USING (auth.uid() = user_id);

-- =====================================================
-- 5. INDEXES FOR PERFORMANCE
-- =====================================================

-- Profiles
CREATE INDEX idx_profiles_user_id ON profiles(user_id);

-- Health
CREATE INDEX idx_health_steps_user_date ON health_steps(user_id, date DESC);
CREATE INDEX idx_health_metrics_user_date ON health_metrics(user_id, measured_at DESC);
CREATE INDEX idx_health_goals_user ON health_goals(user_id);

-- Environmental
CREATE INDEX idx_green_activities_user_date ON green_activities(user_id, date DESC);
CREATE INDEX idx_transportation_user_date ON transportation_log(user_id, date DESC);
CREATE INDEX idx_environmental_goals_user ON environmental_goals(user_id);

-- Mental
CREATE INDEX idx_mood_tracker_user_date ON mood_tracker(user_id, date DESC);
CREATE INDEX idx_meditation_user_date ON meditation_sessions(user_id, date DESC);
CREATE INDEX idx_journal_user_date ON journal_entries(user_id, date DESC);
CREATE INDEX idx_mental_goals_user ON mental_wellness_goals(user_id);

-- =====================================================
-- 6. FUNCTIONS & TRIGGERS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_health_steps_updated_at
    BEFORE UPDATE ON health_steps
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_health_goals_updated_at
    BEFORE UPDATE ON health_goals
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_environmental_goals_updated_at
    BEFORE UPDATE ON environmental_goals
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_mental_wellness_goals_updated_at
    BEFORE UPDATE ON mental_wellness_goals
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_journal_entries_updated_at
    BEFORE UPDATE ON journal_entries
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 7. AGGREGATE FUNCTIONS
-- =====================================================

-- Calculate wellness score
CREATE OR REPLACE FUNCTION calculate_wellness_score(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    health_score NUMERIC;
    mental_score NUMERIC;
    env_score NUMERIC;
    total_score NUMERIC;
BEGIN
    -- Health score (based on steps goal achievement)
    SELECT AVG(
        CASE
            WHEN s.steps >= COALESCE(g.daily_steps_goal, 10000) THEN 100
            ELSE (s.steps::NUMERIC / COALESCE(g.daily_steps_goal, 10000)) * 100
        END
    ) INTO health_score
    FROM health_steps s
    LEFT JOIN health_goals g ON g.user_id = p_user_id
    WHERE s.user_id = p_user_id
    AND s.date >= CURRENT_DATE - INTERVAL '7 days';

    -- Mental score (based on mood average)
    SELECT AVG(mood_score) * 20 INTO mental_score
    FROM mood_tracker
    WHERE user_id = p_user_id
    AND date >= CURRENT_DATE - INTERVAL '7 days';

    -- Environmental score (based on activities)
    SELECT COUNT(*) * 10 INTO env_score
    FROM green_activities
    WHERE user_id = p_user_id
    AND date >= CURRENT_DATE - INTERVAL '7 days';

    -- Calculate total (average of available scores)
    total_score := COALESCE(
        (COALESCE(health_score, 0) + COALESCE(mental_score, 0) + COALESCE(env_score, 0)) /
        NULLIF((
            CASE WHEN health_score IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN mental_score IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN env_score IS NOT NULL THEN 1 ELSE 0 END
        ), 0),
        0
    );

    RETURN json_build_object(
        'health_score', COALESCE(health_score, 0),
        'mental_score', COALESCE(mental_score, 0),
        'environmental_score', COALESCE(env_score, 0),
        'total_score', total_score
    );
END;
$$ LANGUAGE plpgsql;

-- Get weekly summary
CREATE OR REPLACE FUNCTION get_weekly_summary(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    total_steps INTEGER;
    total_activities INTEGER;
    avg_mood NUMERIC;
BEGIN
    -- Total steps this week
    SELECT SUM(steps) INTO total_steps
    FROM health_steps
    WHERE user_id = p_user_id
    AND date >= CURRENT_DATE - INTERVAL '7 days';

    -- Total green activities
    SELECT COUNT(*) INTO total_activities
    FROM green_activities
    WHERE user_id = p_user_id
    AND date >= CURRENT_DATE - INTERVAL '7 days';

    -- Average mood
    SELECT AVG(mood_score) INTO avg_mood
    FROM mood_tracker
    WHERE user_id = p_user_id
    AND date >= CURRENT_DATE - INTERVAL '7 days';

    RETURN json_build_object(
        'total_steps', COALESCE(total_steps, 0),
        'total_green_activities', COALESCE(total_activities, 0),
        'average_mood', COALESCE(avg_mood, 0)
    );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 8. STORAGE BUCKETS
-- =====================================================

-- Create storage bucket for avatars
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true);

-- Create storage bucket for wellness media
INSERT INTO storage.buckets (id, name, public)
VALUES ('wellness-media', 'wellness-media', true);

-- Storage policies
CREATE POLICY "Avatar images are publicly accessible"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'avatars'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can update their own avatar"
    ON storage.objects FOR UPDATE
    WITH CHECK (
        bucket_id = 'avatars'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- =====================================================
-- END OF SCHEMA
-- =====================================================

