# Skill: Code Cleanup

## Descrição
Limpeza sistemática de código: remover debug statements, resolver TODOs, quebrar arquivos grandes, eliminar código morto e arquivos desnecessários. Melhora a manutenibilidade sem mudar funcionalidades.

## Quando Usar
- Depois de uma auditoria (project-audit) identificar problemas de qualidade
- Antes de iniciar uma nova fase de desenvolvimento
- Quando o código acumulou débito técnico
- Depois de um período longo sem manutenção

## Regras Importantes
1. **Cleanup NÃO muda funcionalidade** — é puramente cosmético/organizacional
2. **SEMPRE criar branch dedicada** antes de começar
3. **Testar depois de cada categoria** de limpeza
4. **Commitar por categoria** (não misturar tipos de limpeza no mesmo commit)

## Processo

### Passo 0: Preparação
```bash
# Garantir que compila antes
# Flutter
flutter build apk --debug

# Node
npm run build

# Criar branch
git checkout -b chore/code-cleanup-YYYY-MM-DD
```

### Passo 1: Debug Statements (Prioridade ALTA)
Remover todos os print/console.log de código de produção:

```bash
# Encontrar
# Flutter
grep -rn "print(" lib/ --include="*.dart"
grep -rn "debugPrint(" lib/ --include="*.dart"

# Node/React
grep -rn "console.log\|console.warn\|console.error" src/ --include="*.ts" --include="*.tsx"
```

**Estratégia:**
- Remover prints que são claramente debug (ex: `print("aqui")`, `print(variable)`)
- Substituir prints úteis por logging adequado se necessário
- Manter `console.error` em catch blocks se for relevante

```bash
git add . && git commit -m "chore: remove debug print statements"
```

### Passo 2: Arquivos de Backup e Temporários (Prioridade ALTA)
```bash
# Encontrar
find . -name "*.backup" -o -name "*.bak" -o -name "*.old" -o -name "*.tmp" -o -name "*copy*"
find . -name "*.dart.backup" -o -name "*.tsx.backup"
ls releases/  # APKs antigos que não precisam estar no repo

# Remover
rm -f [arquivos identificados]

# Adicionar ao .gitignore
echo "*.backup" >> .gitignore
echo "*.bak" >> .gitignore
echo "*.old" >> .gitignore
echo "releases/*.apk" >> .gitignore  # se APKs não devem ser versionados
```

```bash
git add . && git commit -m "chore: remove backup and temporary files"
```

### Passo 3: TODOs e FIXMEs (Prioridade MÉDIA)
```bash
# Listar todos
grep -rn "TODO\|FIXME\|HACK\|XXX\|TEMP" lib/ src/ --include="*.dart" --include="*.ts" --include="*.tsx"
```

Para cada TODO/FIXME, decidir:
| Ação | Quando |
|------|--------|
| ✅ Resolver agora | Se é simples (< 5 min) |
| 📋 Mover para PROJECT_PLAN.md | Se é uma feature/melhoria real |
| 🗑️ Remover | Se é obsoleto ou já foi feito |
| 🔄 Manter | Se é um lembrete válido e ativo |

```bash
git add . && git commit -m "chore: resolve and organize TODO comments"
```

### Passo 4: Arquivos Grandes — Refatoração (Prioridade MÉDIA)
```bash
# Identificar arquivos grandes
find . -name "*.dart" -o -name "*.ts" -o -name "*.tsx" | xargs wc -l | sort -rn | head -15
```

**Limites recomendados:**
- 🟢 < 300 linhas: OK
- 🟡 300-500 linhas: Monitorar
- 🔴 > 500 linhas: Candidato a refatoração

**Estratégias de quebra:**
1. **Extrair widgets/componentes** — UI grande → widgets menores
2. **Extrair funções utilitárias** — lógica repetida → utils/helpers
3. **Separar lógica de negócio** — tela com lógica → service/controller
4. **Dividir por responsabilidade** — arquivo que faz 3 coisas → 3 arquivos

**Exemplo Flutter:**
```
# Antes:
# workout_tracking_screen.dart (1,087 linhas)

# Depois:
# workout_tracking_screen.dart (300 linhas) — UI principal
# widgets/workout_set_row.dart (150 linhas) — widget de cada set
# widgets/workout_exercise_card.dart (200 linhas) — card do exercício
# controllers/workout_tracking_controller.dart (250 linhas) — lógica
```

```bash
# Commitar CADA arquivo refatorado separadamente
git add . && git commit -m "refactor: split workout_tracking_screen into smaller components"
```

### Passo 5: Código Morto (Prioridade BAIXA)
```bash
# Encontrar imports não usados
# Flutter
flutter analyze 2>&1 | grep "unused_import"

# Encontrar variáveis/funções não usadas
flutter analyze 2>&1 | grep "unused"

# Encontrar arquivos não referenciados (manual)
# Verificar se algum arquivo em lib/ não é importado em lugar nenhum
```

```bash
git add . && git commit -m "chore: remove dead code and unused imports"
```

### Passo 6: Lint e Formatação (Prioridade BAIXA)
```bash
# Flutter
flutter analyze
dart fix --apply  # corrige automaticamente o que pode
dart format lib/  # formata código

# Node
npx eslint . --ext .ts,.tsx --fix
npx prettier --write "src/**/*.{ts,tsx}"
```

```bash
git add . && git commit -m "style: fix lint warnings and format code"
```

### Passo 7: Verificação Final
```bash
# Garantir que nada quebrou
# Flutter
flutter clean && flutter pub get
flutter analyze
flutter build apk --release
flutter test

# Node
rm -rf node_modules && npm install
npm run lint
npm run build
npm test
```

### Passo 8: Merge
```bash
git checkout main
git merge chore/code-cleanup-YYYY-MM-DD
git push
git branch -d chore/code-cleanup-YYYY-MM-DD
```

## Checklist Rápido

```
[ ] Branch criada
[ ] Projeto compila ANTES de começar
[ ] Debug statements removidos → testado → commitado
[ ] Arquivos backup/temp removidos → commitado
[ ] TODOs resolvidos/organizados → commitado
[ ] Arquivos grandes refatorados → testado → commitado (cada um)
[ ] Código morto removido → commitado
[ ] Lint/format aplicado → commitado
[ ] Build release funciona
[ ] Testes passam
[ ] Merge feito
[ ] Branch limpa
```

## Ordem de Commits Esperada
```
chore: remove debug print statements
chore: remove backup and temporary files
chore: resolve and organize TODO comments
refactor: split [arquivo] into smaller components (x N)
chore: remove dead code and unused imports
style: fix lint warnings and format code
```

## Notas
- Cada commit deve compilar — não quebrar o build em commits intermediários
- Se a refatoração de um arquivo grande é complexa, pode virar task no PROJECT_PLAN.md
- Cleanup é o momento ideal para melhorar nomes de variáveis/funções confusos
- NÃO adicionar features durante cleanup — manter foco na limpeza
