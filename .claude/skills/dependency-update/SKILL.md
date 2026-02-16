# Skill: Dependency Update

## Descrição
Processo seguro e sistemático para atualizar dependências de um projeto. Cobre Flutter, Node.js e Python com estratégia de atualização por camadas, testes entre cada etapa e rollback plan.

## Quando Usar
- Depois de uma auditoria (project-audit) identificar dependências desatualizadas
- Antes de iniciar uma nova fase de desenvolvimento
- Quando um pacote tem vulnerabilidade de segurança
- Periodicamente (recomendado: a cada 2-4 semanas)

## Regras Importantes
1. **NUNCA atualizar tudo de uma vez** — atualizar em camadas
2. **SEMPRE criar branch dedicada** antes de começar
3. **SEMPRE testar entre cada camada** de atualização
4. **SEMPRE commitar entre camadas** para facilitar rollback
5. **Ler CHANGELOG de major updates** antes de aplicar

## Processo

### Passo 0: Preparação
```bash
# Garantir que o projeto compila ANTES de começar
# Flutter
flutter clean && flutter pub get && flutter build apk --debug

# Node
rm -rf node_modules && npm install && npm run build

# Criar branch
git checkout -b chore/dependency-update-YYYY-MM-DD
```

### Passo 1: Diagnóstico
```bash
# Flutter
flutter pub outdated

# Node
npm outdated
# ou para ver todas as possibilidades
npx npm-check-updates

# Python
pip list --outdated
```

Classificar cada dependência:
| Tipo | Risco | Estratégia |
|------|-------|------------|
| Patch (1.0.0 → 1.0.1) | 🟢 Baixo | Atualizar em lote |
| Minor (1.0.0 → 1.1.0) | 🟡 Médio | Atualizar em grupos pequenos |
| Major (1.0.0 → 2.0.0) | 🔴 Alto | Atualizar uma por vez, ler changelog |
| Descontinuado | ⚠️ Variável | Encontrar substituto |

### Passo 2: Camada 1 — Patches (Baixo Risco)
```bash
# Flutter — atualizar apenas patches
flutter pub upgrade

# Node — atualizar dentro do range do package.json
npm update

# Commitar
git add . && git commit -m "chore: update patch dependencies"
```
**Testar:** Build + funcionalidades principais

### Passo 3: Camada 2 — Minor Updates (Médio Risco)
```bash
# Flutter — atualizar minor versions
flutter pub upgrade --major-versions  # revisar o que mudou no pubspec.yaml
# OU atualizar pacotes específicos:
# flutter pub add pacote_nome:^nova_versao

# Node
npx npm-check-updates -u --target minor
npm install

# Commitar
git add . && git commit -m "chore: update minor dependencies"
```
**Testar:** Build + funcionalidades principais + lint

### Passo 4: Camada 3 — Major Updates (Alto Risco)
Para CADA major update, individualmente:

```bash
# 1. Ler o changelog/migration guide
# 2. Atualizar apenas este pacote
# Flutter
flutter pub add pacote_nome:^nova_versao

# Node
npm install pacote_nome@latest

# 3. Corrigir breaking changes
# 4. Testar
# 5. Commitar individualmente
git add . && git commit -m "chore: update pacote_nome to vX.0.0

BREAKING CHANGES:
- [listar mudanças que afetaram o código]"
```

### Passo 5: Pacotes Descontinuados
```
Para cada pacote descontinuado:
1. Identificar o substituto recomendado
2. Avaliar esforço de migração
3. Se simples: migrar agora
4. Se complexo: criar issue/task no PROJECT_PLAN.md para fazer depois
```

### Passo 6: Verificação Final
```bash
# Flutter
flutter clean
flutter pub get
flutter analyze
flutter build apk --release
flutter test  # se houver testes

# Node
rm -rf node_modules
npm install
npm run lint
npm run build
npm test  # se houver testes
```

### Passo 7: Merge
```bash
# Se tudo passou:
git checkout main
git merge chore/dependency-update-YYYY-MM-DD
git push

# Limpar
git branch -d chore/dependency-update-YYYY-MM-DD
```

## Rollback
Se algo quebrar durante o processo:

```bash
# Voltar ao commit anterior (dentro da branch)
git log --oneline  # encontrar o último commit bom
git reset --hard <commit-hash>

# Ou descartar a branch inteira
git checkout main
git branch -D chore/dependency-update-YYYY-MM-DD
```

## Checklist Rápido

```
[ ] Branch criada
[ ] Projeto compila ANTES de começar
[ ] Patches atualizados → testado → commitado
[ ] Minor updates aplicados → testado → commitado
[ ] Major updates (um por vez) → testado → commitado cada
[ ] Pacotes descontinuados tratados
[ ] flutter analyze / npm run lint limpo
[ ] Build release funciona
[ ] Testes passam
[ ] Merge feito
[ ] Branch limpa
```

## Notas
- Se uma major update quebra muita coisa, pode ser melhor deixar pra uma task dedicada
- Documentar no commit quais breaking changes afetaram o código
- Manter pubspec.yaml / package.json limpo (sem versões fixas desnecessárias)
