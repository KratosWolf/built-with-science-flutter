---
name: session-workflow
description: Workflow de sessão no Claude Code. Usar ao iniciar nova sessão, ao trocar de tarefa, quando o contexto ficar grande, ou quando precisar planejar antes de codar. Inclui Plan Mode, /clear, subagents, Hooks, e princípios de atomicidade.
---

# Session Workflow — Gerenciamento de Sessão no Claude Code

## Ao Iniciar uma Sessão

1. **Ler o `PROJECT_PLAN.md`** — identificar próxima tarefa / fase pendente
2. **Verificar branch** — `git branch` (deve estar em `develop` ou `feature/*`)
3. **Verificar status** — `git status` (não deve ter changes não commitados da sessão anterior)
4. **Identificar a tarefa** — uma funcionalidade por vez, não múltiplas
5. **Avaliar tamanho da tarefa** — cabe em ~50% do contexto? Se não, quebrar.

## Plan Mode (Shift+Tab 2x)

Ativar Plan Mode ANTES de codar quando:
- Tarefa envolve múltiplos arquivos
- Arquitetura nova (nova tela, novo service, novo model)
- Integração com API externa
- Refatoração significativa

No Plan Mode, o Claude Code analisa e planeja sem modificar arquivos.
Só implementar após o plano estar aprovado pelo Tiago.

## Fluxo de Trabalho por Tarefa

```
┌─────────────────────────────────────┐
│  1. PLANEJAR (Plan Mode)            │
│     → Que arquivos criar/editar?    │
│     → Que dependências?             │
│     → Que impacto no banco?         │
│     → Cabe em ~50% do contexto?     │
├─────────────────────────────────────┤
│  2. IMPLEMENTAR                     │
│     → Criar/editar arquivos         │
│     → Seguir padrões das Skills     │
├─────────────────────────────────────┤
│  3. TESTAR                          │
│     → Compilar                      │
│     → Testar funcionalidade         │
│     → Testar edge cases             │
├─────────────────────────────────────┤
│  4. COMMITAR                        │
│     → Secret scan (skill)           │
│     → git add + commit + push       │
├─────────────────────────────────────┤
│  5. ATUALIZAR                       │
│     → Marcar tarefa como ✅          │
│       no PROJECT_PLAN.md            │
│     → Atualizar CLAUDE.md se banco  │
│       ou decisões técnicas mudaram  │
└─────────────────────────────────────┘
```

---

## 🆕 Princípio de Atomicidade (GSD)

> "Uma task que não cabe no contexto não é uma task — é um projeto."

### Regras de Tamanho

Cada task no PROJECT_PLAN.md deve ser **atômica**: pequena o suficiente para ser planejada, implementada, testada, e commitada dentro de uma única sessão do Claude Code, usando no máximo ~50% do contexto.

**Sinais de que uma task é grande demais:**
- Envolve mais de 5-7 arquivos
- Precisa de mais de 3 subtarefas para explicar
- O Plan Mode gera um plano com mais de 15 passos
- Você precisa de mais de 10 trocas de mensagem para completar

**O que fazer quando a task é grande demais:**
1. Quebrar em subtasks numeradas (ex: 2.3a, 2.3b, 2.3c)
2. Cada subtask deve ter seus próprios critérios de "done"
3. Cada subtask deve poder ser commitada independentemente
4. Usar `/clear` entre subtasks

### Exemplo de Quebra

```
❌ RUIM — Task grande demais:
2.3 Implementar sistema de juros com cálculo, tela, e notificações

✅ BOM — Tasks atômicas:
2.3a Criar InterestService com cálculo de juros mensais
     Done: service criado, teste unitário passando
2.3b Criar tela de configuração de juros
     Done: tela renderiza, salva config no banco
2.3c Integrar cálculo com dashboard e notificação
     Done: dashboard mostra juros acumulados, notificação dispara
```

### Regra de Ouro da Atomicidade
> Se ao começar uma task você pensa "isso vai ser longo", PARE e quebre antes de codar.

---

## 🆕 Hooks do Claude Code

Hooks são comandos shell que o Claude Code executa automaticamente em momentos específicos. Substituem a necessidade de "lembrar" de fazer coisas repetitivas.

### Configuração

Hooks ficam em `.claude/settings.json` (por projeto) ou `~/.claude/settings.json` (global).

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(git commit)",
        "hook": "echo '🔍 Lembrete: secret scan deve ter sido executado antes do commit'"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hook": "FILE=\"$TOOL_INPUT_path\"; EXT=\"${FILE##*.}\"; case \"$EXT\" in ts|tsx|js|jsx) npx prettier --write \"$FILE\" 2>/dev/null ;; dart) dart format \"$FILE\" 2>/dev/null ;; esac; echo '✅ Auto-formatado'"
      }
    ],
    "SessionStart": [
      {
        "hook": "echo \"📋 Projeto: $(basename $(pwd))\"; echo \"🌿 Branch: $(git branch --show-current 2>/dev/null)\"; echo \"📊 Status: $(git status --short 2>/dev/null | wc -l) arquivos modificados\"; if [ -f PROJECT_PLAN.md ]; then echo '📄 PROJECT_PLAN.md encontrado — ler para identificar próxima task'; fi"
      }
    ],
    "PreCompact": [
      {
        "hook": "echo '⚠️ COMPACTAÇÃO IMINENTE — Verificar:'; echo '1. Todo código commitado?'; echo '2. PROJECT_PLAN.md atualizado?'; echo '3. Decisões técnicas registradas no CLAUDE.md?'"
      }
    ]
  }
}
```

### Hooks Recomendados

| Hook | Evento | O que faz |
|------|--------|-----------|
| Auto-format | PostToolUse (Write/Edit) | Formata arquivo após edição (prettier/dart format) |
| Lembrete de secret scan | PreToolUse (git commit) | Avisa antes de commitar |
| Contexto de sessão | SessionStart | Mostra projeto, branch, arquivos pendentes |
| Alerta de compactação | PreCompact | Lembra de salvar progresso antes de perder contexto |

### Instalação

**Por projeto (recomendado para começar):**
Criar `.claude/settings.json` na raiz do projeto com o JSON acima.

**Global (todos os projetos):**
Adicionar em `~/.claude/settings.json`.

### Hooks que NÃO recomendo automatizar

- **Secret scan completo** como bloqueio de commit → já temos pre-commit hook no Git (ver skill git-workflow)
- **Aprovação automática de comandos** → perigoso, melhor manter supervisão
- **Atualizar PROJECT_PLAN.md automaticamente** → decisão humana, não do hook

---

## Quando Usar `/clear`

O contexto do Claude Code se degrada com conversas longas. Usar `/clear`:

- **Entre tarefas diferentes** (terminou feature A → /clear → começa feature B)
- **Quando o contexto passar de 50%** (aparece indicador no terminal)
- **Após fase de planejamento** (Plan Mode → aprovar plano → /clear → implementar)
- **Quando o Claude começar a alucinar** ou repetir erros
- **Entre subtasks** de uma task grande que foi quebrada

### Antes de `/clear`, SEMPRE:
1. Commitar todo código pendente
2. Anotar onde parou (atualizar PROJECT_PLAN.md)
3. Se houver plano em andamento, salvar em arquivo (plan.md)

### Após `/clear`:
1. O Claude relê o CLAUDE.md automaticamente
2. Dizer: "Continuar do PROJECT_PLAN.md — próxima tarefa é [X]"

---

## 🆕 Health Check de Contexto

### Indicadores de Contexto Degradado
Ficar atento a estes sinais durante a sessão:

- **Claude repete código** que já foi escrito → contexto cheio, /clear
- **Claude "esquece" decisões** tomadas 5 mensagens atrás → contexto cheio, /clear
- **Claude sugere abordagem** que já foi rejeitada → contexto cheio, /clear
- **Respostas ficam mais lentas** e genéricas → contexto cheio, /clear
- **Indicador de contexto >50%** no terminal → considerar /clear

### Protocolo de Preservação (antes de /clear ou compactação)

1. **Commitar** todo código pendente
2. **Verificar** PROJECT_PLAN.md — tasks concluídas marcadas como ✅?
3. **Registrar** decisões técnicas no CLAUDE.md (seção Decisões Técnicas)
4. **Anotar** a próxima task a ser iniciada
5. **Push** para o repositório remoto

### Monitoramento Proativo
O Claude Code deve avisar UMA VEZ quando detectar sessão longa:

```
⚠️ ALERTA DE CONTEXTO: Sessão com muitas trocas. Recomendo:
1. Commitar e push do trabalho atual
2. Atualizar PROJECT_PLAN.md e CLAUDE.md
3. /clear e retomar com contexto fresco
```

---

## Subagents (Pesquisa em Contexto Separado)

Usar subagents para pesquisa que consumiria muito contexto:

```
Use subagents para investigar como o sistema de auth está configurado
e quais utilitários de Supabase já existem no projeto.
```

O subagent explora o codebase em contexto separado e retorna um resumo, sem poluir o contexto principal.

**Quando usar subagents:**
- Explorar codebase grande pela primeira vez
- Investigar como um módulo funciona
- Buscar padrões existentes antes de implementar algo novo
- Comparar implementações em diferentes partes do projeto

**Quando NÃO usar subagents:**
- Task simples que envolve 1-2 arquivos
- Código que você já sabe onde está
- Coisas que cabem numa busca rápida (grep)

## Gerenciamento de Contexto

### Dicas para manter o contexto limpo
- **Uma tarefa por sessão** — escopo focado
- **Não ler arquivos desnecessários** — o Claude Code lê sob demanda
- **Referenciar ao invés de colar** — "veja o arquivo X" em vez de colar o conteúdo
- **Usar /clear entre fases** — planejamento, implementação, review
- **Commitar antes de /clear** — senão perde o contexto do que foi feito
- **Quebrar tasks grandes** — aplicar princípio de atomicidade

### Níveis de raciocínio
- Tarefas simples (rename, ajuste de texto) → prompt normal
- Tarefas médias (nova tela, novo endpoint) → Plan Mode
- Tarefas complexas (arquitetura, refatoração) → "ultrathink" / "think step by step"

## Ao Finalizar uma Sessão

1. ✅ Todo código commitado e pushado
2. ✅ PROJECT_PLAN.md atualizado com progresso
3. ✅ CLAUDE.md atualizado (se houve decisão técnica ou mudança no banco)
4. ✅ Nenhum TODO/FIXME esquecido
5. ✅ Branch correta (develop)
6. ✅ Resumo do que foi feito (para retomar depois)
7. ✅ Lembrar de atualizar Knowledge Base no Projeto Dedicado (se mudou CLAUDE.md ou PROJECT_PLAN.md)
