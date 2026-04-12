# Decisões Técnicas — Built With Science

## Design
- Dark mode only — preferência do Tiago, referência Coach Sandow
- Paleta: #1A1A1A (background) + #FF6B00 (laranja primário)
- Cards: #2D2D2D | Elevated: #3A3A3A | Texto: #FFFFFF / #9CA3AF

## SuperSet
- Sem timer entre exercícios — timer só após completar TODAS as séries
- Séries 2 e 3 pré-preenchidas via cache (fix commit fd78388)

## Banco de Dados
- Coluna status='done' em workout_sessions — obrigatória para dashboard
- Campos corretos: workout_date, workout_type, duration_minutes, status
- NÃO usar: day_id, duration_seconds, completed_at (não existem no schema)
- IDs protegidos: exercícios < 52, variações < 103 (NUNCA alterar)

## Supabase
- Heartbeat via pg_cron a cada 5 dias (nunca pausa no free tier)
- RLS habilitado em todas as tabelas de dados do usuário

## Audio
- Canal `alarm` bypassa modo silencioso — correto para timer
- Canal `notification` NÃO bypassa modo silencioso
