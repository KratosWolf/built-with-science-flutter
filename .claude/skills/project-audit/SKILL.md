# Skill: Project Audit

## Descrição
Auditoria completa de um projeto existente. Gera um relatório padronizado com diagnóstico de tech stack, segurança, qualidade de código, estado do Git e recomendações priorizadas.

## Quando Usar
- Ao retomar um projeto antigo
- Antes de planejar melhorias ou refatorações
- Quando não se sabe o estado atual do projeto
- Como primeiro passo antes de rodar o App Planner

## Processo

### 1. Tech Stack
Identificar todas as tecnologias usadas:
```
- Framework principal e versão
- Linguagem e versão
- UI/Styling (Tailwind, Material, etc.)
- Autenticação (Supabase, Firebase, etc.)
- Database (tipo, ORM, status de conexão)
- Estado (Provider, Redux, Zustand, etc.)
- Testing (framework, cobertura)
- CI/CD (configurado? funcionando?)
```

### 2. Estrutura de Pastas
Mapear a árvore do projeto:
```
- Pastas principais e seus papéis
- Número total de arquivos
- Arquivos de configuração presentes
- Documentação existente (.md files)
```

### 3. O Que Funciona vs O Que Está Quebrado
Testar e listar:
```
✅ Funcionalidades operacionais
⚠️ Funcionalidades parciais ou com bugs
❌ Funcionalidades quebradas
🚫 Funcionalidades planejadas mas não implementadas
```

### 4. Estado do Git
Verificar completamente:
```bash
git status                    # Arquivos modificados/untracked
git log --oneline -5          # Últimos commits
git branch -a                 # Branches locais e remotas
git remote -v                 # Repositórios remotos
git stash list                # Stashes pendentes
```
Reportar:
- Branch atual
- Working tree clean ou dirty (quantos arquivos)
- Tempo desde último commit
- Branches que podem ser limpas
- Conflitos pendentes

### 5. Dependências
Verificar atualizações:
```bash
# Flutter
flutter pub outdated

# Node/Next.js
npm outdated
# ou
npx npm-check-updates

# Python
pip list --outdated
```
Classificar:
- 🔴 Major updates (breaking changes possíveis)
- 🟡 Minor updates (features novas)
- 🟢 Patch updates (bug fixes)
- ⚠️ Pacotes descontinuados

### 6. Segurança
Escanear por problemas:
```bash
# Secrets expostos no Git
git log --all --full-history -- "*.json" "*.env" "*.key" "*.pem"
grep -r "password\|secret\|api_key\|token" --include="*.json" --include="*.yaml" --include="*.yml"

# Verificar .gitignore
cat .gitignore | grep -E "\.env|secret|key|credential|google-services"

# Dependências com vulnerabilidades
# Node
npm audit
# Flutter - verificar advisories manualmente
```
Classificar:
- 🔴 CRÍTICO: Secrets no Git, credenciais expostas
- 🟡 MÉDIO: Configs inseguras, secrets fracos
- 🟢 BAIXO: Melhorias recomendadas

### 7. Qualidade do Código
Analisar:
```bash
# Arquivos grandes (>500 linhas)
find . -name "*.dart" -o -name "*.ts" -o -name "*.tsx" | xargs wc -l | sort -rn | head -20

# TODOs e FIXMEs
grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.dart" --include="*.ts" --include="*.tsx"

# Print/console statements em produção
grep -rn "print(\|console.log" --include="*.dart" --include="*.ts" --include="*.tsx"

# Lint
# Flutter
flutter analyze
# Node
npx eslint . --ext .ts,.tsx
```

## Formato do Relatório Final

```markdown
# 📊 RELATÓRIO DE AUDITORIA - [Nome do Projeto]
**Data:** [data]
**Localização:** [path]

## 1. Tech Stack
[tabela ou lista]

## 2. Estrutura de Pastas
[árvore simplificada]

## 3. Status de Funcionalidades
✅ Funcionando: [lista]
⚠️ Parcial: [lista]
❌ Quebrado: [lista]

## 4. Estado do Git
- Branch: [atual]
- Status: [clean/dirty]
- Último commit: [data e mensagem]
- Pendências: [lista]

## 5. Dependências
[tabela com status]

## 6. Segurança
🔴 Crítico: [lista]
🟡 Médio: [lista]
🟢 Baixo: [lista]

## 7. Qualidade do Código
- Arquivos grandes: [lista top 5]
- TODOs: [contagem]
- Lint issues: [contagem e principais]

## 8. Resumo Executivo
### Pontos Fortes
### Problemas Críticos
### Recomendações (priorizadas)

## 9. Checklist de Ação Imediata
[ ] Ação 1 — prioridade ALTA
[ ] Ação 2 — prioridade ALTA
[ ] ...
```

## Notas
- Este skill é o PRIMEIRO PASSO antes de melhorar qualquer projeto existente
- O relatório gerado deve ser levado ao App Planner para gerar CLAUDE.md e PROJECT_PLAN.md atualizados
- Não executar correções durante a auditoria — apenas diagnosticar e documentar
