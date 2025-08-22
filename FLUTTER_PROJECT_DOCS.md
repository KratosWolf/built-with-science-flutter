# Built With Science - Flutter Mobile App

## 📱 Projeto Principal para Mobile Tracking

Este é o projeto **principal** do Built With Science, focado na experiência mobile nativa para tracking de exercícios durante treinos.

---

## 🎯 OBJETIVO
Aplicação mobile para tracking pessoal de workouts baseados em ciência, com:
- Interface otimizada para uso durante exercícios
- Funcionalidade offline-first
- Sincronização com Supabase
- Performance nativa no celular

---

## 🛠️ TECH STACK

### Core
- **Flutter 3.5.4** + Dart
- **Supabase** para backend e sincronização
- **SQLite** para cache local
- **Material Design 3** para UI

### Dependências Principais
```yaml
dependencies:
  flutter: sdk: flutter
  supabase_flutter: ^2.9.1    # Backend e Auth
  sqflite: ^2.4.1             # SQLite local
  path_provider: ^2.1.5       # Paths do sistema
  shared_preferences: ^2.5.3  # Configurações locais
  cupertino_icons: ^1.0.8     # Ícones iOS
```

---

## 📁 ESTRUTURA DO PROJETO

```
lib/
├── main.dart                    # App principal com Supabase config
├── models/
│   └── workout_models.dart      # Modelos completos de dados
├── data/
│   └── mock_data.dart          # Mock data baseado nos CSVs
├── screens/
│   ├── home_screen.dart        # Tela inicial
│   ├── programs_screen.dart    # Lista de programas
│   └── program_detail_screen.dart  # Detalhes do programa
└── services/ (a criar)
    ├── supabase_service.dart   # API calls
    ├── local_storage.dart      # SQLite operations
    └── sync_service.dart       # Sincronização
```

---

## 📊 MODELOS DE DADOS IMPLEMENTADOS

### Core Models
- ✅ `Program` - Programas de treino (3/4/5 days)
- ✅ `ProgramDay` - Dias específicos dos programas
- ✅ `Exercise` - Exercícios individuais
- ✅ `DayExercise` - Exercícios em dias específicos
- ✅ `DayExerciseSet` - Sets/reps targets
- ✅ `ExerciseVariation` - Variações com YouTube URLs

### Tracking Models
- ✅ `WorkoutUser` - Usuário e preferências
- ✅ `WorkoutSession` - Sessões de treino
- ✅ `WorkoutSet` - Sets realizados pelo usuário
- ✅ `LastSetCache` - Cache das últimas séries
- ✅ `ProgressionSuggestion` - Sugestões de progressão

---

## 🎨 TELAS IMPLEMENTADAS

### ✅ HomeScreen
- Dashboard principal
- Acesso rápido aos programas
- Últimos treinos

### ✅ ProgramsScreen  
- Lista dos programas disponíveis
- Cards com informações dos programas
- Navegação para detalhes

### ⏳ ProgramDetailScreen (básico)
- Detalhes do programa selecionado
- Lista de dias do programa
- Navegação para workout

### 🚧 A Implementar
- **WorkoutScreen** - Tela principal de tracking
- **ExerciseDetailScreen** - Detalhes do exercício
- **HistoryScreen** - Histórico de treinos
- **SettingsScreen** - Configurações do usuário

---

## 🔧 CONFIGURAÇÃO SUPABASE

### Status Atual
```dart
// main.dart - Configuração básica
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',        // ⚠️ Needs configuration
  anonKey: 'YOUR_SUPABASE_ANON_KEY', // ⚠️ Needs configuration
);
```

### Schema Database (a implementar)
Baseado nos modelos já definidos, será criado no Supabase:
- Tabelas para todos os modelos
- Row Level Security (RLS)
- Triggers para sincronização
- Indexes para performance

---

## 📋 DADOS MOCK IMPLEMENTADOS

### Programas
```dart
static final List<Program> programs = [
  Program(id: 1, name: "3-day Program"),
  Program(id: 2, name: "4-day Program"), 
  Program(id: 3, name: "5-day Program"),
];
```

### Program Days
- **3-day**: Full Body A, B, C
- **4-day**: Upper 1, Lower 1, Upper 2, Lower 2
- **5-day**: Upper, Lower 1, Push, Pull, Lower 2

### Exercícios
20+ exercícios base implementados com nomes reais dos CSVs

---

## 🚀 PRÓXIMOS PASSOS PRIORITÁRIOS

### Fase 1: Setup Completo
- [ ] Configurar credenciais Supabase reais
- [ ] Criar schema database no Supabase
- [ ] Implementar serviços de API
- [ ] Setup de sincronização offline/online

### Fase 2: Migração do Next.js
- [ ] Migrar lógica de workout tracking
- [ ] Implementar WorkoutScreen completa
- [ ] Migrar componentes de progressão
- [ ] Implementar rest timer mobile

### Fase 3: Features Mobile-Específicas
- [ ] Interface touch-friendly otimizada
- [ ] Notificações para rest timer
- [ ] Modo landscape para workout
- [ ] Integração com health apps

---

## 🔄 MIGRAÇÃO DO NEXT.JS

### Features a Migrar
1. **Workout Tracking Logic** (`/programs/[id]/days/[dayId]/page.tsx`)
   - Sistema de sets/reps/peso
   - Cálculos de progressão
   - Cache de últimas séries

2. **Rest Timer** (`rest-timer.tsx`)
   - Timer customizável
   - Audio/vibração alerts
   - Controles play/pause

3. **Progression Suggestions** (`progression-suggestion.tsx`)
   - Algoritmos de progressão
   - Sugestões baseadas em performance
   - Diferentes níveis de agressividade

4. **Data Integration**
   - Estrutura de dados CSV
   - Relacionamentos entre tabelas
   - Lógica de queries

---

## 📱 COMANDOS ÚTEIS

```bash
# Desenvolvimento
flutter run                    # Executar no device/emulator
flutter run --release         # Build release
flutter hot-reload            # Hot reload (r no terminal)

# Build
flutter build apk             # Build Android APK
flutter build ipa             # Build iOS (macOS only)

# Debug & Test
flutter doctor               # Check setup
flutter test                 # Run tests
flutter clean                # Clean build files

# Dependencies
flutter pub get              # Install dependencies
flutter pub upgrade          # Update dependencies
```

---

## 🚨 NOTAS IMPORTANTES

- **Foco mobile-first**: Priorizar experiência durante treinos
- **Offline capability**: Funcionar sem internet
- **Performance**: Resposta instantânea durante uso
- **Battery optimization**: Consumo mínimo de bateria
- **Data sync**: Sincronização confiável quando online

---

## 📝 PRÓXIMA SESSÃO

1. Configurar Supabase com dados reais
2. Implementar WorkoutScreen baseada no Next.js
3. Migrar sistema de tracking completo
4. Testar no device físico
5. Implementar features mobile-específicas

---

**Status**: Estrutura base pronta, aguardando migração das features core do Next.js