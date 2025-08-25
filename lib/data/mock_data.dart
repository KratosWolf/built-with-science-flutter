// Mock data baseado nos CSVs fornecidos para desenvolvimento
import '../models/workout_models.dart';

class MockData {
  // Programas (baseado em programs.csv)
  static final List<Program> programs = [
    Program(id: 1, name: "3-day Program", daysPerWeek: 3),
    Program(id: 2, name: "4-day Program", daysPerWeek: 4),
    Program(id: 3, name: "5-day Program", daysPerWeek: 5),
  ];

  // Dias dos programas (baseado em program_days.csv)
  static final List<ProgramDay> programDays = [
    ProgramDay(id: 1, programId: 1, dayIndex: 1, dayName: "Full Body A"),
    ProgramDay(id: 2, programId: 1, dayIndex: 2, dayName: "Full Body B"),
    ProgramDay(id: 3, programId: 1, dayIndex: 3, dayName: "Full Body C"),
    ProgramDay(id: 4, programId: 2, dayIndex: 1, dayName: "Upper 1"),
    ProgramDay(id: 5, programId: 2, dayIndex: 2, dayName: "Lower 1 (Quad Focus)"),
    ProgramDay(id: 6, programId: 2, dayIndex: 3, dayName: "Upper 2"),
    ProgramDay(id: 7, programId: 2, dayIndex: 4, dayName: "Lower 2 (Glute Focus)"),
    ProgramDay(id: 8, programId: 3, dayIndex: 1, dayName: "Upper"),
    ProgramDay(id: 9, programId: 3, dayIndex: 2, dayName: "Lower 1 (Quad Focus)"),
    ProgramDay(id: 10, programId: 3, dayIndex: 3, dayName: "Push"),
    ProgramDay(id: 11, programId: 3, dayIndex: 4, dayName: "Pull"),
    ProgramDay(id: 12, programId: 3, dayIndex: 5, dayName: "Lower 2 (Glute Focus)"),
  ];

  // Exercícios COMPLETOS baseados no CSV do usuário (39 exercícios)
  static final List<Exercise> exercises = [
    // PEITO
    Exercise(id: 1, name: "Barbell Bench Press"),
    Exercise(id: 2, name: "Flat Dumbbell Press"),
    Exercise(id: 3, name: "Flat Machine Chest Press"),
    Exercise(id: 4, name: "Flat Smith Machine Chest Press"),
    Exercise(id: 5, name: "Seated Flat Cable Press"),
    Exercise(id: 6, name: "Neutral Grip DB Press*"),
    
    // COSTAS/POSTERIOR
    Exercise(id: 7, name: "Barbell Romanian Deadlift"),
    Exercise(id: 8, name: "Dumbbell Romanian Deadlift"),
    Exercise(id: 9, name: "Hyperextensions (back/hamstring)"),
    Exercise(id: 10, name: "(Weighted) Pull-Ups"),
    Exercise(id: 11, name: "(Weighted) Chin-Ups"),
    Exercise(id: 12, name: "Banded Pull-Ups"),
    Exercise(id: 13, name: "Pull-Up Negatives"),
    Exercise(id: 14, name: "Kneeling Lat Pulldown"),
    Exercise(id: 15, name: "Lat Pulldown"),
    Exercise(id: 16, name: "Inverted Row"),
    
    // PERNAS/QUADRÍCEPS
    Exercise(id: 17, name: "Walking Lunges (quad focus)"),
    Exercise(id: 18, name: "Heel Elevated Split Squat"),
    Exercise(id: 19, name: "Bulgarian Split Squat (quad focus)"),
    Exercise(id: 20, name: "Reverse Lunges*"),
    Exercise(id: 21, name: "Weighted Step-Ups*"),
    
    // PEITO - ISOLAMENTO
    Exercise(id: 22, name: "Standing Mid-Chest Cable Fly"),
    Exercise(id: 23, name: "Seated Mid-Chest Cable Fly"),
    Exercise(id: 24, name: "Pec-Deck Machine Fly"),
    Exercise(id: 25, name: "Dumbbell Fly"),
    Exercise(id: 26, name: "Banded Push-Ups"),
    
    // OMBROS
    Exercise(id: 27, name: "Dumbbell Lateral Raise"),
    Exercise(id: 28, name: "Cable Lateral Raise"),
    Exercise(id: 29, name: "Lying Incline Lateral Raise"),
    Exercise(id: 30, name: "Lean In Lateral Raise"),
    Exercise(id: 31, name: "Wide Grip BB Upright Row (last resort)"),
    
    // PANTURRILHAS
    Exercise(id: 32, name: "Single Leg Weighted Calf Raise"),
    Exercise(id: 33, name: "Toes-Elevated Smith Machine Calf Raise"),
    Exercise(id: 34, name: "Standing Weighted Calf Raise"),
    Exercise(id: 35, name: "Leg Press Calf Raise"),
    
    // POSTERIOR DELTOIDS
    Exercise(id: 36, name: "Standing Face Pulls"),
    Exercise(id: 37, name: "Bent Over Dumbbell Face Pulls"),
    Exercise(id: 38, name: "(Weighted) Prone Arm Circles"),
    Exercise(id: 39, name: "Wall Slides"),
  ];

  // Variações COMPLETAS com URLs reais do Built with Science
  static final List<ExerciseVariation> exerciseVariations = [
    // BARBELL BENCH PRESS (id: 1) - 6 variações
    ExerciseVariation(id: 1, exerciseId: 1, variationIndex: 1, variationName: "Barbell Bench Press", youtubeUrl: "https://youtu.be/pCGVSBk0bIQ", isPrimary: true),
    ExerciseVariation(id: 2, exerciseId: 1, variationIndex: 2, variationName: "Flat Dumbbell Press", youtubeUrl: "https://youtu.be/g14dhC5KYBM"),
    ExerciseVariation(id: 3, exerciseId: 1, variationIndex: 3, variationName: "Flat Machine Chest Press", youtubeUrl: "https://youtu.be/sO8lFa9CidE"),
    ExerciseVariation(id: 4, exerciseId: 1, variationIndex: 4, variationName: "Flat Smith Machine Chest Press", youtubeUrl: "https://youtu.be/3Z3C44SXSQE"),
    ExerciseVariation(id: 5, exerciseId: 1, variationIndex: 5, variationName: "Seated Flat Cable Press", youtubeUrl: "https://youtu.be/hPpNTAEDnxM"),
    ExerciseVariation(id: 6, exerciseId: 1, variationIndex: 6, variationName: "Neutral Grip DB Press*", youtubeUrl: "https://youtu.be/N-kUwH1uf9c"),
    
    // BARBELL ROMANIAN DEADLIFT (id: 7) - 3 variações
    ExerciseVariation(id: 7, exerciseId: 7, variationIndex: 1, variationName: "Barbell Romanian Deadlift", youtubeUrl: "https://youtu.be/Q-2telZDPRw", isPrimary: true),
    ExerciseVariation(id: 8, exerciseId: 7, variationIndex: 2, variationName: "Dumbbell Romanian Deadlift", youtubeUrl: "https://youtu.be/Xu4DxwKWzl4"),
    ExerciseVariation(id: 9, exerciseId: 7, variationIndex: 3, variationName: "Hyperextensions (back/hamstring)", youtubeUrl: "https://youtu.be/RU5d2H_OmSc"),
    
    // (WEIGHTED) PULL-UPS (id: 10) - 7 variações  
    ExerciseVariation(id: 11, exerciseId: 10, variationIndex: 1, variationName: "(Weighted) Pull-Ups", youtubeUrl: "https://youtu.be/w_yuTRQd6HA", isPrimary: true),
    ExerciseVariation(id: 12, exerciseId: 10, variationIndex: 2, variationName: "(Weighted) Chin-Ups", youtubeUrl: "https://youtu.be/-TZRdvUS7Qo"),
    ExerciseVariation(id: 13, exerciseId: 10, variationIndex: 3, variationName: "Banded Pull-Ups", youtubeUrl: "https://youtu.be/VGm-f5-T5no"),
    ExerciseVariation(id: 14, exerciseId: 10, variationIndex: 4, variationName: "Pull-Up Negatives", youtubeUrl: "https://youtu.be/SyMSay4zrsA"),
    ExerciseVariation(id: 15, exerciseId: 10, variationIndex: 5, variationName: "Kneeling Lat Pulldown", youtubeUrl: "https://youtu.be/4LxKeTqlpZA"),
    ExerciseVariation(id: 16, exerciseId: 10, variationIndex: 6, variationName: "Lat Pulldown", youtubeUrl: "https://youtu.be/AvYZZhEl7Xk"),
    ExerciseVariation(id: 17, exerciseId: 10, variationIndex: 7, variationName: "Inverted Row", youtubeUrl: "https://youtu.be/SyMSay4zrsA"),
    
    // WALKING LUNGES (id: 17) - 5 variações
    ExerciseVariation(id: 18, exerciseId: 17, variationIndex: 1, variationName: "Walking Lunges (quad focus)", youtubeUrl: "https://youtu.be/JB20RuTOaFc", isPrimary: true),
    ExerciseVariation(id: 19, exerciseId: 17, variationIndex: 2, variationName: "Heel Elevated Split Squat", youtubeUrl: "https://youtu.be/bJE0-eZLa6E"),
    ExerciseVariation(id: 20, exerciseId: 17, variationIndex: 3, variationName: "Bulgarian Split Squat (quad focus)", youtubeUrl: "https://youtu.be/r9XtxWSTlcg"),
    ExerciseVariation(id: 21, exerciseId: 17, variationIndex: 4, variationName: "Reverse Lunges*", youtubeUrl: "https://youtu.be/AUEGDvCrQJA"),
    ExerciseVariation(id: 22, exerciseId: 17, variationIndex: 5, variationName: "Weighted Step-Ups*", youtubeUrl: "https://youtu.be/Cjc3AgmdtlA"),
    
    // STANDING MID-CHEST CABLE FLY (id: 22) - 5 variações
    ExerciseVariation(id: 23, exerciseId: 22, variationIndex: 1, variationName: "Standing Mid-Chest Cable Fly", youtubeUrl: "https://youtu.be/fyFVaCP9J-8", isPrimary: true),
    ExerciseVariation(id: 24, exerciseId: 22, variationIndex: 2, variationName: "Seated Mid-Chest Cable Fly", youtubeUrl: "https://youtu.be/Y8E3dHNsSTU"),
    ExerciseVariation(id: 25, exerciseId: 22, variationIndex: 3, variationName: "Pec-Deck Machine Fly", youtubeUrl: "https://youtu.be/rnV3y1P7894"),
    ExerciseVariation(id: 26, exerciseId: 22, variationIndex: 4, variationName: "Dumbbell Fly", youtubeUrl: "https://youtu.be/WRn2hqy0gXU"),
    ExerciseVariation(id: 27, exerciseId: 22, variationIndex: 5, variationName: "Banded Push-Ups", youtubeUrl: "https://youtu.be/dI7LVElfMOg"),
    
    // DUMBBELL LATERAL RAISE (id: 27) - 5 variações
    ExerciseVariation(id: 28, exerciseId: 27, variationIndex: 1, variationName: "Dumbbell Lateral Raise", youtubeUrl: "https://youtu.be/zcO3sgAeLA0", isPrimary: true),
    ExerciseVariation(id: 29, exerciseId: 27, variationIndex: 2, variationName: "Cable Lateral Raise", youtubeUrl: "https://youtu.be/1muit9qEctY"),
    ExerciseVariation(id: 30, exerciseId: 27, variationIndex: 3, variationName: "Lying Incline Lateral Raise", youtubeUrl: "https://youtu.be/upEqeI0F73M"),
    ExerciseVariation(id: 31, exerciseId: 27, variationIndex: 4, variationName: "Lean In Lateral Raise", youtubeUrl: "https://youtu.be/2q4kjTDg-vs"),
    ExerciseVariation(id: 32, exerciseId: 27, variationIndex: 5, variationName: "Wide Grip BB Upright Row (last resort)", youtubeUrl: "https://youtu.be/6BTMVh9AnCw"),
    
    // SINGLE LEG WEIGHTED CALF RAISE (id: 32) - 4 variações
    ExerciseVariation(id: 33, exerciseId: 32, variationIndex: 1, variationName: "Single Leg Weighted Calf Raise", youtubeUrl: "https://youtu.be/cRKA_Qdut7I", isPrimary: true),
    ExerciseVariation(id: 34, exerciseId: 32, variationIndex: 2, variationName: "Toes-Elevated Smith Machine Calf Raise", youtubeUrl: "https://youtu.be/_ChZv2iluM8"),
    ExerciseVariation(id: 35, exerciseId: 32, variationIndex: 3, variationName: "Standing Weighted Calf Raise", youtubeUrl: "https://youtu.be/q2Eigaa9dKU"),
    ExerciseVariation(id: 36, exerciseId: 32, variationIndex: 4, variationName: "Leg Press Calf Raise", youtubeUrl: "https://youtu.be/s8yUXsZrgE0"),
    
    // STANDING FACE PULLS (id: 36) - 4 variações
    ExerciseVariation(id: 37, exerciseId: 36, variationIndex: 1, variationName: "Standing Face Pulls", youtubeUrl: "https://youtu.be/02g7XtSRXug", isPrimary: true),
    ExerciseVariation(id: 38, exerciseId: 36, variationIndex: 2, variationName: "Bent Over Dumbbell Face Pulls", youtubeUrl: "https://youtu.be/kA415Unr-_E"),
    ExerciseVariation(id: 39, exerciseId: 36, variationIndex: 3, variationName: "(Weighted) Prone Arm Circles", youtubeUrl: "https://youtu.be/6D-4V_M8RJA"),
    ExerciseVariation(id: 40, exerciseId: 36, variationIndex: 4, variationName: "Wall Slides", youtubeUrl: "https://youtu.be/x4zjfuLXHVk"),
  ];

  // Mock user para desenvolvimento
  static final WorkoutUser mockUser = WorkoutUser(
    id: "mock-user-123",
    email: "user@builtwithscience.com",
    displayName: "Test User",
    unit: "kg",
    suggestionAggressiveness: "standard",
    videoPref: "smart",
  );

  // Cache de último set (baseado em last_set_cache)
  static final List<LastSetCache> lastSetCache = [
    LastSetCache(
      userId: "mock-user-123",
      exerciseId: 1,
      variationIndex: 1,
      weightKg: 80.0,
      reps: 8,
      restSec: 180,
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    LastSetCache(
      userId: "mock-user-123",
      exerciseId: 2,
      variationIndex: 1,
      weightKg: 60.0,
      reps: 10,
      restSec: 120,
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    LastSetCache(
      userId: "mock-user-123",
      exerciseId: 3,
      variationIndex: 1,
      weightKg: 100.0,
      reps: 6,
      restSec: 240,
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  // Funções helper
  static Program? getProgramById(int id) {
    try {
      return programs.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<ProgramDay> getProgramDays(int programId) {
    return programDays.where((pd) => pd.programId == programId).toList()
      ..sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
  }

  static Exercise? getExerciseById(int id) {
    try {
      return exercises.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<ExerciseVariation> getExerciseVariations(int exerciseId) {
    return exerciseVariations.where((ev) => ev.exerciseId == exerciseId).toList()
      ..sort((a, b) => a.variationIndex.compareTo(b.variationIndex));
  }

  static LastSetCache? getLastSet(String userId, int exerciseId, int? variationIndex) {
    try {
      return lastSetCache.firstWhere(
        (cache) => 
          cache.userId == userId && 
          cache.exerciseId == exerciseId && 
          cache.variationIndex == variationIndex,
      );
    } catch (e) {
      return null;
    }
  }

  // Simular delay de API
  static Future<void> simulateApiDelay([int milliseconds = 500]) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }
}

