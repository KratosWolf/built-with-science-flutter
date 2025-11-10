-- Schema v2 para Built with Science
-- Simplificado e otimizado para uso pessoal

-- Tabela de heartbeat (manter projeto ativo)
CREATE TABLE IF NOT EXISTS heartbeat (
  id SERIAL PRIMARY KEY,
  ping_at TIMESTAMP DEFAULT NOW(),
  source TEXT DEFAULT 'github-action'
);

-- Função para keep-alive
CREATE OR REPLACE FUNCTION keep_alive()
RETURNS json AS $$
BEGIN
  INSERT INTO heartbeat (ping_at) VALUES (NOW());
  RETURN json_build_object('status', 'alive', 'time', NOW());
END;
$$ LANGUAGE plpgsql;

-- Tabela principal de sessões de treino
CREATE TABLE IF NOT EXISTS workout_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  workout_date DATE NOT NULL,
  workout_type TEXT NOT NULL, -- 'A', 'B', 'C'
  duration_minutes INTEGER,
  total_volume DECIMAL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabela de exercícios realizados
CREATE TABLE IF NOT EXISTS workout_exercises (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id UUID REFERENCES workout_sessions(id) ON DELETE CASCADE,
  exercise_name TEXT NOT NULL,
  exercise_variation TEXT,
  set_number INTEGER NOT NULL,
  weight DECIMAL,
  reps INTEGER,
  rpe INTEGER, -- Rate of Perceived Exertion (1-10)
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_workout_sessions_date ON workout_sessions(workout_date DESC);
CREATE INDEX idx_workout_exercises_session ON workout_exercises(session_id);

-- View para estatísticas rápidas
CREATE OR REPLACE VIEW workout_stats AS
SELECT
  COUNT(DISTINCT workout_date) as total_workouts,
  COUNT(DISTINCT DATE_TRUNC('week', workout_date)) as total_weeks,
  MAX(workout_date) as last_workout,
  ROUND(AVG(duration_minutes)) as avg_duration,
  ROUND(AVG(total_volume)) as avg_volume
FROM workout_sessions
WHERE workout_date > NOW() - INTERVAL '90 days';

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_workout_sessions_updated_at
BEFORE UPDATE ON workout_sessions
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();

-- Insert inicial para manter ativo
INSERT INTO heartbeat (ping_at, source) VALUES (NOW(), 'initial-setup');
