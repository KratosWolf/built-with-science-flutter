# Setup Supabase - Built with Science

## 1. Configurar Secrets no GitHub

1. Vá para: https://github.com/KratosWolf/built-with-science-flutter
2. Settings → Secrets and variables → Actions
3. Adicionar secrets:
   - **SUPABASE_URL**: [sua URL do projeto]
   - **SUPABASE_SERVICE_KEY**: [service role key do projeto]

## 2. Executar Schema no Supabase

1. Acesse seu projeto Supabase
2. SQL Editor (ícone lateral)
3. New Query
4. Cole o conteúdo de `schema_v2.sql`
5. Run

## 3. Testar GitHub Action

1. GitHub → Actions tab
2. "Keep Supabase Alive"
3. Run workflow → Run workflow
4. Verificar se executou com sucesso

## 4. Atualizar App

No arquivo `lib/services/supabase_service.dart`:
```dart
static const String _supabaseUrl = 'SUA_URL_AQUI';
static const String _supabaseAnonKey = 'SUA_ANON_KEY_AQUI';
```

## Proteção Implementada

- ✅ GitHub Action roda 2x por semana (quarta e domingo)
- ✅ Mantém projeto sempre ativo
- ✅ Zero custo (plano Free do GitHub Actions)
- ✅ Backup automático possível
- ✅ Tabela heartbeat para monitorar atividade

## Funcionamento do Keep-Alive

O GitHub Action executa:
1. Ping na função `keep_alive()` do Supabase
2. Query na tabela `heartbeat`
3. Teste de conexão com o banco
4. Log de sucesso com timestamp

**Frequência**: 2x por semana (suficiente para evitar inatividade)
**Duração**: ~30 segundos por execução
**Custo**: $0 (dentro do free tier do GitHub Actions)

## Troubleshooting

### Se o Action falhar:
1. Verificar se os secrets estão configurados corretamente
2. Verificar se o schema foi executado no Supabase
3. Verificar se a tabela `heartbeat` existe
4. Verificar logs no GitHub Actions

### Se o projeto ainda expirar:
- Aumentar frequência do cron (ex: diariamente)
- Adicionar mais queries no Action
- Verificar configurações do projeto no Supabase

## Próximos Passos

Após configurar tudo:
1. Testar execução manual do Action
2. Aguardar primeira execução automática
3. Verificar logs no Supabase
4. Implementar sync do app com o banco
