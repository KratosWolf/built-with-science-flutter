# CLAUDE.md — Instruções para o Claude Code

> ⚠️ Este arquivo é lido automaticamente pelo Claude Code a cada interação.
> Todas as regras aqui DEVEM ser seguidas em TODAS as respostas.

---

## 🧠 IDENTIDADE DO PROJETO

- **Nome do Projeto:** Built With Science
- **Descrição:** App de workout tracking baseado nos programas do Built With Science (Jeremy Ethier). Permite acompanhar treinos com SuperSets, registrar peso/repetições/dificuldade, ver progressão e manter consistência.
- **Tipo:** mobile-app
- **Tech Stack Principal:** Flutter 3.24.5 + Dart 3.5.4 + Supabase + SQLite local
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

### FASE 3 — Redesign Visual (Dark Mode) ⬅️ FASE ATUAL (🔄 em andamento)
**Objetivo:** Converter app para tema dark premium (preto + laranja)
- ✅ 3.1-3.3: Theme centralizado, Login, Dashboard
- ✅ 3.4-3.5: Workout screens, Timer (PARCIAL - Home pendente)
- ✅ 3.6: Widgets convertidos para AppTheme
- ✅ 3.8: Programs screen
- ✅ 3.9: Ícones atualizados
- ❌ PENDENTE: simple_home.dart (visual antigo)
- ❌ PENDENTE: AppBar azul na tela "3-day Program"

### FASE 4 — iOS | 🔒 Bloqueada até Fase 3 completa

---

## 🗂️ ESTRUTURA DO PROJETO

```
Flutter-Mobile-Version/
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
2. **Plan Mode** (Shift+Tab 2x) → planejar antes de codar
3. Implementar a tarefa
4. Testar (`flutter analyze` + teste manual)
5. Commit → push para develop
6. Atualizar status no `PROJECT_PLAN.md`
7. Se contexto ficar grande → `/clear` e retomar
