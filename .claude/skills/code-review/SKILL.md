---
name: code-review
description: Padrões de código e checklist de code review. Usar ao revisar código, antes de merge, ao finalizar uma fase, ou quando o usuário pedir review/revisão de qualidade.
allowed-tools: Read, Grep, Glob, Bash
---

# Code Review — Padrões e Checklist

## Quando Usar
- Antes de merge develop → main
- Ao finalizar uma fase do PROJECT_PLAN.md
- Quando o Tiago pedir "review" ou "revisão"
- Antes de deploy para produção

## Checklist Rápido (usar em toda revisão)

### 1. Segurança
- [ ] Nenhum secret/API key no código (rodar skill secret-scan)
- [ ] `.env.local` no `.gitignore`
- [ ] RLS (Row Level Security) ativado em todas as tabelas do Supabase
- [ ] Inputs do usuário sanitizados
- [ ] Auth verificado em rotas protegidas

### 2. Qualidade de Código
- [ ] Sem código comentado ou morto (remover)
- [ ] Sem `print()` / `console.log()` de debug (remover)
- [ ] Sem valores hardcoded que deveriam ser constantes/config
- [ ] Nomes de variáveis e funções descritivos
- [ ] Funções com responsabilidade única (não >50 linhas)
- [ ] Imports organizados e sem imports não usados

### 3. Arquitetura
- [ ] Lógica de negócio nos Services, não nas telas/widgets
- [ ] Models separados dos services
- [ ] Sem lógica duplicada (DRY)
- [ ] Tratamento de erro em chamadas de API/banco
- [ ] Loading states implementados
- [ ] Estados vazios tratados (lista vazia, sem dados)

### 4. Banco de Dados
- [ ] `migrations.sql` atualizado com todas as alterações
- [ ] Índices nas colunas usadas em WHERE/JOIN frequentes
- [ ] RLS policies testadas (testou como usuário comum, não como admin?)
- [ ] Sem queries N+1 (listar + detalhe em loop)
- [ ] Soft delete quando apropriado (campo `deleted_at`)

### 5. UX/UI
- [ ] Feedback visual em ações (loading, sucesso, erro)
- [ ] Botões desabilitados durante requisição (evitar clique duplo)
- [ ] Textos sem erros de português/inglês
- [ ] Funcionando em telas pequenas (responsive)
- [ ] Navegação faz sentido (back button funciona)

### 6. Git
- [ ] Branch correta (develop, não main)
- [ ] Commits com mensagens descritivas
- [ ] Nenhum commit de merge desnecessário
- [ ] Histórico limpo e compreensível

## Formato de Report

Ao fazer code review, gerar relatório neste formato:

```
## Code Review — [Nome da Fase/Feature]
Data: [data]
Branch: [branch]

### ✅ Aprovado
- [item que está OK]

### ⚠️ Atenção (corrigir antes do merge)
- [arquivo:linha] — [descrição do problema]

### 💡 Sugestões (melhorias opcionais)
- [sugestão de melhoria]

### Veredicto: ✅ APROVADO / ⚠️ CORRIGIR ANTES DO MERGE / 🛑 REPROVAR
```

## Comando Rápido para Listar Problemas Comuns

```bash
# TODOs e FIXMEs esquecidos
grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.dart" --include="*.ts" --include="*.tsx" .

# Console.logs / prints de debug
grep -rn "console\.log\|print(" --include="*.dart" --include="*.ts" --include="*.tsx" --exclude-dir=node_modules .

# Arquivos grandes (>300 linhas — candidatos a refatorar)
find . -name "*.dart" -o -name "*.ts" -o -name "*.tsx" | xargs wc -l | sort -rn | head -20
```
