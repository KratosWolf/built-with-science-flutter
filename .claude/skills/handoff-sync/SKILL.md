---
name: handoff-sync
description: Padroniza HANDOFFs entre Projeto Dedicado e Claude Code, e o sync de arquivos na Knowledge Base. Usar ao gerar comandos para Claude Code, ao retornar de uma sessão no Claude Code, ou ao sincronizar CLAUDE.md / PROJECT_PLAN.md com o Projeto Dedicado.
allowed-tools: Read, Write, Bash
---

# HANDOFF & Sync — Comunicação entre Projeto Dedicado e Claude Code

## Arquitetura do Fluxo

```
┌──────────────────┐     HANDOFF      ┌──────────────────┐
│ Projeto Dedicado │ ───────────────→  │   Claude Code    │
│  (Claude Chat)   │                   │    (Terminal)     │
│                  │  ←───────────────  │                  │
│  Planeja e       │   REPORT-BACK     │  Coda, testa,    │
│  acompanha       │                   │  commita         │
└──────────────────┘                   └──────────────────┘
         ↕
  Knowledge Base
  (CLAUDE.md + PROJECT_PLAN.md)
```

## Parte 1 — HANDOFF (Projeto Dedicado → Claude Code)

### Formato Padrão

Todo HANDOFF gerado pelo Projeto Dedicado deve seguir este formato:

```markdown
📋 HANDOFF — [Nome da Task]

## Contexto
- Projeto: [nome]
- Fase: [X] — [nome da fase]
- Task: [X.Y] — [nome da task]
- Branch: develop (ou feature/nome-da-feature)

## O que fazer
[Descrição clara e direta do que implementar]

## Arquivos esperados
- Criar: [lista de arquivos novos, se houver]
- Editar: [lista de arquivos a modificar, se souber]
- Banco: [migrations necessárias, se houver]

## Critérios de Done
- [ ] [critério 1]
- [ ] [critério 2]
- [ ] [critério 3]
- [ ] Projeto compila sem erros
- [ ] Commit feito com mensagem descritiva

## Após concluir
- Atualizar PROJECT_PLAN.md: marcar task [X.Y] como ✅
- Atualizar CLAUDE.md: [se houver mudança no banco ou decisão técnica]
- Report-back: colar resumo do que foi feito no Projeto Dedicado
```

### Regras do HANDOFF

1. **Uma task por HANDOFF** — nunca misturar múltiplas tasks
2. **Critérios de done obrigatórios** — o Claude Code precisa saber quando parar
3. **Contexto suficiente** — o Claude Code lê o CLAUDE.md, mas o HANDOFF deve ser autocontido
4. **Sem ambiguidade** — "implementar a tela" não serve; "criar tela de configuração de juros com campos X, Y, Z" serve
5. **Tamanho atômico** — se o HANDOFF tem mais de 15 itens de "o que fazer", a task é grande demais (ver skill session-workflow → Atomicidade)

### HANDOFFs Especiais

**HANDOFF de Correção (bug fix):**
```markdown
📋 HANDOFF — Fix: [descrição do bug]

## Problema
[O que está acontecendo]

## Comportamento esperado
[O que deveria acontecer]

## Onde investigar
- [arquivo/componente suspeito]
- [tabela/coluna relacionada]

## Critérios de Done
- [ ] Bug corrigido
- [ ] Funcionalidade original preservada
- [ ] Sem regressão em features relacionadas
- [ ] Commit: fix: [descrição]
```

**HANDOFF de Atualização de Docs (sync):**
```markdown
📋 HANDOFF — Sync: Atualizar CLAUDE.md e PROJECT_PLAN.md

## Atualizações no PROJECT_PLAN.md
- Task [X.Y]: marcar como ✅
- Task [X.Z]: marcar como 🔄 Em progresso
- [outras mudanças]

## Atualizações no CLAUDE.md
### Estado do Banco (se mudou):
[tabela atualizada com novo estado]

### Decisões Técnicas (se houve):
| Data | Decisão | Motivo |
|------|---------|--------|
| [data] | [decisão] | [motivo] |

## Critérios de Done
- [ ] PROJECT_PLAN.md atualizado
- [ ] CLAUDE.md atualizado
- [ ] Commit: docs: atualiza estado do projeto
```

---

## Parte 2 — REPORT-BACK (Claude Code → Projeto Dedicado)

Após completar um HANDOFF no Claude Code, o Tiago deve reportar de volta ao Projeto Dedicado. O report não precisa ser detalhado — o Projeto Dedicado vai fazer as perguntas certas.

### Formato Mínimo

```
Voltei do Claude Code. Task [X.Y] concluída.
- [resumo de 1-2 frases do que foi feito]
- [qualquer decisão técnica tomada durante implementação]
- [qualquer problema encontrado ou desvio do plano]
```

### O que o Projeto Dedicado deve fazer ao receber o report:

1. **Verificar critérios de done** — todos atendidos?
2. **Atualizar status** — marcar task como ✅ no contexto da conversa
3. **Identificar próxima task** — gerar próximo HANDOFF
4. **Verificar se Knowledge Base precisa de sync** — trigger da Parte 3

---

## Parte 3 — SYNC de Knowledge Base

### Quando sincronizar

A Knowledge Base do Projeto Dedicado (CLAUDE.md + PROJECT_PLAN.md) deve ser atualizada quando:

| Trigger | Ação |
|---------|------|
| Task concluída muda status no PROJECT_PLAN.md | Sync PROJECT_PLAN.md |
| Mudança no banco de dados (nova tabela, migration) | Sync CLAUDE.md + PROJECT_PLAN.md |
| Decisão técnica importante tomada | Sync CLAUDE.md |
| Fase inteira concluída | Sync ambos (obrigatório) |
| Mais de 3 tasks concluídas sem sync | Sync ambos (acumulou) |

### Como sincronizar

**Opção A — HANDOFF de Sync (recomendado):**
O Projeto Dedicado gera um HANDOFF de atualização de docs (ver formato acima). O Claude Code executa e commita.
Depois, o Tiago baixa/copia os arquivos atualizados e substitui na Knowledge Base.

**Opção B — Manual (rápido para mudanças pequenas):**
1. O Projeto Dedicado gera o conteúdo atualizado no chat
2. O Tiago copia e substitui o arquivo na Knowledge Base diretamente
3. Sem passar pelo Claude Code

### Checklist de Sync

```
[ ] PROJECT_PLAN.md — tasks com status atualizado (✅, 🔄, ⬜)
[ ] CLAUDE.md — Estado do Banco atualizado (se mudou)
[ ] CLAUDE.md — Decisões Técnicas registradas (se houve)
[ ] CLAUDE.md — Reconciliação UI × Código × Banco atualizada (se houve mudança)
[ ] Arquivos copiados para Knowledge Base do Projeto Dedicado
[ ] Testado: abrir novo chat no Projeto Dedicado e verificar que reflete o estado atual
```

### Armadilhas Comuns

**❌ Knowledge Base desatualizada:**
O Projeto Dedicado acha que está na task 2.3, mas o Claude Code já completou até 2.6.
Resultado: HANDOFFs repetidos ou conflitantes.
Prevenção: sync após cada fase ou a cada 3 tasks.

**❌ CLAUDE.md com banco desatualizado:**
O Claude Code criou uma nova tabela, mas o CLAUDE.md ainda não reflete.
Resultado: próxima sessão do Claude Code pode criar tabela duplicada ou referenciar schema errado.
Prevenção: sempre atualizar Estado do Banco no mesmo commit da migration.

**❌ Decisão técnica perdida:**
Uma decisão foi tomada durante uma sessão longa do Claude Code, mas nunca registrada.
Resultado: próxima sessão pode tomar decisão diferente ou refazer trabalho.
Prevenção: registrar decisões no CLAUDE.md antes de /clear.

---

## Checklist Rápido — Fluxo Completo

```
ANTES (no Projeto Dedicado):
[ ] Próxima task identificada
[ ] HANDOFF gerado no formato padrão
[ ] Critérios de done definidos
[ ] HANDOFF é atômico (cabe em ~50% do contexto)

DURANTE (no Claude Code):
[ ] HANDOFF colado como comando inicial
[ ] Task implementada
[ ] Critérios de done verificados
[ ] Commit + push feito
[ ] PROJECT_PLAN.md e CLAUDE.md atualizados no repo

DEPOIS (de volta ao Projeto Dedicado):
[ ] Report-back com resumo do que foi feito
[ ] Verificação de done criteria
[ ] Knowledge Base sincronizada (se necessário)
[ ] Próximo HANDOFF gerado (se continuar)
```

## Notas
- O HANDOFF é a "interface" entre planejamento e execução
- Um bom HANDOFF elimina perguntas — o Claude Code sabe exatamente o que fazer
- Sync regular evita drift entre o que o Projeto Dedicado sabe e o que o código reflete
- Na dúvida, sincronize — é melhor sync demais do que sync de menos
