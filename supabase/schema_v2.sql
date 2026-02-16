-- Schema v2.1 - Built with Science
-- Corrigido compatibilidade total com app Flutter
-- Data: 10/11/2024
-- COMPATÍVEL com lib/services/supabase_service.dart

-- =====================================================
-- LIMPEZA - Dropar tabelas antigas se existirem
-- =====================================================

-- Dropar views primeiro (dependem das tabelas)
DROP VIEW IF EXISTS workout_stats;
DROP VIEW IF EXISTS latest_workout_sets;

-- Dropar triggers
DROP TRIGGER IF EXISTS update_workout_sessions_updated_at ON workout_sessions;
DROP TRIGGER IF EXISTS update_workout_sets_updated_at ON workout_sets;

-- Dropar tabelas (workout_sets primeiro por causa da foreign key)
DROP TABLE IF EXISTS workout_sets CASCADE;
DROP TABLE IF EXISTS workout_sessions CASCADE;
-- Heartbeat não precisa dropar (mantém histórico de keep-alive)

-- =====================================================
-- TABELA DE HEARTBEAT (Keep-Alive)
-- =====================================================
CREATE TABLE IF NOT EXISTS heartbeat (
  id SERIAL PRIMARY KEY,
  ping_at TIMESTAMP DEFAULT NOW(),
  source TEXT DEFAULT 'github-action'
);

-- Função para keep-alive (mantém projeto Supabase ativo)
CREATE OR REPLACE FUNCTION keep_alive()
RETURNS json AS $$
BEGIN
  INSERT INTO heartbeat (ping_at) VALUES (NOW());
  RETURN json_build_object('status', 'alive', 'time', NOW());
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- TABELA PRINCIPAL DE SESSÕES DE TREINO
-- =====================================================
CREATE TABLE workout_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID,  -- Nullable para modo offline
  workout_date DATE NOT NULL,  -- ✅ CAMPO CRÍTICO - data do treino
  workout_type TEXT NOT NULL, -- 'A', 'B', 'C'
  program_id INTEGER,
  duration_minutes INTEGER,
  total_volume DECIMAL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- TABELA DE WORKOUT SETS (RENOMEADA DE workout_exercises)
-- Estrutura EXATA conforme WorkoutSet model no app
-- =====================================================
CREATE TABLE workout_sets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,

  -- Identificação do usuário e sessão
  user_id UUID,  -- Nullable para permitir modo offline
  session_id UUID REFERENCES workout_sessions(id) ON DELETE CASCADE,

  -- Identificação do treino
  program_id INTEGER NOT NULL,  -- ID do programa (3-day, 4-day, etc.)
  day_id INTEGER NOT NULL,      -- ID do dia (A=1, B=2, C=3)
  exercise_id INTEGER NOT NULL, -- ID do exercício

  -- Dados do set
  set_number INTEGER NOT NULL,  -- Número da série (1, 2, 3...)
  weight_kg DECIMAL,            -- Peso em kg (RENOMEADO de 'weight')
  reps INTEGER,                 -- Repetições realizadas
  rpe DECIMAL,                  -- Rate of Perceived Exertion (1-10, permite decimais)
  difficulty TEXT,              -- Nível de dificuldade (RENOMEADO de 'notes')

  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para workout_sessions
CREATE INDEX idx_workout_sessions_date
  ON workout_sessions(workout_date DESC);

CREATE INDEX idx_workout_sessions_user
  ON workout_sessions(user_id);

CREATE INDEX idx_workout_sessions_program
  ON workout_sessions(program_id);

-- Índices para workout_sets
CREATE INDEX idx_workout_sets_user
  ON workout_sets(user_id);

CREATE INDEX idx_workout_sets_session
  ON workout_sets(session_id);

CREATE INDEX idx_workout_sets_program_day
  ON workout_sets(program_id, day_id);

CREATE INDEX idx_workout_sets_exercise
  ON workout_sets(exercise_id);

-- Índice composto para queries de "último treino"
CREATE INDEX idx_workout_sets_lookup
  ON workout_sets(user_id, program_id, day_id, exercise_id, created_at DESC);

-- =====================================================
-- VIEWS PARA ESTATÍSTICAS
-- =====================================================

-- View para estatísticas rápidas de treinos
CREATE VIEW workout_stats AS
SELECT
  user_id,
  COUNT(DISTINCT workout_date) as total_workouts,
  COUNT(DISTINCT DATE_TRUNC('week', workout_date)) as total_weeks,
  MAX(workout_date) as last_workout,
  ROUND(AVG(duration_minutes)) as avg_duration,
  ROUND(AVG(total_volume)) as avg_volume
FROM workout_sessions
WHERE workout_date > NOW() - INTERVAL '90 days'
GROUP BY user_id;

-- View para últimos sets por exercício (usado na restauração)
CREATE VIEW latest_workout_sets AS
SELECT DISTINCT ON (user_id, program_id, day_id, exercise_id, set_number)
  id,
  user_id,
  program_id,
  day_id,
  exercise_id,
  set_number,
  weight_kg,
  reps,
  rpe,
  difficulty,
  created_at
FROM workout_sets
ORDER BY user_id, program_id, day_id, exercise_id, set_number, created_at DESC;

-- =====================================================
-- TRIGGERS
-- =====================================================

-- Trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger em workout_sessions
CREATE TRIGGER update_workout_sessions_updated_at
BEFORE UPDATE ON workout_sessions
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();

-- Aplicar trigger em workout_sets
CREATE TRIGGER update_workout_sets_updated_at
BEFORE UPDATE ON workout_sets
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();

-- =====================================================
-- POLÍTICAS RLS (Row Level Security)
-- Cada usuário só vê seus próprios dados
-- =====================================================

-- Habilitar RLS nas tabelas
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sets ENABLE ROW LEVEL SECURITY;

-- Políticas para workout_sessions
CREATE POLICY "Users can view own sessions" ON workout_sessions
  FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can insert own sessions" ON workout_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can update own sessions" ON workout_sessions
  FOR UPDATE USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can delete own sessions" ON workout_sessions
  FOR DELETE USING (auth.uid() = user_id OR user_id IS NULL);

-- Políticas para workout_sets
CREATE POLICY "Users can view own sets" ON workout_sets
  FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can insert own sets" ON workout_sets
  FOR INSERT WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can update own sets" ON workout_sets
  FOR UPDATE USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can delete own sets" ON workout_sets
  FOR DELETE USING (auth.uid() = user_id OR user_id IS NULL);

-- =====================================================
-- FUNÇÕES UTILITÁRIAS
-- =====================================================

-- Função para obter último treino de um exercício
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
  rpe DECIMAL,
  difficulty TEXT,
  created_at TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT ON (ws.exercise_id, ws.set_number)
    ws.exercise_id,
    ws.set_number,
    ws.weight_kg,
    ws.reps,
    ws.rpe,
    ws.difficulty,
    ws.created_at
  FROM workout_sets ws
  WHERE ws.user_id = p_user_id
    AND ws.program_id = p_program_id
    AND ws.day_id = p_day_id
  ORDER BY ws.exercise_id, ws.set_number, ws.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- INSERT INICIAL (Keep-Alive)
-- =====================================================
INSERT INTO heartbeat (ping_at, source) VALUES (NOW(), 'initial-setup')
ON CONFLICT DO NOTHING;

-- =====================================================
-- COMENTÁRIOS E DOCUMENTAÇÃO
-- =====================================================
COMMENT ON TABLE workout_sessions IS 'Sessões completas de treino do usuário';
COMMENT ON TABLE workout_sets IS 'Sets individuais de cada exercício (renomeado de workout_exercises)';
COMMENT ON TABLE heartbeat IS 'Tabela para manter projeto Supabase ativo via GitHub Actions';

COMMENT ON COLUMN workout_sessions.workout_date IS 'Data do treino (campo crítico para estatísticas)';
COMMENT ON COLUMN workout_sets.user_id IS 'UUID do usuário autenticado (null para dados offline)';
COMMENT ON COLUMN workout_sets.program_id IS 'ID do programa (ex: 1=3-day, 2=4-day)';
COMMENT ON COLUMN workout_sets.day_id IS 'ID do dia (1=A, 2=B, 3=C)';
COMMENT ON COLUMN workout_sets.exercise_id IS 'ID do exercício no app';
COMMENT ON COLUMN workout_sets.weight_kg IS 'Peso usado em quilogramas';
COMMENT ON COLUMN workout_sets.rpe IS 'Rate of Perceived Exertion (1.0 - 10.0)';
COMMENT ON COLUMN workout_sets.difficulty IS 'Nível de dificuldade percebida (fácil/médio/difícil)';

-- =====================================================
-- FIM DO SCHEMA v2.1
-- =====================================================
-- MUDANÇAS PRINCIPAIS DESTA VERSÃO:
-- 1. Renomeado workout_exercises → workout_sets
-- 2. Adicionado user_id, program_id, day_id, exercise_id
-- 3. Renomeado weight → weight_kg
-- 4. Renomeado notes → difficulty
-- 5. Alterado rpe de INTEGER para DECIMAL
-- 6. Removido exercise_name e exercise_variation (dados vêm do app)
-- 7. Adicionados índices otimizados para queries do app
-- 8. Adicionadas políticas RLS para segurança
-- 9. Adicionada função get_last_workout_data() para restauração
-- 10. Compatível 100% com SupabaseService.saveWorkoutSet() e loadLastWorkoutData()
-- 11. DROP TABLE forçado para garantir recriação completa com workout_date
-- =====================================================
