# PROJECT_PLAN.md — Built With Science (Flutter Mobile)

> Este documento é a fonte única de verdade sobre o que será construído,
> em que ordem, e com que tecnologias. Deve ser mantido atualizado.
> ⚠️ PROJETO EXISTENTE EM MELHORIA — não é um projeto novo.

---

## 📌 VISÃO GERAL

### O que é este projeto?
App de workout tracking baseado nos programas do Built With Science (Jeremy Ethier). O usuário seleciona seu programa (3, 4 ou 5 dias), acompanha cada treino com registro de peso, repetições e dificuldade, navega por SuperSets, vê vídeos dos exercícios no YouTube, e acompanha sua consistência no dashboard. Os dados persistem localmente com backup via Supabase.

### Público-alvo
O próprio Tiago e potencialmente outros praticantes dos programas Built With Science.

### Resultado esperado
App funcional em Android e iOS, com visual dark premium, SuperSets corrigidos, e experiência de treino fluida sem interrupções desnecessárias.

---

## 🛠️ TECH STACK

### Stack Atual
| Camada | Tecnologia | Versão | Motivo |
|--------|-----------|--------|--------|
| Framework | Flutter | 3.24.5 | Cross-platform Android + iOS |
| Linguagem | Dart | 3.5.4 | Padrão Flutter |
| Backend/BaaS | Supabase | 2.10.0 | Auth + backup + sync |
| Banco Local | SQLite (sqflite) | 2.4.1 | Persistência principal offline-first |
| Banco Remoto | PostgreSQL via Supabase | — | Backup e sync |
| Autenticação | Supabase Auth + Google Sign-In | 2.10.3 / 6.2.2 | Google OAuth sem fricção |
| Estado | Provider | 6.1.1 | Simples para o escopo |
| Charts | FL Chart | 0.69.2 | Dashboard de consistência |
| Storage local | SharedPreferences | 2.5.3 | Configurações e estado |
| Deploy | Google Play Store | — | Android (iOS futuro) |
| Versionamento | GitHub | — | KratosWolf/built-with-science-flutter |

### Dependências Principais
```
supabase_flutter: 2.10.3
google_sign_in: 6.2.2
provider: 6.1.1
sqflite: 2.4.1
shared_preferences: 2.5.3
fl_chart: 0.69.2
http: 1.5.0
path_provider: 2.1.5
vibration: 1.9.0
wakelock_plus: 1.1.4
permission_handler: 11.4.0
```

---

## 📋 FASES DO PROJETO

---

### FASE 1 — Arrumar a Casa ⬅️ FASE ATUAL
**Objetivo:** Resolver problemas de segurança, limpar Git, atualizar dependências, garantir que o projeto está num estado saudável antes de qualquer mudança funcional.
**Prazo estimado:** 1-2 sessões de Claude Code

| # | Tarefa | Status | Notas |
|---|--------|--------|-------|
| 1.1 | Remover `google-services.json` do Git tracking | ⬜ Pendente | `git rm --cached android/app/google-services.json` + adicionar ao `.gitignore` |
| 1.2 | Adicionar padrões `.env*` ao `.gitignore` | ⬜ Pendente | Prevenir vazamento futuro |
| 1.3 | Commit de todas as alterações pendentes (14 arquivos) | ⬜ Pendente | Revisar cada alteração antes. Commit organizado por tipo. |
| 1.4 | Criar branch `develop` a partir da `main` limpa | ⬜ Pendente | Todo trabalho futuro será em develop ou feature branches |
| 1.5 | Atualizar dependências Flutter | ⬜ Pendente | `flutter pub upgrade --major-versions` — testar build depois |
| 1.6 | Remover `print()` statements de produção | ⬜ Pendente | Substituir por `debugPrint()` onde necessário |
| 1.7 | Remover arquivos backup (`.dart.backup`) | ⬜ Pendente | Limpar lixo do projeto |
| 1.8 | Organizar `releases/` — remover APKs antigos | ⬜ Pendente | Manter apenas o último ou adicionar ao `.gitignore` |
| 1.9 | Rodar `flutter analyze` — resolver warnings críticos | ⬜ Pendente | Foco em erros e warnings graves, não precisa resolver tudo |
| 1.10 | Build APK de verificação | ⬜ Pendente | `flutter build apk --release` — garantir que tudo compila |
| 1.11 | Push para remote (main limpa + develop criada) | ⬜ Pendente | Estado limpo no GitHub |

**Critério de conclusão:** Git limpo, sem credenciais expostas, dependências atualizadas, app compila e roda normalmente.

**⚠️ CUIDADOS:**
- Ao atualizar dependências major, podem haver breaking changes. Testar build após cada atualização.
- NÃO alterar funcionalidades nesta fase. Apenas limpeza e organização.
- Se google_sign_in atualizar de 6.x para 7.x, testar login antes de prosseguir.

---

### FASE 2 — Correções SuperSet
**Objetivo:** Corrigir 4 bugs/melhorias relacionados ao comportamento do SuperSet durante o treino.
**Status:** 🔒 Bloqueada — só inicia após Fase 1 completa e aprovada pelo Tiago.
**Prazo estimado:** 2-3 sessões de Claude Code

| # | Tarefa | Status | Notas |
|---|--------|--------|-------|
| 2.1 | Remover timer entre exercícios dentro do SuperSet | 🔒 | O timer NÃO deve aparecer entre A1→A2 nem entre A2→A1. Timer só aparece quando o SuperSet inteiro termina (A1→A2→A1→A2→A1→A2 → TIMER → próximo exercício). Ver detalhes abaixo. |
| 2.2 | Adicionar campo de comentário/notas no SuperSet | 🔒 | O exercício normal já tem campo de comentário. O SuperSet não tem. Adicionar campo de texto livre para o usuário anotar observações durante o treino. |
| 2.3 | Carregar dados do treino anterior no SuperSet | 🔒 | CRÍTICO: Quando o usuário abre um SuperSet, os campos de peso, repetições e dificuldade vêm em branco. Deveriam carregar automaticamente os valores do último treino (como já funciona nos exercícios solo). Também deve manter a variação de exercício selecionada no dropdown. |
| 2.4 | Adicionar alerta sonoro ao timer (funcionar com fone) | 🔒 | Atualmente o timer só vibra. Adicionar som audível que toque pelo fone Bluetooth/com fio. Usar package como `audioplayers` ou `just_audio`. O som deve tocar quando o timer zera. |
| 2.5 | Testes de regressão dos SuperSets | 🔒 | Testar fluxo completo: iniciar treino → SuperSet → registrar dados → verificar persistência → próximo treino deve mostrar dados anteriores |

**Critério de conclusão:** SuperSets funcionam corretamente — sem timer interno, com comentários, dados anteriores carregados, som no timer.

#### Detalhamento: Timer no SuperSet (2.1)

**Comportamento ERRADO atual:**
```
A1 Set 1 → [TIMER] → A2 Set 1 → [TIMER] → A1 Set 2 → [TIMER] → A2 Set 2 → ...
```

**Comportamento CORRETO desejado:**
```
A1 Set 1 → A2 Set 1 → A1 Set 2 → A2 Set 2 → A1 Set 3 → A2 Set 3 → [TIMER] → Próximo exercício
```

O conceito de SuperSet é alternar entre dois exercícios SEM descanso. O descanso só acontece quando TODAS as séries do SuperSet foram completadas e o usuário vai para o exercício seguinte.

#### Detalhamento: Dados anteriores no SuperSet (2.3)

Quando o usuário inicia um treino e chega num SuperSet, o app deve:
1. Buscar os dados do último treino para aquele exercício
2. Pré-preencher: peso, repetições, nível de dificuldade
3. Manter o exercício selecionado no dropdown de variações
4. O usuário pode alterar qualquer campo antes de confirmar

Isso já funciona nos exercícios normais (não-SuperSet). O código de carregamento provavelmente existe — precisa ser replicado/conectado ao widget de SuperSet.

---

### FASE 3 — Redesign Visual (Dark Mode)
**Objetivo:** Transformar o visual do app para tema dark premium com laranja como cor de destaque.
**Status:** 🔒 Bloqueada — só inicia após Fase 2 completa e aprovada.
**Prazo estimado:** 3-5 sessões de Claude Code

| # | Tarefa | Status | Notas |
|---|--------|--------|-------|
| 3.1 | Criar ThemeData dark centralizado | 🔒 | Definir todas as cores, tipografia, shapes num único lugar (`lib/config/theme.dart`) |
| 3.2 | Redesign da tela de login | 🔒 | Dark mode, botão Google laranja |
| 3.3 | Redesign do dashboard | 🔒 | Cards escuros, gráficos com laranja, texto branco |
| 3.4 | Redesign das telas de treino | 🔒 | Exercícios, SuperSets, inputs, botões — tudo dark |
| 3.5 | Redesign do timer | 🔒 | Visual dark com destaque laranja |
| 3.6 | Redesign de componentes reutilizáveis | 🔒 | Dropdowns, cards, modals, snackbars |
| 3.7 | Redesign da navegação e AppBar | 🔒 | Bottom nav ou drawer em dark |
| 3.8 | Revisão geral de consistência visual | 🔒 | Todas as telas coerentes, sem resquícios do tema claro |
| 3.9 | Ajuste de ícones e ilustrações | 🔒 | Trocar ícones coloridos para branco/laranja conforme contexto |

**Critério de conclusão:** App inteiro em dark mode, visual premium coerente, sem nenhuma tela no tema claro antigo.

#### Paleta de Cores Definida

```
BACKGROUND
  Principal:     #1A1A1A  (preto suave)
  Card/Elevado:  #2D2D2D  (cinza escuro)
  Input/Hover:   #3A3A3A  (cinza médio)

DESTAQUE
  Primário:      #FF6B00  (laranja vibrante — CTAs, botões, destaques)
  Active/Hover:  #FF8C00  (laranja claro)
  Sutil:         #FF6B00 com 20% opacidade (backgrounds de destaque)

TEXTO
  Principal:     #FFFFFF  (branco)
  Secundário:    #9CA3AF  (cinza claro)
  Disabled:      #6B7280  (cinza)

STATUS
  Sucesso:       #22C55E  (verde)
  Erro:          #EF4444  (vermelho)
  Alerta:        #F59E0B  (amarelo)
  Info:          #3B82F6  (azul)

SUPERSET
  Badge A1:      #FF6B00  (laranja)
  Badge A2:      #22C55E  (verde — para diferenciar do A1)

DIFICULDADE
  Perfeito:      #22C55E  (verde)
  Muito fácil:   #3B82F6  (azul)
  Muito difícil: #EF4444  (vermelho)
```

#### Referência Visual
Estilo: Dark mode premium, fitness-oriented. Referência: app Coach Sandow.AI.
- Fundo preto/cinza escuro
- Destaques em laranja vibrante
- Cards com cantos arredondados (12-16px)
- Tipografia clean (Roboto ou Inter)
- Sem sombras pesadas — usar diferença de tons para profundidade

---

### FASE 4 — iOS
**Objetivo:** Preparar e publicar o app para iOS (iPhone/iPad).
**Status:** 🔒 Bloqueada — só inicia após Fase 3 completa.
**Prazo estimado:** A definir

| # | Tarefa | Status | Notas |
|---|--------|--------|-------|
| 4.1 | Configurar ambiente Xcode completo | 🔒 | Instalação completa do Xcode + CocoaPods |
| 4.2 | Configurar Google Sign-In para iOS | 🔒 | iOS client ID, Info.plist, URL schemes |
| 4.3 | Configurar Supabase para iOS | 🔒 | Deep links, URL schemes |
| 4.4 | Ajustar UI para iOS guidelines | 🔒 | Cupertino adaptations, safe areas, notch |
| 4.5 | Testar em simulador iOS | 🔒 | Todas as funcionalidades |
| 4.6 | Testar em dispositivo real | 🔒 | TestFlight |
| 4.7 | Preparar para App Store | 🔒 | Screenshots, descrição, review guidelines |
| 4.8 | Submeter para Apple | 🔒 | — |

**Critério de conclusão:** App publicado na App Store e funcionando em iPhones.

---

## 🏗️ ARQUITETURA

### Estrutura de Pastas Atual
```
Flutter-Mobile-Version/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── screens/                     # 19 telas
│   │   ├── login_screen.dart
│   │   ├── dashboard_screen.dart     # 692 linhas ⚠️
│   │   ├── workout_screen.dart       # 728 linhas ⚠️
│   │   ├── workout_tracking_screen.dart  # 1,087 linhas 🔴
│   │   └── ... (outras telas)
│   ├── widgets/
│   │   ├── dashboard/               # Widgets do dashboard
│   │   ├── exercise_tracking_widget.dart  # 682 linhas ⚠️
│   │   ├── superset_tracking_widget.dart  # 1,122 linhas 🔴 ← FOCO DA FASE 2
│   │   └── rest_timer.dart           # 661 linhas ⚠️
│   ├── models/                      # Modelos de dados
│   ├── services/
│   │   ├── supabase_service.dart     # 915 linhas 🔴
│   │   ├── backup_service.dart
│   │   └── timer_service.dart
│   ├── data/                        # Mock data / CSVs integrados
│   └── utils/                       # Utilidades
├── android/
│   └── app/
│       └── google-services.json     # ⚠️ REMOVER DO GIT
├── data/                            # CSVs originais dos programas
└── releases/                        # APKs (17 releases)
```

### Arquivos Críticos para as Correções (Fase 2)
- `lib/widgets/superset_tracking_widget.dart` — Widget principal do SuperSet (1,122 linhas). Onde está a lógica de navegação A1↔A2, timer, e inputs.
- `lib/widgets/rest_timer.dart` — Timer de descanso (661 linhas). Onde adicionar o som.
- `lib/widgets/exercise_tracking_widget.dart` — Widget de exercício solo (682 linhas). Referência de como os dados anteriores são carregados (funciona aqui, não funciona no SuperSet).
- `lib/services/` — Serviços de persistência. Verificar se os dados do SuperSet estão sendo salvos/carregados corretamente.

### Fluxos Principais
```
1. Usuário abre o app → Verifica sessão Supabase → Login ou Dashboard
2. Dashboard → Seleciona programa (3/4/5 dias) → Seleciona treino do dia
3. Treino → Exercício normal ou SuperSet → Registra peso/reps/dificuldade
4. SuperSet: A1→A2→A1→A2→A1→A2 (sem pausa) → Timer → Próximo exercício
5. Exercício normal: Set 1 → Timer → Set 2 → Timer → Set 3 → Timer → Próximo
6. Fim do treino → Salva dados localmente + backup Supabase
7. Dashboard mostra consistência e histórico
```

---

## 📊 ESTADO ATUAL DO PROJETO (Auditoria 16/02/2026)

### ✅ Funcionando
- App totalmente funcional com programa 3-day
- Sistema de persistência local completo (v4.0+)
- SuperSet navigation funcionando (com bugs listados)
- Variações de exercícios (dropdowns)
- YouTube links funcionando
- Rest timer com vibração e wakelock
- Dashboard de consistência
- Autenticação com Supabase + Google OAuth
- Backup/restore local

### ⚠️ Problemas Conhecidos
- google-services.json exposto no Git (SEGURANÇA CRÍTICA)
- 14 arquivos modificados não commitados
- 3 meses sem commits
- Dependências desatualizadas (major versions)
- 50+ warnings no flutter analyze
- 20+ print() em produção
- Arquivos >800 linhas precisam refatoração futura
- Xcode não configurado (iOS bloqueado)

---

## 📝 HISTÓRICO DE MUDANÇAS

| Data | Fase | O que mudou | Motivo |
|------|------|-------------|--------|
| 2024 | Original | Projeto criado e desenvolvido | Tracker pessoal Built With Science |
| Nov/2025 | — | Último commit antes da pausa | — |
| 16/02/2026 | Planejamento | Auditoria completa + plano de melhoria | Retomar desenvolvimento ativo |
| 16/02/2026 | Planejamento | CLAUDE.md e PROJECT_PLAN.md criados | Preparar para Claude Code |
