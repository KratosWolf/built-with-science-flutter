-- Built With Science - Supabase Database Schema
-- Run this in Supabase SQL Editor

-- Enable Row Level Security (RLS) for all tables
ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

-- 1. User Profiles Table
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for user_profiles
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see/edit their own profile
CREATE POLICY "Users can view own profile" ON user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- 2. Workout Sessions Table
CREATE TABLE IF NOT EXISTS workout_sessions (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE NOT NULL,
    program_id INTEGER NOT NULL,
    day_id INTEGER NOT NULL,
    exercise_id INTEGER NOT NULL,
    set_number INTEGER NOT NULL,
    weight_kg DECIMAL(5,2),
    reps INTEGER,
    difficulty TEXT CHECK (difficulty IN ('Muito Fácil', 'Fácil', 'Perfeito', 'Difícil', 'Muito Difícil')),
    notes TEXT,
    completed_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Unique constraint to prevent duplicate sets
    UNIQUE(user_id, program_id, day_id, exercise_id, set_number)
);

-- Enable RLS for workout_sessions
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see/edit their own workout sessions
CREATE POLICY "Users can view own workout sessions" ON workout_sessions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own workout sessions" ON workout_sessions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own workout sessions" ON workout_sessions
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own workout sessions" ON workout_sessions
    FOR DELETE USING (auth.uid() = user_id);

-- 3. Workout Programs Table (Reference data)
CREATE TABLE IF NOT EXISTS workout_programs (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    days_per_week INTEGER NOT NULL,
    difficulty_level TEXT CHECK (difficulty_level IN ('Beginner', 'Intermediate', 'Advanced')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default programs
INSERT INTO workout_programs (id, name, description, days_per_week, difficulty_level) VALUES
(1, 'Beginner Full Body', 'Science-based full body workout for beginners', 3, 'Beginner'),
(2, 'Intermediate Upper/Lower', 'Upper/lower split for intermediate lifters', 4, 'Intermediate'),
(3, 'Advanced Push/Pull/Legs', 'Push/pull/legs split for advanced lifters', 5, 'Advanced')
ON CONFLICT (id) DO NOTHING;

-- 4. Workout Days Table (Reference data)  
CREATE TABLE IF NOT EXISTS workout_days (
    id INTEGER PRIMARY KEY,
    program_id INTEGER REFERENCES workout_programs(id) ON DELETE CASCADE,
    day_index INTEGER NOT NULL,
    day_name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default workout days
INSERT INTO workout_days (id, program_id, day_index, day_name) VALUES
-- Beginner Full Body (Program 1)
(1, 1, 1, 'Full Body A'),
(2, 1, 2, 'Full Body B'),
(3, 1, 3, 'Full Body C'),
-- Intermediate Upper/Lower (Program 2)
(4, 2, 1, 'Upper Body'),
(5, 2, 2, 'Lower Body'),
(6, 2, 3, 'Upper Body'),
(7, 2, 4, 'Lower Body'),
-- Advanced PPL (Program 3)
(8, 3, 1, 'Push'),
(9, 3, 2, 'Pull'),
(10, 3, 3, 'Legs'),
(11, 3, 4, 'Push'),
(12, 3, 5, 'Pull')
ON CONFLICT (id) DO NOTHING;

-- 5. User Statistics View
CREATE OR REPLACE VIEW user_workout_stats AS
SELECT 
    user_id,
    COUNT(*) as total_sets,
    COUNT(DISTINCT exercise_id) as total_exercises,
    COUNT(DISTINCT CONCAT(program_id, '-', day_id, '-', DATE(completed_at))) as total_workouts,
    SUM(CASE WHEN weight_kg IS NOT NULL AND reps IS NOT NULL 
        THEN weight_kg * reps ELSE 0 END) as total_weight_lifted,
    MIN(completed_at) as first_workout,
    MAX(completed_at) as last_workout
FROM workout_sessions
GROUP BY user_id;

-- 6. Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_program_day 
ON workout_sessions(user_id, program_id, day_id);

CREATE INDEX IF NOT EXISTS idx_workout_sessions_completed_at 
ON workout_sessions(completed_at);

CREATE INDEX IF NOT EXISTS idx_workout_sessions_exercise_id 
ON workout_sessions(exercise_id);

-- 7. Functions

-- Function to get user's last workout data for a specific program/day
CREATE OR REPLACE FUNCTION get_last_workout_data(
    p_user_id UUID,
    p_program_id INTEGER,
    p_day_id INTEGER
)
RETURNS TABLE (
    exercise_id INTEGER,
    set_number INTEGER,
    weight_kg DECIMAL,
    reps INTEGER,
    difficulty TEXT,
    completed_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ws.exercise_id,
        ws.set_number,
        ws.weight_kg,
        ws.reps,
        ws.difficulty,
        ws.completed_at
    FROM workout_sessions ws
    WHERE ws.user_id = p_user_id
        AND ws.program_id = p_program_id  
        AND ws.day_id = p_day_id
    ORDER BY ws.exercise_id, ws.set_number;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update user profile updated_at timestamp
CREATE OR REPLACE FUNCTION update_user_profile_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update user_profiles.updated_at
DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON user_profiles;
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_user_profile_updated_at();

-- Grant access to authenticated users
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated;

-- Refresh RLS policies
ALTER TABLE user_profiles FORCE ROW LEVEL SECURITY;
ALTER TABLE workout_sessions FORCE ROW LEVEL SECURITY;

COMMIT;