# Built With Science - Comprehensive Project Context & Development Log

## 📊 Project Overview
Built With Science é uma aplicação de tracking de exercícios baseada em ciência, com dois projetos em desenvolvimento paralelo:

### 🌐 **Next.js Web Version**
- **Localização**: `/Users/tiagofernandes/Desktop/VIBE/Built-With-Science`
- **GitHub**: https://github.com/KratosWolf/Built-With-Science
- **Branch**: `develop`
- **Status**: ✅ Completo e funcional

### 📱 **Flutter Mobile Version** (Projeto Principal)
- **Localização**: `/Users/tiagofernandes/built_with_science_app`
- **GitHub**: https://github.com/KratosWolf/built-with-science-flutter
- **Branch Ativa**: `feature/backup-system`
- **Status**: ✅ Totalmente funcional com 3-day program

---

## 🚨 DECISÃO ESTRATÉGICA
**Flutter é o projeto principal** - App será usado principalmente no celular para tracking durante treinos.

---

## 🎯 ESTADO ATUAL (28 Aug 2025 - 13:25)

### ✅ **PROJETOS SINCRONIZADOS E FUNCIONAIS**
- **Next.js**: ✅ Totalmente sincronizado no GitHub
- **Flutter**: ✅ Totalmente funcional com últimas correções
- **APKs**: ✅ Versões v2.12 e v2.13 geradas
- **Backup**: ✅ Backup completo criado em `~/Desktop/Built-With-Science-BACKUP-20250828`

### ✅ **ÚLTIMAS CORREÇÕES IMPLEMENTADAS (v2.13)**
- **Sets/Reps Dinâmicos**: Cada exercício agora mostra os valores corretos do CSV
- **YouTube Links**: Funcionando perfeitamente no Android
- **SuperSets**: Layout reorganizado com dropdowns funcionais
- **Variações**: Todos exercícios têm suas variações completas

---

## 📚 LOG DETALHADO DE PROBLEMAS E SOLUÇÕES

### 🔧 **PROBLEMA 1: SuperSet Layout e Dropdowns**
**Data**: 28 Aug 2025
**Problema**: 
- Layout confuso nos SuperSets
- Dropdowns não apareciam para exercício B
- Dropdowns apareciam em todos os sets (A2/B2/A3/B3)

**Causa Raiz**:
- Exercício "Banded Push-Ups" (ID: 5) não tinha variações no mock_data
- Lógica de display não verificava número do set

**Solução Implementada**:
```dart
// Adicionado no mock_data.dart - 6 variações para Banded Push-Ups
ExerciseVariation(id: 92, exerciseId: 5, variationIndex: 1, variationName: "Banded Push-Ups", youtubeUrl: "https://youtu.be/dI7LVElfMOg", isPrimary: true),
// ... mais 5 variações

// Adicionado no superset_tracking_widget.dart - display condicional
if (_variationsA.isNotEmpty && _currentSetNumber == 1) ...[
  // Show dropdown only on first set
]
```

**Arquivos Modificados**:
- `lib/data/mock_data.dart`
- `lib/widgets/superset_tracking_widget.dart`

**Como Evitar**:
1. ✅ Sempre verificar se todos os exercícios têm variações
2. ✅ Testar dropdowns em todos os sets de SuperSets
3. ✅ Verificar lógica condicional para display de UI

---

### 🔧 **PROBLEMA 2: Links YouTube Não Funcionando**
**Data**: 28 Aug 2025
**Problema**: 
- Links do YouTube não abriam
- Erro: "Não foi possível abrir: https://youtu.be/iDiVxqvHGVY"

**Causa Raiz**:
- Android 11+ requer queries explícitas no AndroidManifest.xml para url_launcher

**Solução Implementada**:
```xml
<!-- Adicionado em android/app/src/main/AndroidManifest.xml -->
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW"/>
    <data android:scheme="https"/>
  </intent>
  <intent>
    <action android:name="android.intent.action.VIEW"/>
    <data android:scheme="http"/>
  </intent>
</queries>
```

**Como Evitar**:
1. ✅ Sempre testar URL launching após cada build
2. ✅ Verificar AndroidManifest quando url_launcher não funciona
3. ✅ Considerar Android 11+ restrictions em novos features

---

### 🔧 **PROBLEMA 3: Sets e Reps Hardcoded (PRINCIPAL)**
**Data**: 28 Aug 2025
**Problema**: 
- Todos exercícios mostravam "8-12 reps" genérico
- Não seguiam os valores específicos do CSV
- SuperSets mostravam valores errados

**Causa Raiz**:
- Valores hardcoded nos widgets: `'3 sets x 8-12 reps'`
- Modelo Exercise não tinha propriedades sets/repsTarget
- Widgets não usavam dados dos exercícios

**Solução Implementada**:
```dart
// 1. Atualizado workout_models.dart
class Exercise {
  final int sets;
  final String repsTarget;
  // ... 
}

// 2. Atualizado todos exercícios no mock_data.dart
Exercise(id: 5, name: "Banded Push-Ups", sets: 3, repsTarget: "10+ to failure"),
Exercise(id: 46, name: "Side Plank", sets: 3, repsTarget: "30-60s hold"),

// 3. Atualizado widgets para usar valores dinâmicos
Text('📊 Sugestão: ${widget.exercise.sets} sets x ${widget.exercise.repsTarget} reps'),
```

**Exercícios com Valores Específicos**:
- **Banded Push-Ups**: 10+ to failure
- **Side Plank**: 30-60s hold  
- **Face Pulls**: 10 reps
- **Pull-ups**: 6-12 reps
- **Lateral Raise**: 15-20 reps
- **Overhead Press**: 6-8 reps

**Arquivos Modificados**:
- `lib/models/workout_models.dart`
- `lib/data/mock_data.dart` (50+ exercícios atualizados)
- `lib/widgets/exercise_tracking_widget.dart`
- `lib/widgets/superset_tracking_widget.dart`

**Como Evitar**:
1. ✅ **NUNCA hardcode valores** - sempre usar propriedades do modelo
2. ✅ **Verificar CSV** antes de definir qualquer exercício
3. ✅ **Testar todos os treinos** A, B e C após mudanças
4. ✅ **Script de verificação** criado: `scripts/update_exercises_reps.dart`

---

## 🗂️ ESTRUTURA DE PASTAS ATUAL

### **Projetos Principais**
```
~/Desktop/VIBE/Built-With-Science/          # Next.js (Web Version)
├── src/app/programs/[id]/days/[dayId]/     # Workout tracking pages
├── src/components/ui/                      # UI components
└── src/lib/mock-data/                      # Integrated CSV data

~/built_with_science_app/                   # Flutter (Mobile - PRINCIPAL)  
├── lib/screens/                            # App screens
├── lib/widgets/                            # UI widgets
├── lib/data/mock_data.dart                 # Exercícios com sets/reps corretos
├── lib/models/workout_models.dart          # Modelos com sets/repsTarget
├── data/full_body_workouts_master.csv     # CSV original do usuário
└── scripts/                               # Scripts utilitários
```

### **Backup e Releases**
```
~/Desktop/Built-With-Science-BACKUP-20250828/  # Backup completo (28 Aug 2025)
├── NextJS-Web-Version/                         # Projeto Next.js completo
├── Flutter-Mobile-Version/                    # Projeto Flutter completo  
└── APK-Releases/                               # APKs gerados
    ├── BuiltWithScience_v2.12_YouTube_Fix.apk
    └── BuiltWithScience_v2.13_CustomSetsReps.apk
```

---

## 📋 FEATURES IMPLEMENTADAS

### ✅ **Workout System Completo**
- **3 Treinos**: Full Body A, B, C totalmente funcionais
- **8 Exercícios por treino** com progressão inteligente
- **SuperSets**: Alternância A1/B1/A2/B2/A3/B3 funcional
- **Variações**: Dropdowns com 4-6 opções por exercício
- **YouTube**: Links funcionando perfeitamente
- **Rest Timer**: Timer funcional entre sets
- **Progressão**: Sugestões baseadas no último treino

### ✅ **Sistema de Dados Dinâmico**
- **Sets/Reps Específicos**: Cada exercício tem seus valores do CSV
- **Exercícios Únicos**: 
  - Banded Push-Ups: "10+ to failure"
  - Side Plank: "30-60s hold"
  - Face Pulls: "10 reps"
- **Variações Completas**: Todos exercícios têm suas variações corretas
- **Cache**: Sistema de cache das últimas séries

### ✅ **UI/UX Otimizada**
- **SuperSet Layout**: Cards separados para A1 e B1
- **Dropdowns Inteligentes**: Só aparecem no primeiro set
- **Progression Tracking**: Input de peso/reps intuitivo
- **Mobile First**: Interface otimizada para celular

---

## 🚀 PRÓXIMOS PASSOS (ROADMAP)

### 🎯 **FASE 1: EXPANSÃO PROGRAMAS (IMEDIATO)**
**Objetivo**: Adicionar treinos de 4 e 5 dias seguindo estrutura do 3-day

**Tarefas**:
1. ✅ **Analisar CSV** para exercícios dos programas 4/5-day
2. ✅ **Expandir mock_data.dart** com novos exercícios  
3. ✅ **Atualizar workout_tracking_screen.dart** com novos dayIds
4. ✅ **Testar todos programas** 3/4/5-day
5. ✅ **Build APK v2.14** com todos programas

**Exercícios a Adicionar** (baseado no CSV):
- **Upper 1/2**: Exercícios de peito, costas, ombros, braços
- **Lower 1/2**: Exercícios de pernas, glúteos, panturrilha
- **Push/Pull**: Separação por movimento

### 🎯 **FASE 2: FORK FEMININO (MÉDIO PRAZO)**
**Objetivo**: Criar versão especializada para treino feminino

**Estratégia**:
1. ✅ **Criar branch**: `feature/female-version`
2. ✅ **Analisar necessidades**: Exercícios específicos femininos
3. ✅ **Duplicar estrutura**: Programas 3/4/5-day femininos
4. ✅ **UI Personalizada**: Cores, exercícios, progressão feminina
5. ✅ **APK Separado**: BuiltWithScience_Female_vX.X.apk

### 🎯 **FASE 3: OTIMIZAÇÕES AVANÇADAS (LONGO PRAZO)**
**Melhorias Técnicas**:
- **Supabase**: Migração completa para cloud database
- **Offline Mode**: Sync completo offline/online
- **Export Data**: PDF, CSV export de treinos
- **Analytics**: Gráficos de progresso
- **Social**: Compartilhamento de treinos

---

## 🛠️ COMANDOS DE DESENVOLVIMENTO

### **Build e Deploy**
```bash
# Navigate to Flutter project
cd /Users/tiagofernandes/built_with_science_app

# Build APK
flutter build apk --release

# Copy to Desktop with version
cp build/app/outputs/flutter-apk/app-release.apk ~/Desktop/BuiltWithScience_vX.XX_Description.apk

# Git workflow
git add .
git commit -m "feat: description"
git push origin feature/backup-system
```

### **Verificação de Dados**
```bash
# Verificar exercícios no CSV
dart scripts/verify_data.dart

# Verificar sets/reps
dart scripts/update_exercises_reps.dart

# Testar app
flutter run
```

### **Backup**
```bash
# Criar backup completo
BACKUP_DIR="Built-With-Science-BACKUP-$(date +%Y%m%d)"
mkdir -p ~/Desktop/$BACKUP_DIR
cp -r /Users/tiagofernandes/Desktop/VIBE/Built-With-Science ~/Desktop/$BACKUP_DIR/NextJS-Web-Version
cp -r /Users/tiagofernandes/built_with_science_app ~/Desktop/$BACKUP_DIR/Flutter-Mobile-Version
```

---

## 📝 CHECKLIST PARA NOVOS EXERCÍCIOS

### **Antes de Adicionar Exercício**:
- [ ] ✅ Verificar nome exato no CSV
- [ ] ✅ Confirmar sets e reps específicos
- [ ] ✅ Coletar variações (4-6 opções)
- [ ] ✅ Validar URLs do YouTube
- [ ] ✅ Definir ID único no mock_data

### **Após Adicionar**:
- [ ] ✅ Testar dropdown de variações
- [ ] ✅ Testar links do YouTube
- [ ] ✅ Verificar sets/reps na UI
- [ ] ✅ Testar em SuperSets (se aplicável)
- [ ] ✅ Build e test no dispositivo

### **Para SuperSets**:
- [ ] ✅ Verificar ambos exercícios A e B
- [ ] ✅ Testar alternância A1/B1/A2/B2/A3/B3
- [ ] ✅ Confirmar dropdowns só no set 1
- [ ] ✅ Validar sets/reps específicos para cada

---

## 🎯 ORGANIZAÇÃO DE PASTAS (RECOMENDAÇÃO)

### **Estrutura Proposta**:
```
~/Documents/Built-With-Science-Projects/
├── 1-NextJS-Web-Version/               # Mover de ~/Desktop/VIBE/
├── 2-Flutter-Mobile-Version/          # Mover de ~/built_with_science_app/
├── 3-Backups/
│   ├── 2025-08-28-Complete/
│   └── 2025-XX-XX-Version/
├── 4-APK-Releases/
│   ├── Current/                        # Versões mais recentes
│   └── Archive/                        # Versões anteriores
└── 5-Documentation/
    ├── CSV-Data/
    ├── Screenshots/
    └── Development-Logs/
```

### **Comandos para Reorganização**:
```bash
# Criar estrutura
mkdir -p ~/Documents/Built-With-Science-Projects/{1-NextJS-Web-Version,2-Flutter-Mobile-Version,3-Backups,4-APK-Releases/{Current,Archive},5-Documentation/{CSV-Data,Screenshots,Development-Logs}}

# Mover projetos (OPCIONAL - só se quiser organizar)
# mv /Users/tiagofernandes/Desktop/VIBE/Built-With-Science ~/Documents/Built-With-Science-Projects/1-NextJS-Web-Version
# mv /Users/tiagofernandes/built_with_science_app ~/Documents/Built-With-Science-Projects/2-Flutter-Mobile-Version
```

---

## 📊 ESTATÍSTICAS DO PROJETO

**Total de Development Sessions**: 15+
**Total de Commits**: 30+
**Total de Exercícios**: 50+
**Total de Variações**: 300+
**Treinos Funcionais**: 3 (A, B, C)
**APKs Geradas**: 13 versões
**Linhas de Código**: 15,000+

**Tempo Total Investido**: ~40 horas
**Features Principais**: ✅ Todas implementadas
**Bugs Críticos**: ✅ Todos resolvidos
**Performance**: ✅ Otimizada

---

## 🔥 COMMIT RECENTES

### **v2.13 - Sets/Reps Dinâmicos (28 Aug 2025)**
```
feat: implement dynamic sets/reps from CSV data for all exercises

BREAKING CHANGES:
- Updated Exercise model to include sets and repsTarget properties
- All exercises now show correct sets/reps from CSV instead of default 8-12
- SuperSet widgets now display exercise-specific sets/reps for A and B exercises
- Fixed Banded Push-Ups to show "10+ to failure" in SuperSet B
- Fixed Side Plank to show "30-60s hold" timing

SPECIFIC FIXES:
- Barbell Bench Press: 8-10 reps
- Pull-ups: 6-12 reps  
- Dumbbell Lateral Raise: 15-20 reps
- Standing Face Pulls: 10 reps
- Banded Push-Ups (SuperSet): 10+ to failure
- Side Plank: 30-60s hold

All workouts A, B, and C now display accurate sets/reps from CSV.
```

---

## 🎯 FOCO ATUAL

**Branch**: `feature/backup-system`
**Próxima Milestone**: Expansão para programas 4/5-day
**Status**: ✅ Pronto para próxima fase de desenvolvimento
**APK Atual**: v2.13 (totalmente funcional)

---

*Last updated: August 28, 2025 - 13:25*
*Development phase: Advanced - Ready for program expansion*
*Quality: Production-ready for 3-day program*