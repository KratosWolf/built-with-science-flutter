-- ============================================================================
-- SUPABASE SECURITY FIX - Built With Science App
-- Projeto: gktvfldykmzhynqthbdn (built-with-science-app)
-- ============================================================================
-- INSTRUÇÕES:
-- 1. Abra o Supabase Dashboard: https://supabase.com/dashboard/project/gktvfldykmzhynqthbdn
-- 2. Vá em: SQL Editor > New Query
-- 3. Cole este script completo e execute
-- 4. Verifique no Security Advisor se os erros foram corrigidos
-- ============================================================================

-- ============================================================================
-- PARTE 1: HABILITAR RLS NAS TABELAS DE DADOS DE USUÁRIO (6 tabelas)
-- ============================================================================

-- 1. workout_sets (JÁ TEM 4 POLÍTICAS CRIADAS, só precisa habilitar RLS!)
ALTER TABLE workout_sets ENABLE ROW LEVEL SECURITY;

-- 2. workout_sessions
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access own workout_sessions"
ON workout_sessions FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 3. exercise_history
ALTER TABLE exercise_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access own exercise_history"
ON exercise_history FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 4. exercise_prs
ALTER TABLE exercise_prs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access own exercise_prs"
ON exercise_prs FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 5. last_set_cache
ALTER TABLE last_set_cache ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access own last_set_cache"
ON last_set_cache FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 6. user_profiles (usa 'id' como PK que corresponde a auth.uid())
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access own profile"
ON user_profiles FOR ALL
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- ============================================================================
-- PARTE 2: CORRIGIR TABELAS DE CATÁLOGO (6 tabelas) - READ-ONLY
-- ============================================================================
-- Estas tabelas contêm dados de exercícios/programas do BWS.
-- Atualmente têm políticas USING(true) que permitem INSERT/UPDATE/DELETE.
-- Vamos trocar para SELECT-only (somente leitura pública).

-- 1. day_exercise_sets
DROP POLICY IF EXISTS "Day exercise sets are publicly accessible" ON day_exercise_sets;
CREATE POLICY "catalog_read_only" ON day_exercise_sets FOR SELECT USING (true);

-- 2. day_exercises
DROP POLICY IF EXISTS "Day exercises are publicly accessible" ON day_exercises;
CREATE POLICY "catalog_read_only" ON day_exercises FOR SELECT USING (true);

-- 3. exercise_variations
DROP POLICY IF EXISTS "Exercise variations are publicly accessible" ON exercise_variations;
CREATE POLICY "catalog_read_only" ON exercise_variations FOR SELECT USING (true);

-- 4. exercises
DROP POLICY IF EXISTS "Exercises are publicly accessible" ON exercises;
CREATE POLICY "catalog_read_only" ON exercises FOR SELECT USING (true);

-- 5. program_days
DROP POLICY IF EXISTS "Program days are publicly accessible" ON program_days;
CREATE POLICY "catalog_read_only" ON program_days FOR SELECT USING (true);

-- 6. programs
DROP POLICY IF EXISTS "Programs are publicly accessible" ON programs;
CREATE POLICY "catalog_read_only" ON programs FOR SELECT USING (true);

-- ============================================================================
-- PARTE 3: TABELAS DE CATÁLOGO SEM POLÍTICAS (2 tabelas) - READ-ONLY
-- ============================================================================
-- workout_programs e workout_days são tabelas de catálogo (sem user_id).
-- Habilitar RLS + política de leitura pública.

-- 1. workout_programs
ALTER TABLE workout_programs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "catalog_read_only" ON workout_programs FOR SELECT USING (true);

-- 2. workout_days
ALTER TABLE workout_days ENABLE ROW LEVEL SECURITY;
CREATE POLICY "catalog_read_only" ON workout_days FOR SELECT USING (true);

-- ============================================================================
-- PARTE 4: TABELA DE SISTEMA (heartbeat) - SISTEMA APENAS
-- ============================================================================
-- heartbeat é uma tabela de monitoramento/sistema (não tem user_id).
-- Permitir apenas para usuários autenticados.

ALTER TABLE heartbeat ENABLE ROW LEVEL SECURITY;
CREATE POLICY "authenticated_users_only" ON heartbeat FOR ALL
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

-- ============================================================================
-- PARTE 5: TABELAS ÓRFÃS (8 tabelas) - OPÇÃO 1: HABILITAR RLS BLOQUEADOR
-- ============================================================================
-- Estas tabelas estão VAZIAS (0 linhas) e não pertencem ao app de treino:
-- goals, transactions, families, children, dream_boards, family_goals,
-- family_goal_contributions, goal_contributions
--
-- OPÇÃO 1: Habilitar RLS SEM políticas (bloqueia tudo, mas mantém estrutura)
-- OPÇÃO 2 (comentada): DROP das tabelas

-- Opção 1: Bloquear acesso (habilitar RLS sem políticas = ninguém acessa)
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE families ENABLE ROW LEVEL SECURITY;
ALTER TABLE children ENABLE ROW LEVEL SECURITY;
ALTER TABLE dream_boards ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_goal_contributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE goal_contributions ENABLE ROW LEVEL SECURITY;

-- Opção 2: Deletar tabelas órfãs (DESCOMENTE SE QUISER LIMPAR O SCHEMA)
-- DROP TABLE IF EXISTS goal_contributions CASCADE;
-- DROP TABLE IF EXISTS family_goal_contributions CASCADE;
-- DROP TABLE IF EXISTS dream_boards CASCADE;
-- DROP TABLE IF EXISTS family_goals CASCADE;
-- DROP TABLE IF EXISTS goals CASCADE;
-- DROP TABLE IF EXISTS children CASCADE;
-- DROP TABLE IF EXISTS families CASCADE;
-- DROP TABLE IF EXISTS transactions CASCADE;

-- ============================================================================
-- PARTE 6: TABELAS VAZIAS MAS LEGÍTIMAS (3 tabelas)
-- ============================================================================
-- workout_users, exercise_history, exercise_prs, last_set_cache, workout_sessions
-- estão vazias mas são legítimas do BWS. Já foram tratadas na PARTE 1.

-- ============================================================================
-- VERIFICAÇÃO FINAL
-- ============================================================================
-- Após executar este script:
-- 1. Vá em: Database > Security Advisor
-- 2. Clique em "Refresh" para atualizar os advisories
-- 3. Os 16 erros críticos devem ter sido reduzidos significativamente
-- 4. Verifique se o app funciona normalmente (login, carregar treinos, salvar séries)
--
-- Erros esperados restantes (warnings não-críticos):
-- - 9 funções sem search_path fixo (médio prazo)
-- - 2 views com SECURITY DEFINER (médio prazo)
-- - Proteção senha vazada desabilitada (configuração do Auth)
-- - Postgres com patches disponíveis (upgrade do Postgres)
-- ============================================================================
