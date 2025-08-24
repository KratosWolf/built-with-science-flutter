-- Built With Science - Clean Database Schema
-- No syntax errors version

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Programs (3-day, 4-day, 5-day)
CREATE TABLE programs (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    days_per_week INTEGER DEFAULT 3,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Program Days (Full Body A, Full Body B)
CREATE TABLE program_days (
    id SERIAL PRIMARY KEY,
    program_id INTEGER NOT NULL REFERENCES programs(id) ON DELETE CASCADE,
    day_index INTEGER NOT NULL,
    day_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Exercises (master list)
CREATE TABLE exercises (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    muscle_groups TEXT[],
    category VARCHAR(100),
    equipment VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Exercise Variations (different ways to perform same exercise)
CREATE TABLE exercise_variations (
    id SERIAL PRIMARY KEY,
    exercise_id INTEGER NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    variation_index INTEGER NOT NULL,
    variation_name VARCHAR(255) NOT NULL,
    youtube_url VARCHAR(500),
    is_primary BOOLEAN DEFAULT FALSE,
    difficulty_level VARCHAR(50) DEFAULT 'intermediate',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Day Exercises (exercises assigned to specific program days)
CREATE TABLE day_exercises (
    id SERIAL PRIMARY KEY,
    program_day_id INTEGER NOT NULL REFERENCES program_days(id) ON DELETE CASCADE,
    exercise_id INTEGER NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    order_pos INTEGER NOT NULL,
    set_target INTEGER NOT NULL DEFAULT 3,
    rest_sec INTEGER DEFAULT 120,
    is_superset BOOLEAN DEFAULT FALSE,
    superset_label VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Day Exercise Sets (specific set configurations for each exercise)
CREATE TABLE day_exercise_sets (
    id SERIAL PRIMARY KEY,
    day_exercise_id INTEGER NOT NULL REFERENCES day_exercises(id) ON DELETE CASCADE,
    set_number INTEGER NOT NULL,
    reps_target VARCHAR(20) NOT NULL,
    intensity_pct DECIMAL(4,1),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Users (extends Supabase auth.users)
CREATE TABLE workout_users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255),
    display_name VARCHAR(255),
    unit VARCHAR(10) DEFAULT 'kg' CHECK (unit IN ('kg', 'lb')),
    suggestion_aggressiveness VARCHAR(20) DEFAULT 'standard' CHECK (suggestion_aggressiveness IN ('conservative', 'standard', 'aggressive')),
    video_pref VARCHAR(20) DEFAULT 'smart' CHECK (video_pref IN ('youtube', 'guide', 'smart')),
    current_program_id INTEGER REFERENCES programs(id),
    onboarding_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Workout Sessions (individual workout instances)
CREATE TABLE workout_sessions (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES workout_users(id) ON DELETE CASCADE,
    program_id INTEGER NOT NULL REFERENCES programs(id) ON DELETE RESTRICT,
    program_day_id INTEGER NOT NULL REFERENCES program_days(id) ON DELETE RESTRICT,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    finished_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'done', 'abandoned')),
    notes TEXT,
    total_duration_sec INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Workout Sets (individual sets performed during workouts)
CREATE TABLE workout_sets (
    id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
    exercise_id INTEGER NOT NULL REFERENCES exercises(id) ON DELETE RESTRICT,
    variation_index INTEGER DEFAULT 1,
    set_number INTEGER NOT NULL,
    weight_kg DECIMAL(6,2),
    reps INTEGER,
    rest_sec INTEGER,
    rpe DECIMAL(3,1) CHECK (rpe >= 1 AND rpe <= 10),
    difficulty VARCHAR(20) CHECK (difficulty IN ('easy', 'medium', 'hard', 'max_effort', 'failed')),
    duration_sec INTEGER,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Last Set Cache (for quick progression suggestions)
CREATE TABLE last_set_cache (
    user_id UUID NOT NULL REFERENCES workout_users(id) ON DELETE CASCADE,
    exercise_id INTEGER NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    variation_index INTEGER DEFAULT 1,
    weight_kg DECIMAL(6,2),
    reps INTEGER,
    rest_sec INTEGER,
    difficulty VARCHAR(20),
    sets JSONB,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, exercise_id, variation_index)
);

-- User Exercise PRs (Personal Records)
CREATE TABLE exercise_prs (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES workout_users(id) ON DELETE CASCADE,
    exercise_id INTEGER NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    variation_index INTEGER DEFAULT 1,
    pr_type VARCHAR(20) NOT NULL CHECK (pr_type IN ('1rm', 'max_reps', 'max_volume')), 
    weight_kg DECIMAL(6,2),
    reps INTEGER,
    estimated_1rm DECIMAL(6,2),
    achieved_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    session_id INTEGER REFERENCES workout_sessions(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, exercise_id, variation_index, pr_type)
);

-- Create indexes
CREATE INDEX idx_program_days_program_id ON program_days(program_id);
CREATE INDEX idx_day_exercises_program_day_id ON day_exercises(program_day_id);
CREATE INDEX idx_day_exercises_exercise_id ON day_exercises(exercise_id);
CREATE INDEX idx_day_exercise_sets_day_exercise_id ON day_exercise_sets(day_exercise_id);
CREATE INDEX idx_exercise_variations_exercise_id ON exercise_variations(exercise_id);
CREATE INDEX idx_exercise_variations_primary ON exercise_variations(exercise_id, is_primary);
CREATE INDEX idx_workout_sessions_user_id ON workout_sessions(user_id);
CREATE INDEX idx_workout_sessions_status ON workout_sessions(status);
CREATE INDEX idx_workout_sessions_started_at ON workout_sessions(started_at);
CREATE INDEX idx_workout_sets_session_id ON workout_sets(session_id);
CREATE INDEX idx_workout_sets_exercise_id ON workout_sets(exercise_id);
CREATE INDEX idx_workout_sets_created_at ON workout_sets(created_at);
CREATE INDEX idx_last_set_cache_user_exercise ON last_set_cache(user_id, exercise_id);
CREATE INDEX idx_exercise_prs_user_id ON exercise_prs(user_id);
CREATE INDEX idx_exercise_prs_exercise_id ON exercise_prs(exercise_id);

-- Enable RLS on user-specific tables
ALTER TABLE workout_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE last_set_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_prs ENABLE ROW LEVEL SECURITY;

-- Users can only see their own data
CREATE POLICY "Users can manage their own profile" ON workout_users
    FOR ALL USING (auth.uid() = id);

CREATE POLICY "Users can manage their own workout sessions" ON workout_sessions
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their own workout sets" ON workout_sets
    FOR ALL USING (auth.uid() = (SELECT user_id FROM workout_sessions WHERE id = session_id));

CREATE POLICY "Users can manage their own cache" ON last_set_cache
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their own PRs" ON exercise_prs
    FOR ALL USING (auth.uid() = user_id);

-- Public read access for program structure
ALTER TABLE programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE program_days ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_variations ENABLE ROW LEVEL SECURITY;
ALTER TABLE day_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE day_exercise_sets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Programs are publicly readable" ON programs FOR SELECT TO public USING (true);
CREATE POLICY "Program days are publicly readable" ON program_days FOR SELECT TO public USING (true);
CREATE POLICY "Exercises are publicly readable" ON exercises FOR SELECT TO public USING (true);
CREATE POLICY "Exercise variations are publicly readable" ON exercise_variations FOR SELECT TO public USING (true);
CREATE POLICY "Day exercises are publicly readable" ON day_exercises FOR SELECT TO public USING (true);
CREATE POLICY "Day exercise sets are publicly readable" ON day_exercise_sets FOR SELECT TO public USING (true);

-- Auto-update updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_programs_updated_at BEFORE UPDATE ON programs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workout_users_updated_at BEFORE UPDATE ON workout_users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workout_sessions_updated_at BEFORE UPDATE ON workout_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Auto-update cache when workout sets are inserted/updated
CREATE OR REPLACE FUNCTION update_last_set_cache()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.weight_kg IS NOT NULL AND NEW.reps IS NOT NULL AND NEW.difficulty IS NOT NULL THEN
        INSERT INTO last_set_cache (
            user_id, 
            exercise_id, 
            variation_index, 
            weight_kg, 
            reps, 
            rest_sec, 
            difficulty,
            updated_at
        ) 
        SELECT 
            ws.user_id, 
            NEW.exercise_id, 
            COALESCE(NEW.variation_index, 1), 
            NEW.weight_kg, 
            NEW.reps, 
            NEW.rest_sec, 
            NEW.difficulty,
            CURRENT_TIMESTAMP
        FROM workout_sessions ws 
        WHERE ws.id = NEW.session_id
        ON CONFLICT (user_id, exercise_id, variation_index) 
        DO UPDATE SET
            weight_kg = EXCLUDED.weight_kg,
            reps = EXCLUDED.reps,
            rest_sec = EXCLUDED.rest_sec,
            difficulty = EXCLUDED.difficulty,
            updated_at = EXCLUDED.updated_at;
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_update_last_set_cache 
    AFTER INSERT OR UPDATE ON workout_sets
    FOR EACH ROW EXECUTE FUNCTION update_last_set_cache();