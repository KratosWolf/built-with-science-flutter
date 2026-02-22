# CLAUDE.md — Instruções para o Claude Code

> ⚠️ Este arquivo é lido automaticamente pelo Claude Code a cada interação.
> Todas as regras aqui DEVEM ser seguidas em TODAS as respostas.

---

## 🧠 IDENTIDADE DO PROJETO

- **Nome do Projeto:** Built With Science
- **Descrição:** App de workout tracking baseado nos programas do Built With Science (Jeremy Ethier). Permite acompanhar treinos com SuperSets, registrar peso/repetições/dificuldade, ver progressão e manter consistência.
- **Tipo:** mobile-app
- **Tech Stack Principal:** Flutter 3.41.1 + Dart 3.11.0 + Supabase + SQLite local
- **Repositório:** https://github.com/KratosWolf/built-with-science-flutter
- **Dono do Projeto:** Tiago (empreendedor, perfil estratégico, não-técnico)

---

## 🚨 REGRAS FUNDAMENTAIS (NUNCA VIOLAR)

### Regra 1: Faseamento Obrigatório
- O projeto é dividido em FASES com escopo definido no PROJECT_PLAN.md.
- **NUNCA** avance para a próxima fase sem aprovação explícita do Tiago.
- **NUNCA** implemente funcionalidades que não pertencem à fase atual.
- Se algo da fase atual depende de uma fase futura, AVISE e PERGUNTE antes.
- Ao concluir cada item da fase, marque como ✅ no PROJECT_PLAN.md.

### Regra 2: Checkpoints Obrigatórios
Antes de avançar para o próximo item, SEMPRE verifique:
- [ ] O app compila sem erros? (`flutter analyze` limpo)
- [ ] A funcionalidade implementada funciona como esperado?
- [ ] O código foi testado (pelo menos teste manual)?
- [ ] Foi feito commit com mensagem descritiva?
- [ ] O PROJECT_PLAN.md foi atualizado?

Só prossiga quando TODOS os itens estiverem ✅.

### Regra 3: Comunicação Clara
- Explique decisões técnicas em linguagem simples e direta.
- Antes de executar qualquer comando destrutivo (deletar, resetar, alterar estrutura), PERGUNTE.
- Quando houver mais de uma abordagem, apresente opções com prós e contras ANTES de implementar.
- Use analogias do dia a dia quando explicar conceitos técnicos.
- No início de cada interação, diga: "Estamos na Fase X, trabalhando em [item]."

### Regra 4: Qualidade de Código
- Código limpo, organizado e com comentários explicativos nos trechos importantes.
- Siga os padrões Dart/Flutter (lowerCamelCase para variáveis, UpperCamelCase para classes).
- Remova código comentado que não esteja em uso — nada de "lixo".
- Remova `print()` statements de debug — usar `debugPrint()` ou logger adequado.
- Trate erros adequadamente — nunca ignore exceções silenciosamente.
- Separe responsabilidades: um arquivo não deve fazer "tudo".
- Arquivos com mais de 500 linhas devem ser avaliados para refatoração.

### Regra 5: Git e Versionamento
- Commits frequentes com mensagens descritivas em português.
- Padrão: `tipo: descrição curta`
  - `feat:` nova funcionalidade | `fix:` correção | `docs:` documentação
  - `refactor:` refatoração | `style:` formatação | `test:` testes | `chore:` manutenção
  - `security:` correção de segurança
  - Exemplo: `fix: remove timer entre exercícios do SuperSet`
- Branches: `main` (produção) → `develop` (desenvolvimento) → `feature/nome`
- NUNCA faça push direto na `main` após a Fase 1.

### Regra 6: Atomicidade de Tasks
- Cada task deve caber em uma sessão do Claude Code (~50% do contexto).
- Se uma task envolve mais de 5-7 arquivos ou precisa de mais de 10 trocas de mensagem, é grande demais.
- Tasks grandes devem ser quebradas em subtasks (ex: 2.3a, 2.3b, 2.3c) ANTES de começar a codar.
- Cada subtask deve ter seus próprios critérios de done e poder ser commitada independentemente.
- Na dúvida: se ao começar você pensa "isso vai ser longo", PARE e quebre.

---

## 📋 FASES DO PROJETO (resumo)

> Detalhamento completo em PROJECT_PLAN.md
> ⚠️ ESTE É UM PROJETO EXISTENTE EM MELHORIA, NÃO UM PROJETO NOVO.

### FASE 1 — Arrumar a Casa ✅ CONCLUÍDA (16/02/2026)
**Objetivo:** Resolver segurança, limpar Git, atualizar dependências.
- ✅ Git limpo, sem credenciais expostas
- ✅ Flutter 3.41.1, dependências atualizadas
- ✅ Build funcional (55.5MB)

### FASE 2 — Correções SuperSet ✅ CONCLUÍDA (16/02/2026)
**Objetivo:** Corrigir bugs do SuperSet (timer, comentários, dados anteriores, som)
- ✅ Timer só no final do SuperSet
- ✅ Campo de comentários adicionado
- ✅ Dados anteriores carregados automaticamente
- ✅ Som + vibração no timer

### FASE 3 — Redesign Visual (Dark Mode) ✅ CONCLUÍDA (22/02/2026)
**Objetivo:** Converter app para tema dark premium (preto + laranja)
- ✅ 3.1-3.3: Theme centralizado, Login, Dashboard
- ✅ 3.4-3.5: Workout screens, Timer
- ✅ 3.6: Widgets convertidos para AppTheme
- ✅ 3.8: Programs screen
- ✅ 3.9: Ícones atualizados
- ✅ 3.10: simple_home.dart (já estava convertido)
- ✅ 3.11-3.12: Bugs corrigidos (UI update, som no mudo)
- ✅ 3.13: AppBar azul corrigido
- ✅ 3.14a-d: Onboarding, Backup, Program Selection, Statistics
- ✅ APK v6.0 gerado (53MB)

### FASE 4 — Backup Automático ⬅️ FASE ATUAL
**Objetivo:** Backup automático na nuvem + restore ao reinstalar
- [ ] 4.1 Auto-backup ao concluir treino
- [ ] 4.2 Auto-restore ao instalar/reinstalar
- [ ] 4.3 Indicador de sync

### FASE 5 — iOS | 🔒 Bloqueada — decidido focar em Android por agora

---

## 🗂️ ESTRUTURA DO PROJETO

```
Flutter-Mobile-Version/
├── .claude/
│   ├── settings.json      ← Configurações do Claude Code (hooks, etc.)
│   └── skills/            ← Skills customizadas (14 configuradas)
├── CLAUDE.md              ← Este arquivo (lido automaticamente)
├── PROJECT_PLAN.md        ← Plano detalhado com fases
├── README.md              ← Documentação pública
├── .gitignore
├── pubspec.yaml           ← Dependências Flutter
├── lib/
│   ├── main.dart          ← Entry point
│   ├── screens/           ← 19 telas principais
│   ├── widgets/           ← Widgets reutilizáveis
│   │   └── dashboard/     ← Dashboard widgets
│   ├── models/            ← Modelos de dados
│   ├── services/          ← Serviços (Supabase, backup, timer)
│   ├── data/              ← Mock data / CSVs integrados
│   └── utils/             ← Utilidades
├── android/
│   └── app/
│       └── google-services.json  ← ⚠️ REMOVER DO GIT (Fase 1.1)
├── data/                  ← CSVs originais dos programas
└── releases/              ← APKs gerados (não versionados)
```

---

## 🔧 PADRÕES TÉCNICOS

### Banco de Dados
- **Supabase (remoto):** Autenticação + backup de dados. RLS habilitado.
- **SQLite local (sqflite):** Persistência principal dos treinos no dispositivo.
- **SharedPreferences:** Configurações do usuário, estado do app.
- Toda alteração no schema deve ser documentada no PROJECT_PLAN.md.

### Autenticação
- **Supabase Auth** com Google OAuth (google_sign_in 6.2.2).
- Verificar sessão no startup. Tokens em variáveis de ambiente.
- google-services.json NÃO pode estar no Git.

### Segurança
- Validar TODOS os inputs do usuário.
- Credenciais e secrets APENAS em variáveis de ambiente (NUNCA commitar).
- `google-services.json` e `.env*` devem estar no `.gitignore`.
- Rodar `flutter analyze` antes de cada commit.

---

## 📝 DECISÕES TÉCNICAS REGISTRADAS

| Data | Decisão | Motivo |
|------|---------|--------|
| 2024 | Provider para estado | Simplicidade para o escopo do app |
| 2024 | SQLite + SharedPreferences | Persistência local robusta, offline-first |
| 2024 | Supabase (não Firebase) | Auth + DB integrado, PostgreSQL, free tier |
| 16/02/2026 | Dark mode only (sem light) | Preferência do Tiago, referência visual premium |
| 16/02/2026 | Paleta: preto + laranja | Referência: app Coach Sandow, estilo fitness premium |
| 16/02/2026 | SuperSet sem timer interno | Conceito correto: sem descanso entre A1↔A2, só após completar rodada |
| 16/02/2026 | Reset para commit 9039540 | Tentativas de fix na Home (commits fc49d22, e1d0f60) quebraram o app — revertido para versão estável dark mode |
| 16/02/2026 | simple_home.dart pendente | Redesign da Home precisa ser feito com cuidado — testar antes de commit |
| 18/02/2026 | Bug SuperSet: missing setState() | UI não atualizava após save — dados estavam corretos no cache mas widget não reconstruía |
| 18/02/2026 | Som no mudo: canal alarm | AndroidSounds.alarm toca mesmo no silencioso (igual despertador) |
| 18/02/2026 | simple_home.dart já convertido | Análise revelou que conversão dark mode já tinha sido feita — task 3.10 não era necessária |
| 22/02/2026 | Variações 4-day/5-day completas | 267 variações (IDs 103-369) adicionadas ao mock_data.dart, SUPERSETs resolvidos |
| 22/02/2026 | Fase 3 dark mode completa | Todas as telas convertidas — APK v6.0 |
| 22/02/2026 | iOS adiado — foco Android | Quando mudar para iPhone, configurar Xcode + TestFlight (1-2 sessões) |
| 22/02/2026 | Programas femininos BWS | Esposa usa iOS — programas femininos 3/4/5 dias a adicionar futuramente |
| 22/02/2026 | Backup automático como Fase 4 | Dados ficam só no SQLite local — risco de perda. Auto-backup resolve antes de migrar para iOS |

---

## 🎨 DESIGN SYSTEM (a partir da Fase 3)

> Referência visual: estilo dark premium fitness (Coach Sandow)

```
Cores:
- Background principal: #1A1A1A
- Background card: #2D2D2D
- Background elevado: #3A3A3A
- Destaque primário (CTA, botões): #FF6B00 (laranja)
- Destaque hover/active: #FF8C00
- Texto principal: #FFFFFF
- Texto secundário: #9CA3AF
- Sucesso: #22C55E
- Erro: #EF4444
- Warning: #F59E0B

Tipografia:
- Manter fonte padrão do Flutter (Roboto) ou avaliar Inter/Poppins
- Títulos: bold, texto corpo: regular

Componentes:
- Cards com fundo #2D2D2D, border-radius 12-16px, sombra sutil
- Botões primários: fundo laranja #FF6B00, texto branco, border-radius 12px
- Inputs: fundo #3A3A3A, borda sutil, texto branco
- Ícones: brancos ou laranja conforme contexto
```

---

## 📦 Skills Disponíveis
As skills em `.claude/skills/` são carregadas automaticamente quando relevantes.
Para ver todas: listar a pasta `.claude/skills/`.

### Skills Configuradas neste Projeto
| Skill | Função | Quando usar |
|-------|--------|-------------|
| **session-workflow** | Workflow de sessão no Claude Code | Ao iniciar nova sessão, trocar de tarefa, quando contexto ficar grande, ou planejar antes de codar |
| **code-cleanup** | Limpeza sistemática de código | Depois de auditoria, antes de nova fase, quando acumulou débito técnico |
| **code-review** | Padrões de código e checklist de code review | Antes de merge, ao finalizar fase, quando pedir review de qualidade |
| **git-workflow** | Regras e convenções de Git | Ao fazer commits, criar branches, push, merge, ou configurar Git em projeto novo |
| **database-migration** | Processo seguro para alterações de schema no banco | Ao renomear colunas, adicionar/remover campos, alterar tabelas, migrar dados |
| **secret-scan** | Verificação de secrets e credenciais no código | SEMPRE antes de git add/commit, ao criar/editar configs ou arquivos com API keys |
| **project-audit** | Auditoria completa de projeto existente | Ao retomar projeto antigo, antes de planejar melhorias, quando não sabe estado atual |
| **dependency-update** | Processo seguro para atualizar dependências | Depois de auditoria, antes de nova fase, quando há vulnerabilidade, periodicamente |
| **supabase-setup** | Convenções de Supabase, criação de tabelas, RLS | Ao criar tabelas, alterar schema, configurar auth, escrever policies RLS |
| **troubleshooting** | Diagnóstico e resolução de problemas comuns | Quando build quebrar, funcionalidade parar, dados sumirem, ou erro inesperado |
| **project-setup** | Setup inicial de projeto novo | Ao criar projeto do zero (não aplicável a este projeto existente) |
| **pre-launch** | Checklist pré-lançamento | Antes de deploy para produção (Fase 4+) |
| **mcp-setup** | Configuração de MCP servers | Ao adicionar novos MCP servers ao Claude Code |
| **handoff-sync** | Sincronização de conhecimento entre sessões | Ao transferir contexto, atualizar Knowledge Base, ou documentar decisões |

---

## 🪝 Hooks Configurados
> Hooks em `.claude/settings.json` — executam automaticamente.
> Se não há hooks configurados, manter esta seção vazia como referência.

| Evento | O que faz |
|--------|-----------|
| (nenhum configurado ainda) | — |

---

## 🆘 QUANDO ALGO DER ERRADO

1. **NÃO** tente resolver silenciosamente refazendo tudo.
2. **PARE** e explique o problema em linguagem simples.
3. **MOSTRE** o erro exato e o que significa.
4. **PROPONHA** 1-2 soluções com prós e contras.
5. **AGUARDE** aprovação antes de implementar.

---

## Comandos Úteis
- `flutter run` — rodar em dev (dispositivo/emulador conectado)
- `flutter analyze` — verificar erros e warnings
- `flutter build apk --release` — build de produção Android
- `flutter build ios --release` — build de produção iOS (futuro)
- `flutter pub upgrade --major-versions` — atualizar dependências
- `flutter test` — rodar testes (quando houver)

## Workflow por Sessão
1. Ler `PROJECT_PLAN.md` → identificar próxima tarefa
2. **Avaliar tamanho:** cabe em ~50% do contexto? Se não, quebrar (Regra 6)
3. **Plan Mode** (Shift+Tab 2x) → planejar antes de codar
4. Implementar a tarefa
5. Testar (`flutter analyze` + teste manual)
6. Commit → push para develop
7. Atualizar status no `PROJECT_PLAN.md`
8. Se contexto ficar grande → `/clear` e retomar
