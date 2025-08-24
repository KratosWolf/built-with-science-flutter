-- Built With Science - Minimal Working Schema
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Programs table
CREATE TABLE programs (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    days_per_week INTEGER DEFAULT 3,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Program Days table
CREATE TABLE program_days (
    id SERIAL PRIMARY KEY,
    program_id INTEGER NOT NULL REFERENCES programs(id) ON DELETE CASCADE,
    day_index INTEGER NOT NULL,
    day_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Exercises table
CREATE TABLE exercises (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    muscle_groups TEXT[],
    category VARCHAR(100),
    equipment VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Exercise Variations table
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

-- Day Exercises table
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

-- Day Exercise Sets table
CREATE TABLE day_exercise_sets (
    id SERIAL PRIMARY KEY,
    day_exercise_id INTEGER NOT NULL REFERENCES day_exercises(id) ON DELETE CASCADE,
    set_number INTEGER NOT NULL,
    reps_target VARCHAR(20) NOT NULL,
    intensity_pct DECIMAL(4,1),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Workout Users table
CREATE TABLE workout_users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255),
    display_name VARCHAR(255),
    unit VARCHAR(10) DEFAULT 'kg',
    suggestion_aggressiveness VARCHAR(20) DEFAULT 'standard',
    video_pref VARCHAR(20) DEFAULT 'smart',
    current_program_id INTEGER REFERENCES programs(id),
    onboarding_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Workout Sessions table
CREATE TABLE workout_sessions (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES workout_users(id) ON DELETE CASCADE,
    program_id INTEGER NOT NULL REFERENCES programs(id) ON DELETE RESTRICT,
    program_day_id INTEGER NOT NULL REFERENCES program_days(id) ON DELETE RESTRICT,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    finished_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'in_progress',
    notes TEXT,
    total_duration_sec INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Workout Sets table
CREATE TABLE workout_sets (
    id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
    exercise_id INTEGER NOT NULL REFERENCES exercises(id) ON DELETE RESTRICT,
    variation_index INTEGER DEFAULT 1,
    set_number INTEGER NOT NULL,
    weight_kg DECIMAL(6,2),
    reps INTEGER,
    rest_sec INTEGER,
    rpe DECIMAL(3,1),
    difficulty VARCHAR(20),
    duration_sec INTEGER,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Last Set Cache table
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

-- Exercise PRs table
CREATE TABLE exercise_prs (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES workout_users(id) ON DELETE CASCADE,
    exercise_id INTEGER NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    variation_index INTEGER DEFAULT 1,
    pr_type VARCHAR(20) NOT NULL,
    weight_kg DECIMAL(6,2),
    reps INTEGER,
    estimated_1rm DECIMAL(6,2),
    achieved_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    session_id INTEGER REFERENCES workout_sessions(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Enable RLS
ALTER TABLE programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE program_days ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_variations ENABLE ROW LEVEL SECURITY;
ALTER TABLE day_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE day_exercise_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE last_set_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_prs ENABLE ROW LEVEL SECURITY;

-- Public read policies
CREATE POLICY "Programs are publicly readable" ON programs FOR SELECT TO public USING (true);
CREATE POLICY "Program days are publicly readable" ON program_days FOR SELECT TO public USING (true);
CREATE POLICY "Exercises are publicly readable" ON exercises FOR SELECT TO public USING (true);
CREATE POLICY "Exercise variations are publicly readable" ON exercise_variations FOR SELECT TO public USING (true);
CREATE POLICY "Day exercises are publicly readable" ON day_exercises FOR SELECT TO public USING (true);
CREATE POLICY "Day exercise sets are publicly readable" ON day_exercise_sets FOR SELECT TO public USING (true);

-- User data policies
CREATE POLICY "Users can manage their own profile" ON workout_users FOR ALL USING (auth.uid() = id);
CREATE POLICY "Users can manage their own workout sessions" ON workout_sessions FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own workout sets" ON workout_sets FOR ALL USING (auth.uid() = (SELECT user_id FROM workout_sessions WHERE id = session_id));
CREATE POLICY "Users can manage their own cache" ON last_set_cache FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own PRs" ON exercise_prs FOR ALL USING (auth.uid() = user_id);