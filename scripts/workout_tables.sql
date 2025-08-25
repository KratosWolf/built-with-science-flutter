-- Tabela para sessões de treino
CREATE TABLE IF NOT EXISTS workout_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  program_id INTEGER NOT NULL,
  day_id INTEGER NOT NULL,
  day_name TEXT NOT NULL,
  user_id UUID REFERENCES auth.users(id),
  started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'cancelled')),
  total_exercises INTEGER DEFAULT 0,
  completed_exercises INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela para sets individuais de cada exercício
CREATE TABLE IF NOT EXISTS workout_sets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id UUID REFERENCES workout_sessions(id) ON DELETE CASCADE,
  exercise_id INTEGER NOT NULL,
  exercise_name TEXT NOT NULL,
  set_number INTEGER NOT NULL,
  weight_kg DECIMAL(5,2),
  reps INTEGER,
  difficulty TEXT CHECK (difficulty IN ('Too Easy', 'Easy', 'Perfect', 'Hard', 'Too Hard')),
  notes TEXT,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(session_id, exercise_id, set_number)
);

-- Tabela para cache de últimas séries (para sugestões de progressão)
CREATE TABLE IF NOT EXISTS exercise_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  exercise_id INTEGER NOT NULL,
  exercise_name TEXT NOT NULL,
  last_weight_kg DECIMAL(5,2),
  last_reps INTEGER,
  last_difficulty TEXT,
  avg_weight_kg DECIMAL(5,2),
  avg_reps DECIMAL(4,1),
  best_weight_kg DECIMAL(5,2),
  best_reps INTEGER,
  total_sessions INTEGER DEFAULT 1,
  last_performed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, exercise_id)
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_id ON workout_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_program_day ON workout_sessions(program_id, day_id);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_status ON workout_sessions(status);
CREATE INDEX IF NOT EXISTS idx_workout_sets_session_id ON workout_sets(session_id);
CREATE INDEX IF NOT EXISTS idx_workout_sets_exercise_id ON workout_sets(exercise_id);
CREATE INDEX IF NOT EXISTS idx_exercise_history_user_exercise ON exercise_history(user_id, exercise_id);

-- Triggers para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_workout_sessions_updated_at BEFORE UPDATE ON workout_sessions
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_workout_sets_updated_at BEFORE UPDATE ON workout_sets
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_exercise_history_updated_at BEFORE UPDATE ON exercise_history
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- RLS (Row Level Security) - usuários só veem seus próprios dados
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_history ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "Users can view own workout sessions" ON workout_sessions
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own workout sets" ON workout_sets
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM workout_sessions 
            WHERE workout_sessions.id = workout_sets.session_id 
            AND workout_sessions.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can view own exercise history" ON exercise_history
    FOR ALL USING (auth.uid() = user_id);