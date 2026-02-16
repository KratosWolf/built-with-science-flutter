---
name: git-workflow
description: Regras e convenções de Git. Usar ao fazer commits, criar branches, fazer push, merge, ou qualquer operação Git. Também usar ao configurar Git em projeto novo.
allowed-tools: Bash, Read, Write
---

# Git Workflow — Regras e Convenções

## Estrutura de Branches
```
main        ← produção (só recebe merge da develop)
develop     ← desenvolvimento ativo (branch padrão de trabalho)
feature/*   ← funcionalidades novas (opcional, para features grandes)
```

## Regras de Commit

### Formato
```
tipo: descrição curta

Corpo opcional explicando o que e por quê.
```

### Tipos permitidos
- `feat:` — funcionalidade nova
- `fix:` — correção de bug
- `refactor:` — refatoração (sem mudar comportamento)
- `style:` — formatação, espaços, imports
- `docs:` — documentação
- `test:` — testes
- `chore:` — manutenção, configs, dependências

### Regras
- Mensagem em português ou inglês (manter consistência no projeto)
- Não commitar código que não compila
- Não commitar testes falhando
- 🔴 SEMPRE rodar secret scan antes (ver skill secret-scan)

## Quando Fazer Commit + Push
- A cada funcionalidade concluída e testada
- Ao final de cada sessão com Claude Code (NUNCA terminar com código não commitado)
- Antes de `/clear` no Claude Code

## Quando Fazer Merge develop → main
1. Fase inteira concluída e testada
2. Code review passado (ver skill code-review)
3. Secret scan completo ✅
4. Criar tag de versão: `git tag -a v1.0 -m "Fase 1 completa"`

## Setup Inicial de Git (para projeto novo)

```bash
# 1. Inicializar
git init

# 2. Verificar .gitignore
cat .gitignore | grep "env.local" && echo "✅ OK" || echo "🛑 ADICIONAR .env.local!"

# 3. Primeiro commit
git add .
# → Rodar secret scan aqui (ver skill secret-scan)
git commit -m "chore: setup inicial do projeto"

# 4. Criar repo PRIVADO no GitHub
gh repo create nome-do-projeto --private --source=. --remote=origin

# 5. Branches
git push -u origin main
git checkout -b develop
git push -u origin develop
```

## Instalação do Pre-commit Hook

```bash
mkdir -p .git/hooks
cat > .git/hooks/pre-commit << 'HOOK'
#!/bin/bash
echo "🔍 Verificando secrets nos arquivos staged..."

FOUND=$(git diff --cached --name-only | xargs grep -rn -i \
  -e "sk-ant-" \
  -e "AIza" \
  -e "supabase.*service.*role.*=.*[A-Za-z0-9]" \
  -e "SUPABASE_SERVICE_ROLE_KEY=.*[A-Za-z0-9]" \
  -e "secret.*key.*=.*[A-Za-z0-9]" \
  -e "password.*=.*[A-Za-z0-9]" \
  -e "BEGIN.*PRIVATE.*KEY" \
  -e "ghp_" -e "sk-proj-" \
  2>/dev/null)

if [ -n "$FOUND" ]; then
  echo ""
  echo "🛑 COMMIT BLOQUEADO — Possível secret detectado:"
  echo ""
  echo "$FOUND"
  echo ""
  echo "Remova o secret do código e use variáveis de ambiente (.env.local)."
  echo "Se for falso positivo, use: git commit --no-verify"
  exit 1
fi

echo "✅ Nenhum secret encontrado. Commit seguro."
HOOK
chmod +x .git/hooks/pre-commit
echo "✅ Pre-commit hook instalado!"
```

> ⚠️ Hook é LOCAL — precisa instalar em cada clone. Incluir este passo no setup de todo projeto novo.

## Regra de Ouro
> "Se o computador quebrasse agora, eu perderia código? Se sim → commit e push AGORA."
