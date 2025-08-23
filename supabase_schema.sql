-- Built With Science App - Supabase Database Schema
-- Run these commands in the Supabase SQL Editor

-- Enable Row Level Security
ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM PUBLIC;

-- 1. Users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.workout_users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT,
  display_name TEXT,
  unit TEXT DEFAULT 'kg' CHECK (unit IN ('kg', 'lb')),
  suggestion_aggressiveness TEXT DEFAULT 'standard' CHECK (suggestion_aggressiveness IN ('conservative', 'standard', 'aggressive')),
  video_pref TEXT DEFAULT 'smart' CHECK (video_pref IN ('youtube', 'guide', 'smart')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Programs table
CREATE TABLE IF NOT EXISTS public.programs (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Program days table
CREATE TABLE IF NOT EXISTS public.program_days (
  id SERIAL PRIMARY KEY,
  program_id INTEGER REFERENCES programs(id) ON DELETE CASCADE,
  day_index INTEGER NOT NULL,
  day_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Exercises table
CREATE TABLE IF NOT EXISTS public.exercises (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  muscle_group TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Exercise variations table
CREATE TABLE IF NOT EXISTS public.exercise_variations (
  id SERIAL PRIMARY KEY,
  exercise_id INTEGER REFERENCES exercises(id) ON DELETE CASCADE,
  variation_index INTEGER NOT NULL,
  variation_name TEXT NOT NULL,
  youtube_url TEXT,
  is_primary BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(exercise_id, variation_index)
);

-- 6. Day exercises table (which exercises are in each program day)
CREATE TABLE IF NOT EXISTS public.day_exercises (
  id SERIAL PRIMARY KEY,
  program_day_id INTEGER REFERENCES program_days(id) ON DELETE CASCADE,
  exercise_id INTEGER REFERENCES exercises(id) ON DELETE CASCADE,
  order_pos INTEGER NOT NULL,
  sets INTEGER NOT NULL,
  reps_target TEXT NOT NULL,
  is_superset BOOLEAN DEFAULT FALSE,
  superset_label TEXT,
  superset_exercise_label TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Workout sessions table
CREATE TABLE IF NOT EXISTS public.workout_sessions (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  program_id INTEGER REFERENCES programs(id),
  program_day_id INTEGER REFERENCES program_days(id),
  started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  finished_at TIMESTAMP WITH TIME ZONE,
  status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'done', 'cancelled')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Workout sets table (individual sets performed)
CREATE TABLE IF NOT EXISTS public.workout_sets (
  id SERIAL PRIMARY KEY,
  session_id INTEGER REFERENCES workout_sessions(id) ON DELETE CASCADE,
  exercise_id INTEGER REFERENCES exercises(id),
  variation_index INTEGER,
  set_number INTEGER NOT NULL,
  weight_kg DECIMAL(5,2),
  reps INTEGER,
  rest_sec INTEGER,
  rpe DECIMAL(3,1), -- Rate of Perceived Exertion (1.0 - 10.0)
  difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard', 'max_effort', 'failed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Last set cache table (for quick access to previous workout data)
CREATE TABLE IF NOT EXISTS public.last_set_cache (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id INTEGER REFERENCES exercises(id),
  variation_index INTEGER,
  weight_kg DECIMAL(5,2),
  reps INTEGER,
  rest_sec INTEGER,
  difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard', 'max_effort', 'failed')),
  sets_data JSONB, -- Store array of sets for quick access
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, exercise_id)
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_id ON workout_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_status ON workout_sessions(status);
CREATE INDEX IF NOT EXISTS idx_workout_sets_session_id ON workout_sets(session_id);
CREATE INDEX IF NOT EXISTS idx_workout_sets_exercise_id ON workout_sets(exercise_id);
CREATE INDEX IF NOT EXISTS idx_last_set_cache_user_exercise ON last_set_cache(user_id, exercise_id);
CREATE INDEX IF NOT EXISTS idx_exercise_variations_exercise_id ON exercise_variations(exercise_id);
CREATE INDEX IF NOT EXISTS idx_day_exercises_program_day_id ON day_exercises(program_day_id);

-- Row Level Security (RLS) Policies
ALTER TABLE public.workout_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.last_set_cache ENABLE ROW LEVEL SECURITY;

-- RLS Policies for workout_users
CREATE POLICY "Users can view own profile" ON public.workout_users
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.workout_users
  FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.workout_users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- RLS Policies for workout_sessions
CREATE POLICY "Users can view own sessions" ON public.workout_sessions
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own sessions" ON public.workout_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own sessions" ON public.workout_sessions
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own sessions" ON public.workout_sessions
  FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for workout_sets
CREATE POLICY "Users can view own workout sets" ON public.workout_sets
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM workout_sessions ws 
      WHERE ws.id = workout_sets.session_id 
      AND ws.user_id = auth.uid()
    )
  );
CREATE POLICY "Users can create own workout sets" ON public.workout_sets
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM workout_sessions ws 
      WHERE ws.id = workout_sets.session_id 
      AND ws.user_id = auth.uid()
    )
  );
CREATE POLICY "Users can update own workout sets" ON public.workout_sets
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM workout_sessions ws 
      WHERE ws.id = workout_sets.session_id 
      AND ws.user_id = auth.uid()
    )
  );
CREATE POLICY "Users can delete own workout sets" ON public.workout_sets
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM workout_sessions ws 
      WHERE ws.id = workout_sets.session_id 
      AND ws.user_id = auth.uid()
    )
  );

-- RLS Policies for last_set_cache
CREATE POLICY "Users can view own cache" ON public.last_set_cache
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own cache" ON public.last_set_cache
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own cache" ON public.last_set_cache
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own cache" ON public.last_set_cache
  FOR DELETE USING (auth.uid() = user_id);

-- Public read access for reference data (no user-specific data)
ALTER TABLE public.programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.program_days ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exercise_variations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.day_exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to programs" ON public.programs
  FOR SELECT USING (true);
CREATE POLICY "Allow public read access to program_days" ON public.program_days
  FOR SELECT USING (true);
CREATE POLICY "Allow public read access to exercises" ON public.exercises
  FOR SELECT USING (true);
CREATE POLICY "Allow public read access to exercise_variations" ON public.exercise_variations
  FOR SELECT USING (true);
CREATE POLICY "Allow public read access to day_exercises" ON public.day_exercises
  FOR SELECT USING (true);

-- Functions for automatic timestamp updates
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for automatic timestamp updates
CREATE TRIGGER update_workout_users_updated_at 
  BEFORE UPDATE ON public.workout_users 
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_last_set_cache_updated_at 
  BEFORE UPDATE ON public.last_set_cache 
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Insert initial data
INSERT INTO public.programs (name, description) VALUES
('3-day Program', 'Science-based 3-day full body workout program for optimal muscle growth'),
('4-day Program', 'Upper/Lower split program for intermediate trainees'),
('5-day Program', 'Push/Pull/Legs split for advanced trainees')
ON CONFLICT DO NOTHING;

-- Get program IDs for reference
-- Note: Run this after the programs are inserted to get the actual IDs
-- You can check the IDs with: SELECT id, name FROM programs;