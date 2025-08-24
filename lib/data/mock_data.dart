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

  // Exercícios (baseado em exercises.csv - primeiros 10)
  static final List<Exercise> exercises = [
    Exercise(id: 1, name: "Barbell Back Squat"),
    Exercise(id: 2, name: "Barbell Bench Press"),
    Exercise(id: 3, name: "Barbell Deadlift"),
    Exercise(id: 4, name: "Barbell Hip Thrust"),
    Exercise(id: 5, name: "Barbell Row (lat focus)"),
    Exercise(id: 6, name: "Cable Lateral Raise"),
    Exercise(id: 7, name: "Cable Pushdowns*"),
    Exercise(id: 8, name: "Dumbbell Fly"),
    Exercise(id: 9, name: "Dumbbell Lateral Raise"),
    Exercise(id: 10, name: "Dumbbell Romanian Deadlift"),
    Exercise(id: 11, name: "Flat Dumbbell Press"),
    Exercise(id: 12, name: "Hammer Curls"),
    Exercise(id: 13, name: "Incline DB Overhead Extensions"),
    Exercise(id: 14, name: "Incline Dumbbell Curls"),
    Exercise(id: 15, name: "Kneeling Lat Pulldown"),
    Exercise(id: 16, name: "Lat Focused Cable Row"),
    Exercise(id: 17, name: "Lat Pulldown"),
    Exercise(id: 18, name: "Low Incline Dumbbell Press"),
    Exercise(id: 19, name: "Lying Leg Curls"),
    Exercise(id: 20, name: "Quad-Focused Leg Press"),
  ];

  // Variações de exercícios (baseado em exercise_variations.csv - primeiras 10)
  static final List<ExerciseVariation> exerciseVariations = [
    ExerciseVariation(
      id: 1,
      exerciseId: 1,
      variationIndex: 1,
      variationName: "See Tutorial Video",
      youtubeUrl: "https://youtu.be/AWo-q7P-HZ0",
    ),
    ExerciseVariation(
      id: 2,
      exerciseId: 2,
      variationIndex: 1,
      variationName: "See Tutorial Video",
      youtubeUrl: "https://youtu.be/pCGVSBk0bIQ",
    ),
    ExerciseVariation(
      id: 3,
      exerciseId: 3,
      variationIndex: 1,
      variationName: "See Tutorial Video",
      youtubeUrl: "https://youtu.be/JL1tJTEmxfw",
    ),
    ExerciseVariation(
      id: 4,
      exerciseId: 3,
      variationIndex: 2,
      variationName: "Sumo Deadlift",
      youtubeUrl: "https://youtu.be/sO8lFa9CidE",
    ),
    ExerciseVariation(
      id: 5,
      exerciseId: 3,
      variationIndex: 3,
      variationName: "Romanian Deadlift",
      youtubeUrl: "https://youtu.be/3Z3C44SXSQE",
    ),
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

