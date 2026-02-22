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
    Exercise(id: 1, name: "Barbell Bench Press", sets: 3, repsTarget: "8-10"),
    Exercise(id: 2, name: "Flat Dumbbell Press", sets: 3, repsTarget: "8-10"),
    Exercise(id: 3, name: "Flat Machine Chest Press", sets: 3, repsTarget: "8-10"),
    Exercise(id: 4, name: "Flat Smith Machine Chest Press", sets: 3, repsTarget: "8-10"),
    Exercise(id: 5, name: "Banded Push-Ups", sets: 3, repsTarget: "10+ to failure"),
    Exercise(id: 6, name: "Neutral Grip DB Press*", sets: 3, repsTarget: "8-10"),
    
    // COSTAS/POSTERIOR
    Exercise(id: 7, name: "Barbell Romanian Deadlift", sets: 3, repsTarget: "8-10"),
    Exercise(id: 8, name: "Dumbbell Romanian Deadlift", sets: 3, repsTarget: "8-10"),
    Exercise(id: 9, name: "Hyperextensions (back/hamstring)", sets: 3, repsTarget: "8-10"),
    Exercise(id: 10, name: "(Weighted) Pull-Ups", sets: 3, repsTarget: "6-12"),
    Exercise(id: 11, name: "(Weighted) Chin-Ups", sets: 3, repsTarget: "6-12"),
    Exercise(id: 12, name: "Banded Pull-Ups", sets: 3, repsTarget: "6-12"),
    Exercise(id: 13, name: "Pull-Up Negatives", sets: 3, repsTarget: "6-12"),
    Exercise(id: 14, name: "Kneeling Lat Pulldown", sets: 3, repsTarget: "6-12"),
    Exercise(id: 15, name: "Lat Pulldown", sets: 3, repsTarget: "6-12"),
    Exercise(id: 16, name: "Inverted Row", sets: 3, repsTarget: "6-12"),
    
    // PERNAS/QUADRÍCEPS
    Exercise(id: 17, name: "Walking Lunges (quad focus)", sets: 3, repsTarget: "8-10 per leg"),
    Exercise(id: 18, name: "Heel Elevated Split Squat", sets: 3, repsTarget: "8-10 per leg"),
    Exercise(id: 19, name: "Bulgarian Split Squat (quad focus)", sets: 3, repsTarget: "8-10 per leg"),
    Exercise(id: 20, name: "Reverse Lunges*", sets: 3, repsTarget: "8-10 per leg"),
    Exercise(id: 21, name: "Weighted Step-Ups*", sets: 3, repsTarget: "8-10 per leg"),
    
    // PEITO - ISOLAMENTO
    Exercise(id: 22, name: "Standing Mid-Chest Cable Fly", sets: 3, repsTarget: "10-15"),
    Exercise(id: 23, name: "Seated Mid-Chest Cable Fly", sets: 3, repsTarget: "10-15"),
    Exercise(id: 24, name: "Pec-Deck Machine Fly", sets: 3, repsTarget: "10-15"),
    Exercise(id: 25, name: "Dumbbell Fly", sets: 3, repsTarget: "10-15"),
    Exercise(id: 26, name: "Banded Push-Ups", sets: 3, repsTarget: "10+"),
    
    // OMBROS
    Exercise(id: 27, name: "Dumbbell Lateral Raise", sets: 3, repsTarget: "15-20"),
    Exercise(id: 28, name: "Cable Lateral Raise", sets: 3, repsTarget: "15-20"),
    Exercise(id: 29, name: "Lying Incline Lateral Raise", sets: 3, repsTarget: "15-20"),
    Exercise(id: 30, name: "Lean In Lateral Raise", sets: 3, repsTarget: "15-20"),
    Exercise(id: 31, name: "Wide Grip BB Upright Row (last resort)", sets: 3, repsTarget: "15-20"),
    
    // PANTURRILHAS
    Exercise(id: 32, name: "Single Leg Weighted Calf Raise", sets: 3, repsTarget: "10-15"),
    Exercise(id: 33, name: "Toes-Elevated Smith Machine Calf Raise", sets: 3, repsTarget: "10-15"),
    Exercise(id: 34, name: "Standing Weighted Calf Raise", sets: 3, repsTarget: "10-15"),
    Exercise(id: 35, name: "Leg Press Calf Raise", sets: 3, repsTarget: "10-15"),
    
    // POSTERIOR DELTOIDS
    Exercise(id: 36, name: "Standing Face Pulls", sets: 3, repsTarget: "10"),
    Exercise(id: 37, name: "Bent Over Dumbbell Face Pulls", sets: 3, repsTarget: "10"),
    Exercise(id: 38, name: "(Weighted) Prone Arm Circles", sets: 3, repsTarget: "10"),
    Exercise(id: 39, name: "Wall Slides", sets: 3, repsTarget: "10"),
    
    // EXERCÍCIOS ADICIONAIS PARA FULL BODY B e C
    Exercise(id: 40, name: "Barbell Back Squat", sets: 3, repsTarget: "8-10"),
    Exercise(id: 41, name: "Standing Barbell Overhead Press", sets: 3, repsTarget: "6-8"), 
    Exercise(id: 42, name: "Seated Leg Curls", sets: 3, repsTarget: "10-15"),
    Exercise(id: 43, name: "DB Chest Supported Row (mid/upper back)", sets: 3, repsTarget: "10-12"),
    Exercise(id: 44, name: "Incline DB Overhead Extensions", sets: 3, repsTarget: "10-15"),
    Exercise(id: 45, name: "Seated Weighted Calf Raise", sets: 3, repsTarget: "10-15"),
    Exercise(id: 46, name: "Side Plank", sets: 3, repsTarget: "30-60s hold"),
    Exercise(id: 47, name: "Barbell Deadlift", sets: 3, repsTarget: "6-8"),
    Exercise(id: 48, name: "Low Incline Dumbbell Press", sets: 3, repsTarget: "10-12"),
    Exercise(id: 49, name: "Seated Leg Extensions", sets: 3, repsTarget: "10-15"),
    Exercise(id: 50, name: "Seated Dumbbell Curls", sets: 3, repsTarget: "10-15"),
    
    // Exercício adicional
    Exercise(id: 51, name: "Seated Flat Cable Press", sets: 3, repsTarget: "8-10"),

    // ======================================
    // EXERCÍCIOS DOS PROGRAMAS 4-DAY E 5-DAY
    // ======================================
    // Nota: SUPERSETs agora são 2 exercícios separados (A1 e A2) com mesmo supersetPairId

    // 4-DAY PROGRAM
    // Upper 1 (8 exercícios)
    Exercise(id: 52, name: "Flat Dumbbell Press", day: "Upper 1", program: "4-day", sets: 3, repsTarget: "8-10", youtubeUrl: "https://youtu.be/g14dhC5KYBM"),
    Exercise(id: 53, name: "Lat Pulldown", day: "Upper 1", program: "4-day", sets: 3, repsTarget: "6-12", youtubeUrl: "https://youtu.be/AvYZZhEl7Xk"),
    Exercise(id: 54, name: "Seated Dumbbell Shoulder Press", day: "Upper 1", program: "4-day", sets: 3, repsTarget: "6-8", youtubeUrl: "https://youtu.be/DPXG3BJvl8A"),
    Exercise(id: 55, name: "Dumbbell Fly", day: "Upper 1", program: "4-day", sets: 3, repsTarget: "10-15", youtubeUrl: "https://youtu.be/WRn2hqy0gXU"),
    Exercise(id: 56, name: "Seated Cable Row (mid/upper back)", day: "Upper 1", program: "4-day", sets: 3, repsTarget: "10-12", youtubeUrl: "https://youtu.be/Q-5V5T55giY"),
    Exercise(id: 57, name: "Incline Dumbbell Curls", day: "Upper 1", program: "4-day", sets: 3, repsTarget: "8-10", youtubeUrl: "https://youtu.be/3D56VDVkQnM", isSuperset: true, supersetPairId: 1),
    Exercise(id: 58, name: "Dumbbell Lateral Raise", day: "Upper 1", program: "4-day", sets: 3, repsTarget: "15-20", youtubeUrl: "https://youtu.be/zcO3sgAeLA0", isSuperset: true, supersetPairId: 1),
    Exercise(id: 59, name: "Standing Face Pulls", day: "Upper 1", program: "4-day", sets: 2, repsTarget: "10", youtubeUrl: "https://youtu.be/02g7XtSRXug"),

    // Lower 1 - Quad Focus (7 exercícios)
    Exercise(id: 60, name: "Barbell Back Squat", day: "Lower 1 (Quad Focus)", program: "4-day", sets: 3, repsTarget: "8-10", youtubeUrl: "https://youtu.be/AWo-q7P-HZ0"),
    Exercise(id: 61, name: "Dumbbell Romanian Deadlift", day: "Lower 1 (Quad Focus)", program: "4-day", sets: 3, repsTarget: "8-10", youtubeUrl: "https://youtu.be/Xu4DxwKWzl4", isSuperset: true, supersetPairId: 2),
    Exercise(id: 62, name: "Seated Leg Extensions", day: "Lower 1 (Quad Focus)", program: "4-day", sets: 3, repsTarget: "10-15", youtubeUrl: "https://youtu.be/nIalczfM8es", isSuperset: true, supersetPairId: 2),
    Exercise(id: 63, name: "Walking Lunges (quad focus)", day: "Lower 1 (Quad Focus)", program: "4-day", sets: 3, repsTarget: "8-10 per leg", youtubeUrl: "https://youtu.be/JB20RuTOaFc"),
    Exercise(id: 64, name: "Standing Weighted Calf Raise", day: "Lower 1 (Quad Focus)", program: "4-day", sets: 3, repsTarget: "10-15", youtubeUrl: "https://youtu.be/q2Eigaa9dKU"),
    Exercise(id: 65, name: "Side Plank", day: "Lower 1 (Quad Focus)", program: "4-day", sets: 3, repsTarget: "30-60s hold", youtubeUrl: "https://youtu.be/o4LGPtKjbhU"),

    // Upper 2 (9 exercícios)
    Exercise(id: 66, name: "Low Incline Dumbbell Press", day: "Upper 2", program: "4-day", sets: 3, repsTarget: "8-10", youtubeUrl: "https://youtu.be/kpzUeELReEA"),
    Exercise(id: 67, name: "Lat Focused Cable Row", day: "Upper 2", program: "4-day", sets: 3, repsTarget: "10-12", youtubeUrl: "https://youtu.be/ZaEnZ47cDTk"),
    Exercise(id: 68, name: "Flat Dumbbell Press", day: "Upper 2", program: "4-day", sets: 3, repsTarget: "8-10", youtubeUrl: "https://youtu.be/g14dhC5KYBM"),
    Exercise(id: 69, name: "Rear Delt Cable Row", day: "Upper 2", program: "4-day", sets: 3, repsTarget: "12-15", youtubeUrl: "https://youtu.be/k9G7BykDD4o"),
    Exercise(id: 70, name: "Cable Lateral Raise", day: "Upper 2", program: "4-day", sets: 3, repsTarget: "15-20", youtubeUrl: "https://youtu.be/1muit9qEctY"),
    Exercise(id: 71, name: "Hammer Curls", day: "Upper 2", program: "4-day", sets: 3, repsTarget: "8-10", youtubeUrl: "https://youtu.be/OrGL-ymYREg", isSuperset: true, supersetPairId: 3),
    Exercise(id: 72, name: "Incline DB Overhead Extensions", day: "Upper 2", program: "4-day", sets: 3, repsTarget: "10-15", youtubeUrl: "https://youtu.be/3d86xMhHROA", isSuperset: true, supersetPairId: 3),
    Exercise(id: 73, name: "Standing Face Pulls", day: "Upper 2", program: "4-day", sets: 2, repsTarget: "10", youtubeUrl: "https://youtu.be/02g7XtSRXug"),

    // Lower 2 - Glute Focus (7 exercícios)
    Exercise(id: 74, name: "Barbell Deadlift", day: "Lower 2 (Glute Focus)", program: "4-day", sets: 3, repsTarget: "6-8", youtubeUrl: "https://youtu.be/JL1tJTEmxfw"),
    Exercise(id: 75, name: "Single-Leg Leg Press", day: "Lower 2 (Glute Focus)", program: "4-day", sets: 3, repsTarget: "8-10 per leg", youtubeUrl: "https://youtu.be/hdioTTf8qdw"),
    Exercise(id: 76, name: "Barbell Hip Thrust", day: "Lower 2 (Glute Focus)", program: "4-day", sets: 3, repsTarget: "10-15", youtubeUrl: "https://youtu.be/_vBMijiZoxE"),
    Exercise(id: 77, name: "Lying Leg Curls", day: "Lower 2 (Glute Focus)", program: "4-day", sets: 3, repsTarget: "10-15", youtubeUrl: "https://youtu.be/aYy3alWRDmk"),
    Exercise(id: 78, name: "Banded Hip Abductions", day: "Lower 2 (Glute Focus)", program: "4-day", sets: 3, repsTarget: "15-20", youtubeUrl: "https://youtu.be/CA0ALPgTkxw", isSuperset: true, supersetPairId: 4),
    Exercise(id: 79, name: "Seated Weighted Calf Raise", day: "Lower 2 (Glute Focus)", program: "4-day", sets: 3, repsTarget: "10-15", youtubeUrl: "", isSuperset: true, supersetPairId: 4),

    // 5-DAY PROGRAM
    // Upper (7 exercícios)
    Exercise(id: 80, name: "Barbell Bench Press", day: "Upper", program: "5-day", sets: 3, repsTarget: "8-10", youtubeUrl: "https://youtu.be/pCGVSBk0bIQ"),
    Exercise(id: 81, name: "Seated Cable Row (mid/upper back)", day: "Upper", program: "5-day", sets: 3, repsTarget: "10-12", youtubeUrl: "https://youtu.be/Q-5V5T55giY"),
    Exercise(id: 82, name: "Seated Dumbbell Shoulder Press", day: "Upper", program: "5-day", sets: 3, repsTarget: "6-8", youtubeUrl: "https://youtu.be/DPXG3BJvl8A"),
    Exercise(id: 83, name: "Barbell Row (lat focus)", day: "Upper", program: "5-day", sets: 3, repsTarget: "8-10", youtubeUrl: "https://youtu.be/tS5lKXxtNvE"),
    Exercise(id: 84, name: "Standing High To Low Cable Fly", day: "Upper", program: "5-day", sets: 3, repsTarget: "10-15", youtubeUrl: "https://youtu.be/JfZjng7jAKs"),
    Exercise(id: 85, name: "Dumbbell Lateral Raise", day: "Upper", program: "5-day", sets: 3, repsTarget: "15-20", youtubeUrl: "https://youtu.be/zcO3sgAeLA0"),
    Exercise(id: 86, name: "Standing Face Pulls", day: "Upper", program: "5-day", sets: 3, repsTarget: "10", youtubeUrl: "https://youtu.be/02g7XtSRXug"),

    // Lower 1 - Quad Focus (7 exercícios)
    Exercise(id: 87, name: "Smith Machine Squat", day: "Lower 1 (Quad Focus)", program: "5-day", sets: 3, repsTarget: "8-10", youtubeUrl: "https://youtu.be/zSVi51Jp3eI"),
    Exercise(id: 88, name: "Dumbbell Romanian Deadlift", day: "Lower 1 (Quad Focus)", program: "5-day", sets: 3, repsTarget: "8-10", youtubeUrl: "https://youtu.be/Xu4DxwKWzl4", isSuperset: true, supersetPairId: 5),
    Exercise(id: 89, name: "Seated Leg Extensions", day: "Lower 1 (Quad Focus)", program: "5-day", sets: 3, repsTarget: "10-15", youtubeUrl: "https://youtu.be/nIalczfM8es", isSuperset: true, supersetPairId: 5),
    Exercise(id: 90, name: "Weighted Step-Ups*", day: "Lower 1 (Quad Focus)", program: "5-day", sets: 3, repsTarget: "8-10 per leg", youtubeUrl: "https://youtu.be/Cjc3AgmdtlA"),
    Exercise(id: 91, name: "Single Leg Weighted Calf Raise", day: "Lower 1 (Quad Focus)", program: "5-day", sets: 3, repsTarget: "10-15", youtubeUrl: "https://youtu.be/cRKA_Qdut7I"),
    Exercise(id: 92, name: "Side Plank", day: "Lower 1 (Quad Focus)", program: "5-day", sets: 2, repsTarget: "30-60s hold", youtubeUrl: "https://youtu.be/o4LGPtKjbhU"),

    // Push (6 exercícios)
    Exercise(id: 93, name: "Low Incline Dumbbell Press", day: "Push", program: "5-day", sets: 3, repsTarget: "8-10", youtubeUrl: "https://youtu.be/kpzUeELReEA"),
    Exercise(id: 94, name: "Dumbbell Fly", day: "Push", program: "5-day", sets: 3, repsTarget: "10-15", youtubeUrl: "https://youtu.be/WRn2hqy0gXU"),
    Exercise(id: 95, name: "Flat Dumbbell Press", day: "Push", program: "5-day", sets: 3, repsTarget: "8-10", youtubeUrl: "https://youtu.be/g14dhC5KYBM"),
    Exercise(id: 96, name: "Dumbbell Lateral Raise", day: "Push", program: "5-day", sets: 3, repsTarget: "15-20", youtubeUrl: "https://youtu.be/zcO3sgAeLA0"),
    Exercise(id: 97, name: "Incline DB Overhead Extensions", day: "Push", program: "5-day", sets: 3, repsTarget: "10-15", youtubeUrl: "https://youtu.be/3d86xMhHROA"),
    Exercise(id: 98, name: "Cable Pushdowns*", day: "Push", program: "5-day", sets: 3, repsTarget: "10-15", youtubeUrl: "https://youtu.be/MlfCS_7ZLXA"),

    // Pull (6 exercícios)
    Exercise(id: 99, name: "Kneeling Lat Pulldown", day: "Pull", program: "5-day", sets: 3, repsTarget: "6-12", youtubeUrl: "https://youtu.be/4LxKeTqlpZA"),
    Exercise(id: 100, name: "Lat Focused Cable Row", day: "Pull", program: "5-day", sets: 3, repsTarget: "10-12", youtubeUrl: "https://youtu.be/ZaEnZ47cDTk"),
    Exercise(id: 101, name: "Rear Delt Cable Row", day: "Pull", program: "5-day", sets: 3, repsTarget: "12-15", youtubeUrl: "https://youtu.be/k9G7BykDD4o"),
    Exercise(id: 102, name: "Incline Dumbbell Curls", day: "Pull", program: "5-day", sets: 3, repsTarget: "8-10", youtubeUrl: "https://youtu.be/3D56VDVkQnM"),
    Exercise(id: 103, name: "Hammer Curls", day: "Pull", program: "5-day", sets: 3, repsTarget: "8-10", youtubeUrl: "https://youtu.be/OrGL-ymYREg"),
    Exercise(id: 104, name: "Standing Face Pulls", day: "Pull", program: "5-day", sets: 2, repsTarget: "10", youtubeUrl: "https://youtu.be/02g7XtSRXug"),

    // Lower 2 - Glute Focus (7 exercícios)
    Exercise(id: 105, name: "Barbell Deadlift", day: "Lower 2 (Glute Focus)", program: "5-day", sets: 3, repsTarget: "6-8", youtubeUrl: "https://youtu.be/JL1tJTEmxfw"),
    Exercise(id: 106, name: "Single-Leg Leg Press", day: "Lower 2 (Glute Focus)", program: "5-day", sets: 3, repsTarget: "8-10 per leg", youtubeUrl: "https://youtu.be/hdioTTf8qdw"),
    Exercise(id: 107, name: "Smith Machine Hip Thrust", day: "Lower 2 (Glute Focus)", program: "5-day", sets: 3, repsTarget: "10-15", youtubeUrl: "https://youtu.be/srYETmyq3_c"),
    Exercise(id: 108, name: "Lying Leg Curls", day: "Lower 2 (Glute Focus)", program: "5-day", sets: 3, repsTarget: "10-15", youtubeUrl: "https://youtu.be/aYy3alWRDmk"),
    Exercise(id: 109, name: "Banded Hip Abductions", day: "Lower 2 (Glute Focus)", program: "5-day", sets: 3, repsTarget: "15-20", youtubeUrl: "https://youtu.be/CA0ALPgTkxw", isSuperset: true, supersetPairId: 6),
    Exercise(id: 110, name: "Seated Weighted Calf Raise", day: "Lower 2 (Glute Focus)", program: "5-day", sets: 3, repsTarget: "10-15", youtubeUrl: "", isSuperset: true, supersetPairId: 6),
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
    
    // BANDED PUSH-UPS (id: 5) - 6 variações
    ExerciseVariation(id: 92, exerciseId: 5, variationIndex: 1, variationName: "Banded Push-Ups", youtubeUrl: "https://youtu.be/dI7LVElfMOg", isPrimary: true),
    ExerciseVariation(id: 93, exerciseId: 5, variationIndex: 2, variationName: "Close-Grip Barbell Bench Press", youtubeUrl: "https://youtu.be/JzCGNgXuATs"),
    ExerciseVariation(id: 94, exerciseId: 5, variationIndex: 3, variationName: "Close-Grip Push-Ups", youtubeUrl: "https://youtu.be/ZtAz8gupAss"),
    ExerciseVariation(id: 95, exerciseId: 5, variationIndex: 4, variationName: "Close-Grip Dumbbell Press", youtubeUrl: "https://youtu.be/wHx9-aLjDOM"),
    ExerciseVariation(id: 96, exerciseId: 5, variationIndex: 5, variationName: "Close-Grip Smith Machine Press", youtubeUrl: "https://youtu.be/GIuRW-MDHK8"),
    ExerciseVariation(id: 97, exerciseId: 5, variationIndex: 6, variationName: "Cable Pushdowns*", youtubeUrl: "https://youtu.be/MlfCS_7ZLXA"),
    
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

    // CABLE LATERAL RAISE (id: 28) - 5 variações
    ExerciseVariation(id: 98, exerciseId: 28, variationIndex: 1, variationName: "Cable Lateral Raise", youtubeUrl: "https://youtu.be/1muit9qEctY", isPrimary: true),
    ExerciseVariation(id: 99, exerciseId: 28, variationIndex: 2, variationName: "Dumbbell Lateral Raise", youtubeUrl: "https://youtu.be/zcO3sgAeLA0"),
    ExerciseVariation(id: 100, exerciseId: 28, variationIndex: 3, variationName: "Lying Incline Lateral Raise", youtubeUrl: "https://youtu.be/upEqeI0F73M"),
    ExerciseVariation(id: 101, exerciseId: 28, variationIndex: 4, variationName: "Lean In Lateral Raise", youtubeUrl: "https://youtu.be/2q4kjTDg-vs"),
    ExerciseVariation(id: 102, exerciseId: 28, variationIndex: 5, variationName: "Wide Grip BB Upright Row (last resort)", youtubeUrl: "https://youtu.be/6BTMVh9AnCw"),

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
    
    // BARBELL BACK SQUAT (id: 40) - 7 variações
    ExerciseVariation(id: 41, exerciseId: 40, variationIndex: 1, variationName: "Barbell Back Squat", youtubeUrl: "https://youtu.be/AWo-q7P-HZ0", isPrimary: true),
    ExerciseVariation(id: 42, exerciseId: 40, variationIndex: 2, variationName: "Quad-Focused Leg Press", youtubeUrl: "https://youtu.be/0nrW-q7-WRQ"),
    ExerciseVariation(id: 43, exerciseId: 40, variationIndex: 3, variationName: "Smith Machine Squat", youtubeUrl: "https://youtu.be/zSVi51Jp3eI"),
    ExerciseVariation(id: 44, exerciseId: 40, variationIndex: 4, variationName: "Barbell Back Box Squat*", youtubeUrl: "https://youtu.be/QryQO4VuPK8"),
    ExerciseVariation(id: 45, exerciseId: 40, variationIndex: 5, variationName: "Weighted Step-Ups*", youtubeUrl: "https://youtu.be/Cjc3AgmdtlA"),
    ExerciseVariation(id: 46, exerciseId: 40, variationIndex: 6, variationName: "Dumbbell Goblet Squat*", youtubeUrl: "https://youtu.be/nYDEYFXN2Rs"),
    ExerciseVariation(id: 47, exerciseId: 40, variationIndex: 7, variationName: "Bulgarian Split Squat (quad focus)", youtubeUrl: "https://youtu.be/r9XtxWSTlcg"),
    
    // STANDING BARBELL OVERHEAD PRESS (id: 41) - 5 variações  
    ExerciseVariation(id: 48, exerciseId: 41, variationIndex: 1, variationName: "Standing Barbell Overhead Press", youtubeUrl: "https://youtu.be/S3kYKH32VqI", isPrimary: true),
    ExerciseVariation(id: 49, exerciseId: 41, variationIndex: 2, variationName: "Seated Dumbbell Shoulder Press", youtubeUrl: "https://youtu.be/DPXG3BJvl8A"),
    ExerciseVariation(id: 50, exerciseId: 41, variationIndex: 3, variationName: "Standing Dumbbell Shoulder Press", youtubeUrl: "https://youtu.be/jWriqmLrQqs"),
    ExerciseVariation(id: 51, exerciseId: 41, variationIndex: 4, variationName: "Seated Neutral-Grip DB Press*", youtubeUrl: "https://youtu.be/W35eREjZnhI"),
    ExerciseVariation(id: 52, exerciseId: 41, variationIndex: 5, variationName: "Half Kneeling Landmine Press*", youtubeUrl: "https://youtu.be/JOOS3MPCT8s"),
    
    // SEATED LEG CURLS (id: 42) - 4 variações
    ExerciseVariation(id: 53, exerciseId: 42, variationIndex: 1, variationName: "Seated Leg Curls", youtubeUrl: "https://youtu.be/81umRgyxIAU", isPrimary: true),
    ExerciseVariation(id: 54, exerciseId: 42, variationIndex: 2, variationName: "Lying Leg Curls", youtubeUrl: "https://youtu.be/aYy3alWRDmk"),
    ExerciseVariation(id: 55, exerciseId: 42, variationIndex: 3, variationName: "Swiss Ball Leg Curls", youtubeUrl: "https://youtu.be/uRBpd65dbYs"),
    ExerciseVariation(id: 56, exerciseId: 42, variationIndex: 4, variationName: "Dumbbell Lying Leg Curls", youtubeUrl: "https://youtu.be/Ot1MZipNLOQ"),
    
    // DB CHEST SUPPORTED ROW (id: 43) - 4 variações
    ExerciseVariation(id: 57, exerciseId: 43, variationIndex: 1, variationName: "DB Chest Supported Row (mid/upper back)", youtubeUrl: "https://youtu.be/kNvy2_9Ji2w", isPrimary: true),
    ExerciseVariation(id: 58, exerciseId: 43, variationIndex: 2, variationName: "Barbell Row (mid/upper back)", youtubeUrl: "https://youtu.be/FTCmwlfZ29A"),
    ExerciseVariation(id: 59, exerciseId: 43, variationIndex: 3, variationName: "Seated Cable Row (mid/upper back)", youtubeUrl: "https://youtu.be/Q-5V5T55giY"),
    ExerciseVariation(id: 60, exerciseId: 43, variationIndex: 4, variationName: "Chest Supported Machine Row", youtubeUrl: "https://youtu.be/iDiVxqvHGWY"),
    
    // INCLINE DB OVERHEAD EXTENSIONS (id: 44) - 5 variações
    ExerciseVariation(id: 61, exerciseId: 44, variationIndex: 1, variationName: "Incline DB Overhead Extensions", youtubeUrl: "https://youtu.be/3d86xMhHROA", isPrimary: true),
    ExerciseVariation(id: 62, exerciseId: 44, variationIndex: 2, variationName: "Overhead Rope Extensions", youtubeUrl: "https://youtu.be/7yoTblFCUQM"),
    ExerciseVariation(id: 63, exerciseId: 44, variationIndex: 3, variationName: "Cable Pushdowns*", youtubeUrl: "https://youtu.be/MlfCS_7ZLXA"),
    ExerciseVariation(id: 64, exerciseId: 44, variationIndex: 4, variationName: "Incline Barbell Skullcrushers", youtubeUrl: "https://youtu.be/XgwPiPY4vCI"),
    ExerciseVariation(id: 65, exerciseId: 44, variationIndex: 5, variationName: "Cross Cable Tricep Extensions", youtubeUrl: "https://youtu.be/Fua2QlXnn6Y"),
    
    // SEATED WEIGHTED CALF RAISE (id: 45) - 2 variações
    ExerciseVariation(id: 66, exerciseId: 45, variationIndex: 1, variationName: "Seated Weighted Calf Raise", youtubeUrl: "https://youtu.be/2TkLMol2bCo", isPrimary: true),
    ExerciseVariation(id: 67, exerciseId: 45, variationIndex: 2, variationName: "Seated Bodyweight Calf Raise", youtubeUrl: "https://youtu.be/jW-cNnwRJ7E"),
    
    // SIDE PLANK (id: 46) - 5 variações
    ExerciseVariation(id: 68, exerciseId: 46, variationIndex: 1, variationName: "Side Plank", youtubeUrl: "https://youtu.be/o4LGPtKjbhU", isPrimary: true),
    ExerciseVariation(id: 69, exerciseId: 46, variationIndex: 2, variationName: "RKC Plank", youtubeUrl: "https://youtu.be/lOgA1UfFbWY"),
    ExerciseVariation(id: 70, exerciseId: 46, variationIndex: 3, variationName: "Bird Dog", youtubeUrl: "https://youtu.be/4qE_9h_6Hes"),
    ExerciseVariation(id: 71, exerciseId: 46, variationIndex: 4, variationName: "Palloff Press", youtubeUrl: "https://youtu.be/WhCH2CwVo4I"),
    ExerciseVariation(id: 72, exerciseId: 46, variationIndex: 5, variationName: "Dead Bug", youtubeUrl: "https://youtu.be/UJ7b8gYa2Es"),
    
    // BARBELL DEADLIFT (id: 47) - 6 variações  
    ExerciseVariation(id: 73, exerciseId: 47, variationIndex: 1, variationName: "Barbell Deadlift", youtubeUrl: "https://youtu.be/JL1tJTEmxfw", isPrimary: true),
    ExerciseVariation(id: 74, exerciseId: 47, variationIndex: 2, variationName: "Sumo Deadlift*", youtubeUrl: "https://youtu.be/9rXKd-_DaRs"),
    ExerciseVariation(id: 75, exerciseId: 47, variationIndex: 3, variationName: "Trap Bar Deadlift*", youtubeUrl: "https://youtu.be/5mnlJtf-7WM"),
    ExerciseVariation(id: 76, exerciseId: 47, variationIndex: 4, variationName: "Dumbbell Romanian Deadlift", youtubeUrl: "https://youtu.be/Xu4DxwKWzl4"),
    ExerciseVariation(id: 77, exerciseId: 47, variationIndex: 5, variationName: "Hyperextensions (back/hamstring)", youtubeUrl: "https://youtu.be/RU5d2H_OmSc"),
    ExerciseVariation(id: 78, exerciseId: 47, variationIndex: 6, variationName: "Glute Focused Leg Press", youtubeUrl: "https://youtu.be/p13BNdwR93A"),
    
    // LOW INCLINE DUMBBELL PRESS (id: 48) - 6 variações
    ExerciseVariation(id: 79, exerciseId: 48, variationIndex: 1, variationName: "Low Incline Dumbbell Press", youtubeUrl: "https://youtu.be/kpzUeELReEA", isPrimary: true),
    ExerciseVariation(id: 80, exerciseId: 48, variationIndex: 2, variationName: "Incline Machine Chest Press", youtubeUrl: "https://youtu.be/abc1fisYB3w"),
    ExerciseVariation(id: 81, exerciseId: 48, variationIndex: 3, variationName: "Low Incline Smith Machine Press", youtubeUrl: "https://youtu.be/R53nThQcdZo"),
    ExerciseVariation(id: 82, exerciseId: 48, variationIndex: 4, variationName: "Low Incline Barbell Press", youtubeUrl: "https://youtu.be/jW4j7FoqudI"),
    ExerciseVariation(id: 83, exerciseId: 48, variationIndex: 5, variationName: "Low Incline Cable Press", youtubeUrl: "https://youtu.be/6qV1WZ_z0u0"),
    ExerciseVariation(id: 84, exerciseId: 48, variationIndex: 6, variationName: "(Banded) Decline Push-Ups", youtubeUrl: "https://youtu.be/LdahU9kB-u0"),
    
    // SEATED LEG EXTENSIONS (id: 49) - 4 variações
    ExerciseVariation(id: 85, exerciseId: 49, variationIndex: 1, variationName: "Seated Leg Extensions", youtubeUrl: "https://youtu.be/nIalczfM8es", isPrimary: true),
    ExerciseVariation(id: 86, exerciseId: 49, variationIndex: 2, variationName: "Sissy Squat", youtubeUrl: "https://youtu.be/3SeCC8ABZ_Q"),
    ExerciseVariation(id: 87, exerciseId: 49, variationIndex: 3, variationName: "Heel Elevated Goblet Squat", youtubeUrl: "https://youtu.be/l9crMLuT4II"),
    ExerciseVariation(id: 88, exerciseId: 49, variationIndex: 4, variationName: "Reverse Lunges*", youtubeUrl: "https://youtu.be/AUEGDvCrQJA"),
    
    // SEATED DUMBBELL CURLS (id: 50) - 3 variações
    ExerciseVariation(id: 89, exerciseId: 50, variationIndex: 1, variationName: "Seated Dumbbell Curls", youtubeUrl: "https://youtu.be/qUAzPq4B2aw", isPrimary: true),
    ExerciseVariation(id: 90, exerciseId: 50, variationIndex: 2, variationName: "Standing Cable Curl", youtubeUrl: "https://youtu.be/8Bb-ak2lB8E"),
    ExerciseVariation(id: 91, exerciseId: 50, variationIndex: 3, variationName: "Dumbbell Spider Curls", youtubeUrl: "https://youtu.be/hDDcQkCxHjE"),


    // ======================================
    // VARIAÇÕES DOS PROGRAMAS 4-DAY E 5-DAY
    // ======================================

    // Exercise ID 52 → G00 (6 variações)
    ExerciseVariation(id: 103, exerciseId: 52, variationIndex: 1, variationName: "Barbell Bench Press", youtubeUrl: "https://youtu.be/pCGVSBk0bIQ", isPrimary: true),
    ExerciseVariation(id: 104, exerciseId: 52, variationIndex: 2, variationName: "Flat Dumbbell Press", youtubeUrl: "https://youtu.be/g14dhC5KYBM", isPrimary: false),
    ExerciseVariation(id: 105, exerciseId: 52, variationIndex: 3, variationName: "Flat Machine Chest Press", youtubeUrl: "https://youtu.be/sO8lFa9CidE", isPrimary: false),
    ExerciseVariation(id: 106, exerciseId: 52, variationIndex: 4, variationName: "Flat Smith Machine Chest Press", youtubeUrl: "https://youtu.be/3Z3C44SXSQE", isPrimary: false),
    ExerciseVariation(id: 107, exerciseId: 52, variationIndex: 5, variationName: "Seated Flat Cable Press", youtubeUrl: "https://youtu.be/hPpNTAEDnxM", isPrimary: false),
    ExerciseVariation(id: 108, exerciseId: 52, variationIndex: 6, variationName: "Neutral Grip DB Press*", youtubeUrl: "https://youtu.be/N-kUwH1uf9c", isPrimary: false),

    // Exercise ID 53 → G08 (5 variações)
    ExerciseVariation(id: 109, exerciseId: 53, variationIndex: 1, variationName: "Lat Pulldown", youtubeUrl: "https://youtu.be/AvYZZhEl7Xk", isPrimary: true),
    ExerciseVariation(id: 110, exerciseId: 53, variationIndex: 2, variationName: "(Weighted) Pull-Ups", youtubeUrl: "https://youtu.be/w_yuTRQd6HA", isPrimary: false),
    ExerciseVariation(id: 111, exerciseId: 53, variationIndex: 3, variationName: "Kneeling One Arm Lat Pulldown", youtubeUrl: "https://youtu.be/", isPrimary: false),
    ExerciseVariation(id: 112, exerciseId: 53, variationIndex: 4, variationName: "3 Point Dumbbell Row", youtubeUrl: "https://youtu.be/", isPrimary: false),
    ExerciseVariation(id: 113, exerciseId: 53, variationIndex: 5, variationName: "Barbell Row (lat focus)", youtubeUrl: "https://youtu.be/tS5lKXxtNvE", isPrimary: false),

    // Exercise ID 54 → G11 (5 variações)
    ExerciseVariation(id: 114, exerciseId: 54, variationIndex: 1, variationName: "Standing Barbell Overhead Press", youtubeUrl: "https://youtu.be/S3kYKH32VqI", isPrimary: true),
    ExerciseVariation(id: 115, exerciseId: 54, variationIndex: 2, variationName: "Seated Dumbbell Shoulder Press", youtubeUrl: "https://youtu.be/DPXG3BJvl8A", isPrimary: false),
    ExerciseVariation(id: 116, exerciseId: 54, variationIndex: 3, variationName: "Standing Dumbbell Shoulder Press", youtubeUrl: "https://youtu.be/jWriqmLrQqs", isPrimary: false),
    ExerciseVariation(id: 117, exerciseId: 54, variationIndex: 4, variationName: "Seated Neutral-Grip DB Press*", youtubeUrl: "https://youtu.be/W35eREjZnhI", isPrimary: false),
    ExerciseVariation(id: 118, exerciseId: 54, variationIndex: 5, variationName: "Half Kneeling Landmine Press*", youtubeUrl: "https://youtu.be/JOOS3MPCT8s", isPrimary: false),

    // Exercise ID 55 → G04 (5 variações)
    ExerciseVariation(id: 119, exerciseId: 55, variationIndex: 1, variationName: "Standing Mid-Chest Cable Fly", youtubeUrl: "https://youtu.be/fyFVaCP9J-8", isPrimary: true),
    ExerciseVariation(id: 120, exerciseId: 55, variationIndex: 2, variationName: "Seated Mid-Chest Cable Fly", youtubeUrl: "https://youtu.be/Y8E3dHNsSTU", isPrimary: false),
    ExerciseVariation(id: 121, exerciseId: 55, variationIndex: 3, variationName: "Pec-Deck Machine Fly", youtubeUrl: "https://youtu.be/rnV3y1P7894", isPrimary: false),
    ExerciseVariation(id: 122, exerciseId: 55, variationIndex: 4, variationName: "Dumbbell Fly", youtubeUrl: "https://youtu.be/WRn2hqy0gXU", isPrimary: false),
    ExerciseVariation(id: 123, exerciseId: 55, variationIndex: 5, variationName: "Banded Push-Ups", youtubeUrl: "https://youtu.be/dI7LVElfMOg", isPrimary: false),

    // Exercise ID 56 → G07b (4 variações)
    ExerciseVariation(id: 124, exerciseId: 56, variationIndex: 1, variationName: "DB Chest Supported Row (mid/upper back)", youtubeUrl: "https://youtu.be/kNvy2_9Ji2w", isPrimary: true),
    ExerciseVariation(id: 125, exerciseId: 56, variationIndex: 2, variationName: "Barbell Row (mid/upper back)", youtubeUrl: "https://youtu.be/FTCmwlfZ29A", isPrimary: false),
    ExerciseVariation(id: 126, exerciseId: 56, variationIndex: 3, variationName: "Seated Cable Row (mid/upper back)", youtubeUrl: "https://youtu.be/Q-5V5T55giY", isPrimary: false),
    ExerciseVariation(id: 127, exerciseId: 56, variationIndex: 4, variationName: "Chest Supported Machine Row", youtubeUrl: "https://youtu.be/iDiVxqvHGWY", isPrimary: false),

    // Exercise ID 57 → G05 (3 variações)
    ExerciseVariation(id: 128, exerciseId: 57, variationIndex: 1, variationName: "Incline Dumbbell Curls", youtubeUrl: "https://youtu.be/3D56VDVkQnM", isPrimary: true),
    ExerciseVariation(id: 129, exerciseId: 57, variationIndex: 2, variationName: "Behind Body Cable Curls", youtubeUrl: "https://youtu.be/S2CNDlAY8kY", isPrimary: false),
    ExerciseVariation(id: 130, exerciseId: 57, variationIndex: 3, variationName: "Barbell Curl", youtubeUrl: "https://youtu.be/-ClfZ00zo8c", isPrimary: false),

    // Exercise ID 58 → G13 (5 variações)
    ExerciseVariation(id: 131, exerciseId: 58, variationIndex: 1, variationName: "Dumbbell Lateral Raise", youtubeUrl: "https://youtu.be/zcO3sgAeLA0", isPrimary: true),
    ExerciseVariation(id: 132, exerciseId: 58, variationIndex: 2, variationName: "Cable Lateral Raise", youtubeUrl: "https://youtu.be/1muit9qEctY", isPrimary: false),
    ExerciseVariation(id: 133, exerciseId: 58, variationIndex: 3, variationName: "Lying Incline Lateral Raise", youtubeUrl: "https://youtu.be/upEqeI0F73M", isPrimary: false),
    ExerciseVariation(id: 134, exerciseId: 58, variationIndex: 4, variationName: "Lean In Lateral Raise", youtubeUrl: "https://youtu.be/2q4kjTDg-vs", isPrimary: false),
    ExerciseVariation(id: 135, exerciseId: 58, variationIndex: 5, variationName: "Wide Grip BB Upright Row (last resort)", youtubeUrl: "https://youtu.be/6BTMVh9AnCw", isPrimary: false),

    // Exercise ID 59 → G12 (4 variações)
    ExerciseVariation(id: 136, exerciseId: 59, variationIndex: 1, variationName: "Standing Face Pulls", youtubeUrl: "https://youtu.be/02g7XtSRXug", isPrimary: true),
    ExerciseVariation(id: 137, exerciseId: 59, variationIndex: 2, variationName: "Bent Over Dumbbell Face Pulls", youtubeUrl: "https://youtu.be/kA415Unr-_E", isPrimary: false),
    ExerciseVariation(id: 138, exerciseId: 59, variationIndex: 3, variationName: "(Weighted) Prone Arm Circles", youtubeUrl: "https://youtu.be/6D-4V_M8RJA", isPrimary: false),
    ExerciseVariation(id: 139, exerciseId: 59, variationIndex: 4, variationName: "Wall Slides", youtubeUrl: "https://youtu.be/x4zjfuLXHVk", isPrimary: false),

    // Exercise ID 60 → G16 (7 variações)
    ExerciseVariation(id: 140, exerciseId: 60, variationIndex: 1, variationName: "Barbell Back Squat", youtubeUrl: "https://youtu.be/AWo-q7P-HZ0", isPrimary: true),
    ExerciseVariation(id: 141, exerciseId: 60, variationIndex: 2, variationName: "Quad-Focused Leg Press", youtubeUrl: "https://youtu.be/0nrW-q7-WRQ", isPrimary: false),
    ExerciseVariation(id: 142, exerciseId: 60, variationIndex: 3, variationName: "Smith Machine Squat", youtubeUrl: "https://youtu.be/zSVi51Jp3eI", isPrimary: false),
    ExerciseVariation(id: 143, exerciseId: 60, variationIndex: 4, variationName: "Barbell Back Box Squat*", youtubeUrl: "https://youtu.be/QryQO4VuPK8", isPrimary: false),
    ExerciseVariation(id: 144, exerciseId: 60, variationIndex: 5, variationName: "Weighted Step-Ups*", youtubeUrl: "https://youtu.be/Cjc3AgmdtlA", isPrimary: false),
    ExerciseVariation(id: 145, exerciseId: 60, variationIndex: 6, variationName: "Dumbbell Goblet Squat*", youtubeUrl: "https://youtu.be/nYDEYFXN2Rs", isPrimary: false),
    ExerciseVariation(id: 146, exerciseId: 60, variationIndex: 7, variationName: "Bulgarian Split Squat (quad focus)", youtubeUrl: "https://youtu.be/r9XtxWSTlcg", isPrimary: false),

    // Exercise ID 61 → G20 (3 variações)
    ExerciseVariation(id: 147, exerciseId: 61, variationIndex: 1, variationName: "Barbell Romanian Deadlift", youtubeUrl: "https://youtu.be/Q-2telZDPRw", isPrimary: true),
    ExerciseVariation(id: 148, exerciseId: 61, variationIndex: 2, variationName: "Dumbbell Romanian Deadlift", youtubeUrl: "https://youtu.be/Xu4DxwKWzl4", isPrimary: false),
    ExerciseVariation(id: 149, exerciseId: 61, variationIndex: 3, variationName: "Hyperextensions (back/hamstring)", youtubeUrl: "https://youtu.be/RU5d2H_OmSc", isPrimary: false),

    // Exercise ID 62 → G18 (4 variações)
    ExerciseVariation(id: 150, exerciseId: 62, variationIndex: 1, variationName: "Seated Leg Extensions", youtubeUrl: "https://youtu.be/nIalczfM8es", isPrimary: true),
    ExerciseVariation(id: 151, exerciseId: 62, variationIndex: 2, variationName: "Sissy Squat", youtubeUrl: "https://youtu.be/3SeCC8ABZ_Q", isPrimary: false),
    ExerciseVariation(id: 152, exerciseId: 62, variationIndex: 3, variationName: "Heel Elevated Goblet Squat", youtubeUrl: "https://youtu.be/l9crMLuT4II", isPrimary: false),
    ExerciseVariation(id: 153, exerciseId: 62, variationIndex: 4, variationName: "Reverse Lunges*", youtubeUrl: "https://youtu.be/AUEGDvCrQJA", isPrimary: false),

    // Exercise ID 63 → G39 (5 variações)
    ExerciseVariation(id: 154, exerciseId: 63, variationIndex: 1, variationName: "Walking Lunges (quad focus)", youtubeUrl: "https://youtu.be/JB20RuTOaFc", isPrimary: true),
    ExerciseVariation(id: 155, exerciseId: 63, variationIndex: 2, variationName: "Heel Elevated Split Squat", youtubeUrl: "https://youtu.be/bJE0-eZLa6E", isPrimary: false),
    ExerciseVariation(id: 156, exerciseId: 63, variationIndex: 3, variationName: "Bulgarian Split Squat (quad focus)", youtubeUrl: "https://youtu.be/r9XtxWSTlcg", isPrimary: false),
    ExerciseVariation(id: 157, exerciseId: 63, variationIndex: 4, variationName: "Reverse Lunges*", youtubeUrl: "https://youtu.be/AUEGDvCrQJA", isPrimary: false),
    ExerciseVariation(id: 158, exerciseId: 63, variationIndex: 5, variationName: "Weighted Step-Ups*", youtubeUrl: "https://youtu.be/Cjc3AgmdtlA", isPrimary: false),

    // Exercise ID 64 → G23 (4 variações)
    ExerciseVariation(id: 159, exerciseId: 64, variationIndex: 1, variationName: "Single Leg Weighted Calf Raise", youtubeUrl: "https://youtu.be/cRKA_Qdut7I", isPrimary: true),
    ExerciseVariation(id: 160, exerciseId: 64, variationIndex: 2, variationName: "Toes-Elevated Smith Machine Calf Raise", youtubeUrl: "https://youtu.be/_ChZv2iluM8", isPrimary: false),
    ExerciseVariation(id: 161, exerciseId: 64, variationIndex: 3, variationName: "Standing Weighted Calf Raise", youtubeUrl: "https://youtu.be/q2Eigaa9dKU", isPrimary: false),
    ExerciseVariation(id: 162, exerciseId: 64, variationIndex: 4, variationName: "Leg Press Calf Raise", youtubeUrl: "https://youtu.be/s8yUXsZrgE0", isPrimary: false),

    // Exercise ID 65 → G25 (5 variações)
    ExerciseVariation(id: 163, exerciseId: 65, variationIndex: 1, variationName: "Side Plank", youtubeUrl: "https://youtu.be/o4LGPtKjbhU", isPrimary: true),
    ExerciseVariation(id: 164, exerciseId: 65, variationIndex: 2, variationName: "RKC Plank", youtubeUrl: "https://youtu.be/lOgA1UfFbWY", isPrimary: false),
    ExerciseVariation(id: 165, exerciseId: 65, variationIndex: 3, variationName: "Bird Dog", youtubeUrl: "https://youtu.be/4qE_9h_6Hes", isPrimary: false),
    ExerciseVariation(id: 166, exerciseId: 65, variationIndex: 4, variationName: "Palloff Press", youtubeUrl: "https://youtu.be/WhCH2CwVo4I", isPrimary: false),
    ExerciseVariation(id: 167, exerciseId: 65, variationIndex: 5, variationName: "Dead Bug", youtubeUrl: "https://youtu.be/UJ7b8gYa2Es", isPrimary: false),

    // Exercise ID 66 → G03 (6 variações)
    ExerciseVariation(id: 168, exerciseId: 66, variationIndex: 1, variationName: "Low Incline Dumbbell Press", youtubeUrl: "https://youtu.be/kpzUeELReEA", isPrimary: true),
    ExerciseVariation(id: 169, exerciseId: 66, variationIndex: 2, variationName: "Incline Machine Chest Press", youtubeUrl: "https://youtu.be/abc1fisYB3w", isPrimary: false),
    ExerciseVariation(id: 170, exerciseId: 66, variationIndex: 3, variationName: "Low Incline Smith Machine Press", youtubeUrl: "https://youtu.be/R53nThQcdZo", isPrimary: false),
    ExerciseVariation(id: 171, exerciseId: 66, variationIndex: 4, variationName: "Low Incline Barbell Press", youtubeUrl: "https://youtu.be/jW4j7FoqudI", isPrimary: false),
    ExerciseVariation(id: 172, exerciseId: 66, variationIndex: 5, variationName: "Low Incline Cable Press", youtubeUrl: "https://youtu.be/6qV1WZ_z0u0", isPrimary: false),
    ExerciseVariation(id: 173, exerciseId: 66, variationIndex: 6, variationName: "(Banded) Decline Push-Ups", youtubeUrl: "https://youtu.be/LdahU9kB-u0", isPrimary: false),

    // Exercise ID 67 → G40 (4 variações)
    ExerciseVariation(id: 174, exerciseId: 67, variationIndex: 1, variationName: "Lat Focused Cable Row", youtubeUrl: "https://youtu.be/ZaEnZ47cDTk", isPrimary: true),
    ExerciseVariation(id: 175, exerciseId: 67, variationIndex: 2, variationName: "Chest Supported DB Row (lat focus)", youtubeUrl: "https://youtu.be/", isPrimary: false),
    ExerciseVariation(id: 176, exerciseId: 67, variationIndex: 3, variationName: "Barbell Row (lat focus)", youtubeUrl: "https://youtu.be/tS5lKXxtNvE", isPrimary: false),
    ExerciseVariation(id: 177, exerciseId: 67, variationIndex: 4, variationName: "Half-Kneeling Cable Row", youtubeUrl: "https://youtu.be/", isPrimary: false),

    // Exercise ID 68 → G00 (6 variações)
    ExerciseVariation(id: 178, exerciseId: 68, variationIndex: 1, variationName: "Barbell Bench Press", youtubeUrl: "https://youtu.be/pCGVSBk0bIQ", isPrimary: true),
    ExerciseVariation(id: 179, exerciseId: 68, variationIndex: 2, variationName: "Flat Dumbbell Press", youtubeUrl: "https://youtu.be/g14dhC5KYBM", isPrimary: false),
    ExerciseVariation(id: 180, exerciseId: 68, variationIndex: 3, variationName: "Flat Machine Chest Press", youtubeUrl: "https://youtu.be/sO8lFa9CidE", isPrimary: false),
    ExerciseVariation(id: 181, exerciseId: 68, variationIndex: 4, variationName: "Flat Smith Machine Chest Press", youtubeUrl: "https://youtu.be/3Z3C44SXSQE", isPrimary: false),
    ExerciseVariation(id: 182, exerciseId: 68, variationIndex: 5, variationName: "Seated Flat Cable Press", youtubeUrl: "https://youtu.be/hPpNTAEDnxM", isPrimary: false),
    ExerciseVariation(id: 183, exerciseId: 68, variationIndex: 6, variationName: "Neutral Grip DB Press*", youtubeUrl: "https://youtu.be/N-kUwH1uf9c", isPrimary: false),

    // Exercise ID 69 → G10b (4 variações)
    ExerciseVariation(id: 184, exerciseId: 69, variationIndex: 1, variationName: "Rear Delt Cable Row", youtubeUrl: "https://youtu.be/k9G7BykDD4o", isPrimary: true),
    ExerciseVariation(id: 185, exerciseId: 69, variationIndex: 2, variationName: "Chest Supported DB Rear Delt Row", youtubeUrl: "https://youtu.be/", isPrimary: false),
    ExerciseVariation(id: 186, exerciseId: 69, variationIndex: 3, variationName: "Rear Delt Cable Fly", youtubeUrl: "https://youtu.be/", isPrimary: false),
    ExerciseVariation(id: 187, exerciseId: 69, variationIndex: 4, variationName: "Barbell Row (mid/upper back)", youtubeUrl: "https://youtu.be/FTCmwlfZ29A", isPrimary: false),

    // Exercise ID 70 → G15 (5 variações)
    ExerciseVariation(id: 188, exerciseId: 70, variationIndex: 1, variationName: "Cable Lateral Raise", youtubeUrl: "https://youtu.be/1muit9qEctY", isPrimary: true),
    ExerciseVariation(id: 189, exerciseId: 70, variationIndex: 2, variationName: "Lying Incline Lateral Raise", youtubeUrl: "https://youtu.be/upEqeI0F73M", isPrimary: false),
    ExerciseVariation(id: 190, exerciseId: 70, variationIndex: 3, variationName: "Dumbbell Lateral Raise", youtubeUrl: "https://youtu.be/zcO3sgAeLA0", isPrimary: false),
    ExerciseVariation(id: 191, exerciseId: 70, variationIndex: 4, variationName: "Lean In Lateral Raise", youtubeUrl: "https://youtu.be/2q4kjTDg-vs", isPrimary: false),
    ExerciseVariation(id: 192, exerciseId: 70, variationIndex: 5, variationName: "Wide Grip BB Upright Row (last resort)", youtubeUrl: "https://youtu.be/6BTMVh9AnCw", isPrimary: false),

    // Exercise ID 71 → G06 (2 variações)
    ExerciseVariation(id: 193, exerciseId: 71, variationIndex: 1, variationName: "Hammer Curls", youtubeUrl: "https://youtu.be/OrGL-ymYREg", isPrimary: true),
    ExerciseVariation(id: 194, exerciseId: 71, variationIndex: 2, variationName: "Rope Cable Curls (neutral grip)", youtubeUrl: "https://youtu.be/0vEzBCydrU0", isPrimary: false),

    // Exercise ID 72 → G07a (5 variações)
    ExerciseVariation(id: 195, exerciseId: 72, variationIndex: 1, variationName: "Incline DB Overhead Extensions", youtubeUrl: "https://youtu.be/3d86xMhHROA", isPrimary: true),
    ExerciseVariation(id: 196, exerciseId: 72, variationIndex: 2, variationName: "Overhead Rope Extensions", youtubeUrl: "https://youtu.be/7yoTblFCUQM", isPrimary: false),
    ExerciseVariation(id: 197, exerciseId: 72, variationIndex: 3, variationName: "Cable Pushdowns*", youtubeUrl: "https://youtu.be/MlfCS_7ZLXA", isPrimary: false),
    ExerciseVariation(id: 198, exerciseId: 72, variationIndex: 4, variationName: "Incline Barbell Skullcrushers", youtubeUrl: "https://youtu.be/XgwPiPY4vCI", isPrimary: false),
    ExerciseVariation(id: 199, exerciseId: 72, variationIndex: 5, variationName: "Cross Cable Tricep Extensions", youtubeUrl: "https://youtu.be/Fua2QlXnn6Y", isPrimary: false),

    // Exercise ID 73 → G12 (4 variações)
    ExerciseVariation(id: 200, exerciseId: 73, variationIndex: 1, variationName: "Standing Face Pulls", youtubeUrl: "https://youtu.be/02g7XtSRXug", isPrimary: true),
    ExerciseVariation(id: 201, exerciseId: 73, variationIndex: 2, variationName: "Bent Over Dumbbell Face Pulls", youtubeUrl: "https://youtu.be/kA415Unr-_E", isPrimary: false),
    ExerciseVariation(id: 202, exerciseId: 73, variationIndex: 3, variationName: "(Weighted) Prone Arm Circles", youtubeUrl: "https://youtu.be/6D-4V_M8RJA", isPrimary: false),
    ExerciseVariation(id: 203, exerciseId: 73, variationIndex: 4, variationName: "Wall Slides", youtubeUrl: "https://youtu.be/x4zjfuLXHVk", isPrimary: false),

    // Exercise ID 74 → G19 (6 variações)
    ExerciseVariation(id: 204, exerciseId: 74, variationIndex: 1, variationName: "Barbell Deadlift", youtubeUrl: "https://youtu.be/JL1tJTEmxfw", isPrimary: true),
    ExerciseVariation(id: 205, exerciseId: 74, variationIndex: 2, variationName: "Sumo Deadlift*", youtubeUrl: "https://youtu.be/9rXKd-_DaRs", isPrimary: false),
    ExerciseVariation(id: 206, exerciseId: 74, variationIndex: 3, variationName: "Trap Bar Deadlift*", youtubeUrl: "https://youtu.be/5mnlJtf-7WM", isPrimary: false),
    ExerciseVariation(id: 207, exerciseId: 74, variationIndex: 4, variationName: "Dumbbell Romanian Deadlift", youtubeUrl: "https://youtu.be/Xu4DxwKWzl4", isPrimary: false),
    ExerciseVariation(id: 208, exerciseId: 74, variationIndex: 5, variationName: "Hyperextensions (back/hamstring)", youtubeUrl: "https://youtu.be/RU5d2H_OmSc", isPrimary: false),
    ExerciseVariation(id: 209, exerciseId: 74, variationIndex: 6, variationName: "Glute Focused Leg Press", youtubeUrl: "https://youtu.be/p13BNdwR93A", isPrimary: false),

    // Exercise ID 75 → G17 (5 variações)
    ExerciseVariation(id: 210, exerciseId: 75, variationIndex: 1, variationName: "Bulgarian Split Squat (glute focus)", youtubeUrl: "https://youtu.be/r9XtxWSTlcg", isPrimary: true),
    ExerciseVariation(id: 211, exerciseId: 75, variationIndex: 2, variationName: "Front Foot Elevated Reverse Lunge", youtubeUrl: "https://youtu.be/", isPrimary: false),
    ExerciseVariation(id: 212, exerciseId: 75, variationIndex: 3, variationName: "Reverse Lunges*", youtubeUrl: "https://youtu.be/AUEGDvCrQJA", isPrimary: false),
    ExerciseVariation(id: 213, exerciseId: 75, variationIndex: 4, variationName: "Weighted Step-Ups*", youtubeUrl: "https://youtu.be/Cjc3AgmdtlA", isPrimary: false),
    ExerciseVariation(id: 214, exerciseId: 75, variationIndex: 5, variationName: "Single-Leg Leg Press", youtubeUrl: "https://youtu.be/hdioTTf8qdw", isPrimary: false),

    // Exercise ID 76 → G31 (5 variações)
    ExerciseVariation(id: 215, exerciseId: 76, variationIndex: 1, variationName: "Barbell Hip Thrust", youtubeUrl: "https://youtu.be/_vBMijiZoxE", isPrimary: true),
    ExerciseVariation(id: 216, exerciseId: 76, variationIndex: 2, variationName: "Smith Machine Hip Thrust", youtubeUrl: "https://youtu.be/srYETmyq3_c", isPrimary: false),
    ExerciseVariation(id: 217, exerciseId: 76, variationIndex: 3, variationName: "(Weighted) Single Leg Hip Thrusts", youtubeUrl: "https://youtu.be/", isPrimary: false),
    ExerciseVariation(id: 218, exerciseId: 76, variationIndex: 4, variationName: "Hyperextensions (glute focus)", youtubeUrl: "https://youtu.be/", isPrimary: false),
    ExerciseVariation(id: 219, exerciseId: 76, variationIndex: 5, variationName: "Reverse Hyperextensions", youtubeUrl: "https://youtu.be/", isPrimary: false),

    // Exercise ID 77 → G21 (4 variações)
    ExerciseVariation(id: 220, exerciseId: 77, variationIndex: 1, variationName: "Seated Leg Curls", youtubeUrl: "https://youtu.be/81umRgyxIAU", isPrimary: true),
    ExerciseVariation(id: 221, exerciseId: 77, variationIndex: 2, variationName: "Lying Leg Curls", youtubeUrl: "https://youtu.be/aYy3alWRDmk", isPrimary: false),
    ExerciseVariation(id: 222, exerciseId: 77, variationIndex: 3, variationName: "Swiss Ball Leg Curls", youtubeUrl: "https://youtu.be/uRBpd65dbYs", isPrimary: false),
    ExerciseVariation(id: 223, exerciseId: 77, variationIndex: 4, variationName: "Dumbbell Lying Leg Curls", youtubeUrl: "https://youtu.be/Ot1MZipNLOQ", isPrimary: false),

    // Exercise ID 78 → G33 (3 variações)
    ExerciseVariation(id: 224, exerciseId: 78, variationIndex: 1, variationName: "Banded Hip Abductions", youtubeUrl: "https://youtu.be/CA0ALPgTkxw", isPrimary: true),
    ExerciseVariation(id: 225, exerciseId: 78, variationIndex: 2, variationName: "Side Lying Leg Raise", youtubeUrl: "https://youtu.be/", isPrimary: false),
    ExerciseVariation(id: 226, exerciseId: 78, variationIndex: 3, variationName: "Side Lying Hip Raise", youtubeUrl: "https://youtu.be/", isPrimary: false),

    // Exercise ID 79 → G24 (2 variações)
    ExerciseVariation(id: 227, exerciseId: 79, variationIndex: 1, variationName: "Seated Weighted Calf Raise", youtubeUrl: "https://youtu.be/2TkLMol2bCo", isPrimary: true),
    ExerciseVariation(id: 228, exerciseId: 79, variationIndex: 2, variationName: "Seated Bodyweight Calf Raise", youtubeUrl: "https://youtu.be/jW-cNnwRJ7E", isPrimary: false),

    // Exercise ID 80 → G00 (6 variações)
    ExerciseVariation(id: 229, exerciseId: 80, variationIndex: 1, variationName: "Barbell Bench Press", youtubeUrl: "https://youtu.be/pCGVSBk0bIQ", isPrimary: true),
    ExerciseVariation(id: 230, exerciseId: 80, variationIndex: 2, variationName: "Flat Dumbbell Press", youtubeUrl: "https://youtu.be/g14dhC5KYBM", isPrimary: false),
    ExerciseVariation(id: 231, exerciseId: 80, variationIndex: 3, variationName: "Flat Machine Chest Press", youtubeUrl: "https://youtu.be/sO8lFa9CidE", isPrimary: false),
    ExerciseVariation(id: 232, exerciseId: 80, variationIndex: 4, variationName: "Flat Smith Machine Chest Press", youtubeUrl: "https://youtu.be/3Z3C44SXSQE", isPrimary: false),
    ExerciseVariation(id: 233, exerciseId: 80, variationIndex: 5, variationName: "Seated Flat Cable Press", youtubeUrl: "https://youtu.be/hPpNTAEDnxM", isPrimary: false),
    ExerciseVariation(id: 234, exerciseId: 80, variationIndex: 6, variationName: "Neutral Grip DB Press*", youtubeUrl: "https://youtu.be/N-kUwH1uf9c", isPrimary: false),

    // Exercise ID 81 → G07b (4 variações)
    ExerciseVariation(id: 235, exerciseId: 81, variationIndex: 1, variationName: "DB Chest Supported Row (mid/upper back)", youtubeUrl: "https://youtu.be/kNvy2_9Ji2w", isPrimary: true),
    ExerciseVariation(id: 236, exerciseId: 81, variationIndex: 2, variationName: "Barbell Row (mid/upper back)", youtubeUrl: "https://youtu.be/FTCmwlfZ29A", isPrimary: false),
    ExerciseVariation(id: 237, exerciseId: 81, variationIndex: 3, variationName: "Seated Cable Row (mid/upper back)", youtubeUrl: "https://youtu.be/Q-5V5T55giY", isPrimary: false),
    ExerciseVariation(id: 238, exerciseId: 81, variationIndex: 4, variationName: "Chest Supported Machine Row", youtubeUrl: "https://youtu.be/iDiVxqvHGWY", isPrimary: false),

    // Exercise ID 82 → G11 (5 variações)
    ExerciseVariation(id: 239, exerciseId: 82, variationIndex: 1, variationName: "Standing Barbell Overhead Press", youtubeUrl: "https://youtu.be/S3kYKH32VqI", isPrimary: true),
    ExerciseVariation(id: 240, exerciseId: 82, variationIndex: 2, variationName: "Seated Dumbbell Shoulder Press", youtubeUrl: "https://youtu.be/DPXG3BJvl8A", isPrimary: false),
    ExerciseVariation(id: 241, exerciseId: 82, variationIndex: 3, variationName: "Standing Dumbbell Shoulder Press", youtubeUrl: "https://youtu.be/jWriqmLrQqs", isPrimary: false),
    ExerciseVariation(id: 242, exerciseId: 82, variationIndex: 4, variationName: "Seated Neutral-Grip DB Press*", youtubeUrl: "https://youtu.be/W35eREjZnhI", isPrimary: false),
    ExerciseVariation(id: 243, exerciseId: 82, variationIndex: 5, variationName: "Half Kneeling Landmine Press*", youtubeUrl: "https://youtu.be/JOOS3MPCT8s", isPrimary: false),

    // Exercise ID 83 → G08 (5 variações)
    ExerciseVariation(id: 244, exerciseId: 83, variationIndex: 1, variationName: "Lat Pulldown", youtubeUrl: "https://youtu.be/AvYZZhEl7Xk", isPrimary: true),
    ExerciseVariation(id: 245, exerciseId: 83, variationIndex: 2, variationName: "(Weighted) Pull-Ups", youtubeUrl: "https://youtu.be/w_yuTRQd6HA", isPrimary: false),
    ExerciseVariation(id: 246, exerciseId: 83, variationIndex: 3, variationName: "Kneeling One Arm Lat Pulldown", youtubeUrl: "https://youtu.be/", isPrimary: false),
    ExerciseVariation(id: 247, exerciseId: 83, variationIndex: 4, variationName: "3 Point Dumbbell Row", youtubeUrl: "https://youtu.be/", isPrimary: false),
    ExerciseVariation(id: 248, exerciseId: 83, variationIndex: 5, variationName: "Barbell Row (lat focus)", youtubeUrl: "https://youtu.be/tS5lKXxtNvE", isPrimary: false),

    // Exercise ID 84 → G01 (3 variações)
    ExerciseVariation(id: 249, exerciseId: 84, variationIndex: 1, variationName: "(Banded) Decline Push-Ups", youtubeUrl: "https://youtu.be/LdahU9kB-u0", isPrimary: true),
    ExerciseVariation(id: 250, exerciseId: 84, variationIndex: 2, variationName: "Standing High To Low Cable Fly", youtubeUrl: "https://youtu.be/JfZjng7jAKs", isPrimary: false),
    ExerciseVariation(id: 251, exerciseId: 84, variationIndex: 3, variationName: "Decline Dumbbell Press", youtubeUrl: "https://youtu.be/iv3Uldr7LJc", isPrimary: false),

    // Exercise ID 85 → G13 (5 variações)
    ExerciseVariation(id: 252, exerciseId: 85, variationIndex: 1, variationName: "Dumbbell Lateral Raise", youtubeUrl: "https://youtu.be/zcO3sgAeLA0", isPrimary: true),
    ExerciseVariation(id: 253, exerciseId: 85, variationIndex: 2, variationName: "Cable Lateral Raise", youtubeUrl: "https://youtu.be/1muit9qEctY", isPrimary: false),
    ExerciseVariation(id: 254, exerciseId: 85, variationIndex: 3, variationName: "Lying Incline Lateral Raise", youtubeUrl: "https://youtu.be/upEqeI0F73M", isPrimary: false),
    ExerciseVariation(id: 255, exerciseId: 85, variationIndex: 4, variationName: "Lean In Lateral Raise", youtubeUrl: "https://youtu.be/2q4kjTDg-vs", isPrimary: false),
    ExerciseVariation(id: 256, exerciseId: 85, variationIndex: 5, variationName: "Wide Grip BB Upright Row (last resort)", youtubeUrl: "https://youtu.be/6BTMVh9AnCw", isPrimary: false),

    // Exercise ID 86 → G12 (4 variações)
    ExerciseVariation(id: 257, exerciseId: 86, variationIndex: 1, variationName: "Standing Face Pulls", youtubeUrl: "https://youtu.be/02g7XtSRXug", isPrimary: true),
    ExerciseVariation(id: 258, exerciseId: 86, variationIndex: 2, variationName: "Bent Over Dumbbell Face Pulls", youtubeUrl: "https://youtu.be/kA415Unr-_E", isPrimary: false),
    ExerciseVariation(id: 259, exerciseId: 86, variationIndex: 3, variationName: "(Weighted) Prone Arm Circles", youtubeUrl: "https://youtu.be/6D-4V_M8RJA", isPrimary: false),
    ExerciseVariation(id: 260, exerciseId: 86, variationIndex: 4, variationName: "Wall Slides", youtubeUrl: "https://youtu.be/x4zjfuLXHVk", isPrimary: false),

    // Exercise ID 87 → G16 (7 variações)
    ExerciseVariation(id: 261, exerciseId: 87, variationIndex: 1, variationName: "Barbell Back Squat", youtubeUrl: "https://youtu.be/AWo-q7P-HZ0", isPrimary: true),
    ExerciseVariation(id: 262, exerciseId: 87, variationIndex: 2, variationName: "Quad-Focused Leg Press", youtubeUrl: "https://youtu.be/0nrW-q7-WRQ", isPrimary: false),
    ExerciseVariation(id: 263, exerciseId: 87, variationIndex: 3, variationName: "Smith Machine Squat", youtubeUrl: "https://youtu.be/zSVi51Jp3eI", isPrimary: false),
    ExerciseVariation(id: 264, exerciseId: 87, variationIndex: 4, variationName: "Barbell Back Box Squat*", youtubeUrl: "https://youtu.be/QryQO4VuPK8", isPrimary: false),
    ExerciseVariation(id: 265, exerciseId: 87, variationIndex: 5, variationName: "Weighted Step-Ups*", youtubeUrl: "https://youtu.be/Cjc3AgmdtlA", isPrimary: false),
    ExerciseVariation(id: 266, exerciseId: 87, variationIndex: 6, variationName: "Dumbbell Goblet Squat*", youtubeUrl: "https://youtu.be/nYDEYFXN2Rs", isPrimary: false),
    ExerciseVariation(id: 267, exerciseId: 87, variationIndex: 7, variationName: "Bulgarian Split Squat (quad focus)", youtubeUrl: "https://youtu.be/r9XtxWSTlcg", isPrimary: false),

    // Exercise ID 88 → G20 (3 variações)
    ExerciseVariation(id: 268, exerciseId: 88, variationIndex: 1, variationName: "Barbell Romanian Deadlift", youtubeUrl: "https://youtu.be/Q-2telZDPRw", isPrimary: true),
    ExerciseVariation(id: 269, exerciseId: 88, variationIndex: 2, variationName: "Dumbbell Romanian Deadlift", youtubeUrl: "https://youtu.be/Xu4DxwKWzl4", isPrimary: false),
    ExerciseVariation(id: 270, exerciseId: 88, variationIndex: 3, variationName: "Hyperextensions (back/hamstring)", youtubeUrl: "https://youtu.be/RU5d2H_OmSc", isPrimary: false),

    // Exercise ID 89 → G18 (4 variações)
    ExerciseVariation(id: 271, exerciseId: 89, variationIndex: 1, variationName: "Seated Leg Extensions", youtubeUrl: "https://youtu.be/nIalczfM8es", isPrimary: true),
    ExerciseVariation(id: 272, exerciseId: 89, variationIndex: 2, variationName: "Sissy Squat", youtubeUrl: "https://youtu.be/3SeCC8ABZ_Q", isPrimary: false),
    ExerciseVariation(id: 273, exerciseId: 89, variationIndex: 3, variationName: "Heel Elevated Goblet Squat", youtubeUrl: "https://youtu.be/l9crMLuT4II", isPrimary: false),
    ExerciseVariation(id: 274, exerciseId: 89, variationIndex: 4, variationName: "Reverse Lunges*", youtubeUrl: "https://youtu.be/AUEGDvCrQJA", isPrimary: false),

    // Exercise ID 90 → G16 (7 variações)
    ExerciseVariation(id: 275, exerciseId: 90, variationIndex: 1, variationName: "Barbell Back Squat", youtubeUrl: "https://youtu.be/AWo-q7P-HZ0", isPrimary: true),
    ExerciseVariation(id: 276, exerciseId: 90, variationIndex: 2, variationName: "Quad-Focused Leg Press", youtubeUrl: "https://youtu.be/0nrW-q7-WRQ", isPrimary: false),
    ExerciseVariation(id: 277, exerciseId: 90, variationIndex: 3, variationName: "Smith Machine Squat", youtubeUrl: "https://youtu.be/zSVi51Jp3eI", isPrimary: false),
    ExerciseVariation(id: 278, exerciseId: 90, variationIndex: 4, variationName: "Barbell Back Box Squat*", youtubeUrl: "https://youtu.be/QryQO4VuPK8", isPrimary: false),
    ExerciseVariation(id: 279, exerciseId: 90, variationIndex: 5, variationName: "Weighted Step-Ups*", youtubeUrl: "https://youtu.be/Cjc3AgmdtlA", isPrimary: false),
    ExerciseVariation(id: 280, exerciseId: 90, variationIndex: 6, variationName: "Dumbbell Goblet Squat*", youtubeUrl: "https://youtu.be/nYDEYFXN2Rs", isPrimary: false),
    ExerciseVariation(id: 281, exerciseId: 90, variationIndex: 7, variationName: "Bulgarian Split Squat (quad focus)", youtubeUrl: "https://youtu.be/r9XtxWSTlcg", isPrimary: false),

    // Exercise ID 91 → G23 (4 variações)
    ExerciseVariation(id: 282, exerciseId: 91, variationIndex: 1, variationName: "Single Leg Weighted Calf Raise", youtubeUrl: "https://youtu.be/cRKA_Qdut7I", isPrimary: true),
    ExerciseVariation(id: 283, exerciseId: 91, variationIndex: 2, variationName: "Toes-Elevated Smith Machine Calf Raise", youtubeUrl: "https://youtu.be/_ChZv2iluM8", isPrimary: false),
    ExerciseVariation(id: 284, exerciseId: 91, variationIndex: 3, variationName: "Standing Weighted Calf Raise", youtubeUrl: "https://youtu.be/q2Eigaa9dKU", isPrimary: false),
    ExerciseVariation(id: 285, exerciseId: 91, variationIndex: 4, variationName: "Leg Press Calf Raise", youtubeUrl: "https://youtu.be/s8yUXsZrgE0", isPrimary: false),

    // Exercise ID 92 → G25 (5 variações)
    ExerciseVariation(id: 286, exerciseId: 92, variationIndex: 1, variationName: "Side Plank", youtubeUrl: "https://youtu.be/o4LGPtKjbhU", isPrimary: true),
    ExerciseVariation(id: 287, exerciseId: 92, variationIndex: 2, variationName: "RKC Plank", youtubeUrl: "https://youtu.be/lOgA1UfFbWY", isPrimary: false),
    ExerciseVariation(id: 288, exerciseId: 92, variationIndex: 3, variationName: "Bird Dog", youtubeUrl: "https://youtu.be/4qE_9h_6Hes", isPrimary: false),
    ExerciseVariation(id: 289, exerciseId: 92, variationIndex: 4, variationName: "Palloff Press", youtubeUrl: "https://youtu.be/WhCH2CwVo4I", isPrimary: false),
    ExerciseVariation(id: 290, exerciseId: 92, variationIndex: 5, variationName: "Dead Bug", youtubeUrl: "https://youtu.be/UJ7b8gYa2Es", isPrimary: false),

    // Exercise ID 93 → G03 (6 variações)
    ExerciseVariation(id: 291, exerciseId: 93, variationIndex: 1, variationName: "Low Incline Dumbbell Press", youtubeUrl: "https://youtu.be/kpzUeELReEA", isPrimary: true),
    ExerciseVariation(id: 292, exerciseId: 93, variationIndex: 2, variationName: "Incline Machine Chest Press", youtubeUrl: "https://youtu.be/abc1fisYB3w", isPrimary: false),
    ExerciseVariation(id: 293, exerciseId: 93, variationIndex: 3, variationName: "Low Incline Smith Machine Press", youtubeUrl: "https://youtu.be/R53nThQcdZo", isPrimary: false),
    ExerciseVariation(id: 294, exerciseId: 93, variationIndex: 4, variationName: "Low Incline Barbell Press", youtubeUrl: "https://youtu.be/jW4j7FoqudI", isPrimary: false),
    ExerciseVariation(id: 295, exerciseId: 93, variationIndex: 5, variationName: "Low Incline Cable Press", youtubeUrl: "https://youtu.be/6qV1WZ_z0u0", isPrimary: false),
    ExerciseVariation(id: 296, exerciseId: 93, variationIndex: 6, variationName: "(Banded) Decline Push-Ups", youtubeUrl: "https://youtu.be/LdahU9kB-u0", isPrimary: false),

    // Exercise ID 94 → G04 (5 variações)
    ExerciseVariation(id: 297, exerciseId: 94, variationIndex: 1, variationName: "Standing Mid-Chest Cable Fly", youtubeUrl: "https://youtu.be/fyFVaCP9J-8", isPrimary: true),
    ExerciseVariation(id: 298, exerciseId: 94, variationIndex: 2, variationName: "Seated Mid-Chest Cable Fly", youtubeUrl: "https://youtu.be/Y8E3dHNsSTU", isPrimary: false),
    ExerciseVariation(id: 299, exerciseId: 94, variationIndex: 3, variationName: "Pec-Deck Machine Fly", youtubeUrl: "https://youtu.be/rnV3y1P7894", isPrimary: false),
    ExerciseVariation(id: 300, exerciseId: 94, variationIndex: 4, variationName: "Dumbbell Fly", youtubeUrl: "https://youtu.be/WRn2hqy0gXU", isPrimary: false),
    ExerciseVariation(id: 301, exerciseId: 94, variationIndex: 5, variationName: "Banded Push-Ups", youtubeUrl: "https://youtu.be/dI7LVElfMOg", isPrimary: false),

    // Exercise ID 95 → G00 (6 variações)
    ExerciseVariation(id: 302, exerciseId: 95, variationIndex: 1, variationName: "Barbell Bench Press", youtubeUrl: "https://youtu.be/pCGVSBk0bIQ", isPrimary: true),
    ExerciseVariation(id: 303, exerciseId: 95, variationIndex: 2, variationName: "Flat Dumbbell Press", youtubeUrl: "https://youtu.be/g14dhC5KYBM", isPrimary: false),
    ExerciseVariation(id: 304, exerciseId: 95, variationIndex: 3, variationName: "Flat Machine Chest Press", youtubeUrl: "https://youtu.be/sO8lFa9CidE", isPrimary: false),
    ExerciseVariation(id: 305, exerciseId: 95, variationIndex: 4, variationName: "Flat Smith Machine Chest Press", youtubeUrl: "https://youtu.be/3Z3C44SXSQE", isPrimary: false),
    ExerciseVariation(id: 306, exerciseId: 95, variationIndex: 5, variationName: "Seated Flat Cable Press", youtubeUrl: "https://youtu.be/hPpNTAEDnxM", isPrimary: false),
    ExerciseVariation(id: 307, exerciseId: 95, variationIndex: 6, variationName: "Neutral Grip DB Press*", youtubeUrl: "https://youtu.be/N-kUwH1uf9c", isPrimary: false),

    // Exercise ID 96 → G13 (5 variações)
    ExerciseVariation(id: 308, exerciseId: 96, variationIndex: 1, variationName: "Dumbbell Lateral Raise", youtubeUrl: "https://youtu.be/zcO3sgAeLA0", isPrimary: true),
    ExerciseVariation(id: 309, exerciseId: 96, variationIndex: 2, variationName: "Cable Lateral Raise", youtubeUrl: "https://youtu.be/1muit9qEctY", isPrimary: false),
    ExerciseVariation(id: 310, exerciseId: 96, variationIndex: 3, variationName: "Lying Incline Lateral Raise", youtubeUrl: "https://youtu.be/upEqeI0F73M", isPrimary: false),
    ExerciseVariation(id: 311, exerciseId: 96, variationIndex: 4, variationName: "Lean In Lateral Raise", youtubeUrl: "https://youtu.be/2q4kjTDg-vs", isPrimary: false),
    ExerciseVariation(id: 312, exerciseId: 96, variationIndex: 5, variationName: "Wide Grip BB Upright Row (last resort)", youtubeUrl: "https://youtu.be/6BTMVh9AnCw", isPrimary: false),

    // Exercise ID 97 → G07a (5 variações)
    ExerciseVariation(id: 313, exerciseId: 97, variationIndex: 1, variationName: "Incline DB Overhead Extensions", youtubeUrl: "https://youtu.be/3d86xMhHROA", isPrimary: true),
    ExerciseVariation(id: 314, exerciseId: 97, variationIndex: 2, variationName: "Overhead Rope Extensions", youtubeUrl: "https://youtu.be/7yoTblFCUQM", isPrimary: false),
    ExerciseVariation(id: 315, exerciseId: 97, variationIndex: 3, variationName: "Cable Pushdowns*", youtubeUrl: "https://youtu.be/MlfCS_7ZLXA", isPrimary: false),
    ExerciseVariation(id: 316, exerciseId: 97, variationIndex: 4, variationName: "Incline Barbell Skullcrushers", youtubeUrl: "https://youtu.be/XgwPiPY4vCI", isPrimary: false),
    ExerciseVariation(id: 317, exerciseId: 97, variationIndex: 5, variationName: "Cross Cable Tricep Extensions", youtubeUrl: "https://youtu.be/Fua2QlXnn6Y", isPrimary: false),

    // Exercise ID 98 → G07a (5 variações)
    ExerciseVariation(id: 318, exerciseId: 98, variationIndex: 1, variationName: "Incline DB Overhead Extensions", youtubeUrl: "https://youtu.be/3d86xMhHROA", isPrimary: true),
    ExerciseVariation(id: 319, exerciseId: 98, variationIndex: 2, variationName: "Overhead Rope Extensions", youtubeUrl: "https://youtu.be/7yoTblFCUQM", isPrimary: false),
    ExerciseVariation(id: 320, exerciseId: 98, variationIndex: 3, variationName: "Cable Pushdowns*", youtubeUrl: "https://youtu.be/MlfCS_7ZLXA", isPrimary: false),
    ExerciseVariation(id: 321, exerciseId: 98, variationIndex: 4, variationName: "Incline Barbell Skullcrushers", youtubeUrl: "https://youtu.be/XgwPiPY4vCI", isPrimary: false),
    ExerciseVariation(id: 322, exerciseId: 98, variationIndex: 5, variationName: "Cross Cable Tricep Extensions", youtubeUrl: "https://youtu.be/Fua2QlXnn6Y", isPrimary: false),

    // Exercise ID 99 → G08 (5 variações)
    ExerciseVariation(id: 323, exerciseId: 99, variationIndex: 1, variationName: "Lat Pulldown", youtubeUrl: "https://youtu.be/AvYZZhEl7Xk", isPrimary: true),
    ExerciseVariation(id: 324, exerciseId: 99, variationIndex: 2, variationName: "(Weighted) Pull-Ups", youtubeUrl: "https://youtu.be/w_yuTRQd6HA", isPrimary: false),
    ExerciseVariation(id: 325, exerciseId: 99, variationIndex: 3, variationName: "Kneeling One Arm Lat Pulldown", youtubeUrl: "https://youtu.be/", isPrimary: false),
    ExerciseVariation(id: 326, exerciseId: 99, variationIndex: 4, variationName: "3 Point Dumbbell Row", youtubeUrl: "https://youtu.be/", isPrimary: false),
    ExerciseVariation(id: 327, exerciseId: 99, variationIndex: 5, variationName: "Barbell Row (lat focus)", youtubeUrl: "https://youtu.be/tS5lKXxtNvE", isPrimary: false),

    // Exercise ID 100 → G40 (4 variações)
    ExerciseVariation(id: 328, exerciseId: 100, variationIndex: 1, variationName: "Lat Focused Cable Row", youtubeUrl: "https://youtu.be/ZaEnZ47cDTk", isPrimary: true),
    ExerciseVariation(id: 329, exerciseId: 100, variationIndex: 2, variationName: "Chest Supported DB Row (lat focus)", youtubeUrl: "https://youtu.be/", isPrimary: false),
    ExerciseVariation(id: 330, exerciseId: 100, variationIndex: 3, variationName: "Barbell Row (lat focus)", youtubeUrl: "https://youtu.be/tS5lKXxtNvE", isPrimary: false),
    ExerciseVariation(id: 331, exerciseId: 100, variationIndex: 4, variationName: "Half-Kneeling Cable Row", youtubeUrl: "https://youtu.be/", isPrimary: false),

    // Exercise ID 101 → G10b (4 variações)
    ExerciseVariation(id: 332, exerciseId: 101, variationIndex: 1, variationName: "Rear Delt Cable Row", youtubeUrl: "https://youtu.be/k9G7BykDD4o", isPrimary: true),
    ExerciseVariation(id: 333, exerciseId: 101, variationIndex: 2, variationName: "Chest Supported DB Rear Delt Row", youtubeUrl: "https://youtu.be/", isPrimary: false),
    ExerciseVariation(id: 334, exerciseId: 101, variationIndex: 3, variationName: "Rear Delt Cable Fly", youtubeUrl: "https://youtu.be/", isPrimary: false),
    ExerciseVariation(id: 335, exerciseId: 101, variationIndex: 4, variationName: "Barbell Row (mid/upper back)", youtubeUrl: "https://youtu.be/FTCmwlfZ29A", isPrimary: false),

    // Exercise ID 102 → G05 (3 variações)
    ExerciseVariation(id: 336, exerciseId: 102, variationIndex: 1, variationName: "Incline Dumbbell Curls", youtubeUrl: "https://youtu.be/3D56VDVkQnM", isPrimary: true),
    ExerciseVariation(id: 337, exerciseId: 102, variationIndex: 2, variationName: "Behind Body Cable Curls", youtubeUrl: "https://youtu.be/S2CNDlAY8kY", isPrimary: false),
    ExerciseVariation(id: 338, exerciseId: 102, variationIndex: 3, variationName: "Barbell Curl", youtubeUrl: "https://youtu.be/-ClfZ00zo8c", isPrimary: false),

    // Exercise ID 103 → G06 (2 variações)
    ExerciseVariation(id: 339, exerciseId: 103, variationIndex: 1, variationName: "Hammer Curls", youtubeUrl: "https://youtu.be/OrGL-ymYREg", isPrimary: true),
    ExerciseVariation(id: 340, exerciseId: 103, variationIndex: 2, variationName: "Rope Cable Curls (neutral grip)", youtubeUrl: "https://youtu.be/0vEzBCydrU0", isPrimary: false),

    // Exercise ID 104 → G12 (4 variações)
    ExerciseVariation(id: 341, exerciseId: 104, variationIndex: 1, variationName: "Standing Face Pulls", youtubeUrl: "https://youtu.be/02g7XtSRXug", isPrimary: true),
    ExerciseVariation(id: 342, exerciseId: 104, variationIndex: 2, variationName: "Bent Over Dumbbell Face Pulls", youtubeUrl: "https://youtu.be/kA415Unr-_E", isPrimary: false),
    ExerciseVariation(id: 343, exerciseId: 104, variationIndex: 3, variationName: "(Weighted) Prone Arm Circles", youtubeUrl: "https://youtu.be/6D-4V_M8RJA", isPrimary: false),
    ExerciseVariation(id: 344, exerciseId: 104, variationIndex: 4, variationName: "Wall Slides", youtubeUrl: "https://youtu.be/x4zjfuLXHVk", isPrimary: false),

    // Exercise ID 105 → G19 (6 variações)
    ExerciseVariation(id: 345, exerciseId: 105, variationIndex: 1, variationName: "Barbell Deadlift", youtubeUrl: "https://youtu.be/JL1tJTEmxfw", isPrimary: true),
    ExerciseVariation(id: 346, exerciseId: 105, variationIndex: 2, variationName: "Sumo Deadlift*", youtubeUrl: "https://youtu.be/9rXKd-_DaRs", isPrimary: false),
    ExerciseVariation(id: 347, exerciseId: 105, variationIndex: 3, variationName: "Trap Bar Deadlift*", youtubeUrl: "https://youtu.be/5mnlJtf-7WM", isPrimary: false),
    ExerciseVariation(id: 348, exerciseId: 105, variationIndex: 4, variationName: "Dumbbell Romanian Deadlift", youtubeUrl: "https://youtu.be/Xu4DxwKWzl4", isPrimary: false),
    ExerciseVariation(id: 349, exerciseId: 105, variationIndex: 5, variationName: "Hyperextensions (back/hamstring)", youtubeUrl: "https://youtu.be/RU5d2H_OmSc", isPrimary: false),
    ExerciseVariation(id: 350, exerciseId: 105, variationIndex: 6, variationName: "Glute Focused Leg Press", youtubeUrl: "https://youtu.be/p13BNdwR93A", isPrimary: false),

    // Exercise ID 106 → G17 (5 variações)
    ExerciseVariation(id: 351, exerciseId: 106, variationIndex: 1, variationName: "Bulgarian Split Squat (glute focus)", youtubeUrl: "https://youtu.be/r9XtxWSTlcg", isPrimary: true),
    ExerciseVariation(id: 352, exerciseId: 106, variationIndex: 2, variationName: "Front Foot Elevated Reverse Lunge", youtubeUrl: "https://youtu.be/", isPrimary: false),
    ExerciseVariation(id: 353, exerciseId: 106, variationIndex: 3, variationName: "Reverse Lunges*", youtubeUrl: "https://youtu.be/AUEGDvCrQJA", isPrimary: false),
    ExerciseVariation(id: 354, exerciseId: 106, variationIndex: 4, variationName: "Weighted Step-Ups*", youtubeUrl: "https://youtu.be/Cjc3AgmdtlA", isPrimary: false),
    ExerciseVariation(id: 355, exerciseId: 106, variationIndex: 5, variationName: "Single-Leg Leg Press", youtubeUrl: "https://youtu.be/hdioTTf8qdw", isPrimary: false),

    // Exercise ID 107 → G31 (5 variações)
    ExerciseVariation(id: 356, exerciseId: 107, variationIndex: 1, variationName: "Barbell Hip Thrust", youtubeUrl: "https://youtu.be/_vBMijiZoxE", isPrimary: true),
    ExerciseVariation(id: 357, exerciseId: 107, variationIndex: 2, variationName: "Smith Machine Hip Thrust", youtubeUrl: "https://youtu.be/srYETmyq3_c", isPrimary: false),
    ExerciseVariation(id: 358, exerciseId: 107, variationIndex: 3, variationName: "(Weighted) Single Leg Hip Thrusts", youtubeUrl: "https://youtu.be/", isPrimary: false),
    ExerciseVariation(id: 359, exerciseId: 107, variationIndex: 4, variationName: "Hyperextensions (glute focus)", youtubeUrl: "https://youtu.be/", isPrimary: false),
    ExerciseVariation(id: 360, exerciseId: 107, variationIndex: 5, variationName: "Reverse Hyperextensions", youtubeUrl: "https://youtu.be/", isPrimary: false),

    // Exercise ID 108 → G21 (4 variações)
    ExerciseVariation(id: 361, exerciseId: 108, variationIndex: 1, variationName: "Seated Leg Curls", youtubeUrl: "https://youtu.be/81umRgyxIAU", isPrimary: true),
    ExerciseVariation(id: 362, exerciseId: 108, variationIndex: 2, variationName: "Lying Leg Curls", youtubeUrl: "https://youtu.be/aYy3alWRDmk", isPrimary: false),
    ExerciseVariation(id: 363, exerciseId: 108, variationIndex: 3, variationName: "Swiss Ball Leg Curls", youtubeUrl: "https://youtu.be/uRBpd65dbYs", isPrimary: false),
    ExerciseVariation(id: 364, exerciseId: 108, variationIndex: 4, variationName: "Dumbbell Lying Leg Curls", youtubeUrl: "https://youtu.be/Ot1MZipNLOQ", isPrimary: false),

    // Exercise ID 109 → G33 (3 variações)
    ExerciseVariation(id: 365, exerciseId: 109, variationIndex: 1, variationName: "Banded Hip Abductions", youtubeUrl: "https://youtu.be/CA0ALPgTkxw", isPrimary: true),
    ExerciseVariation(id: 366, exerciseId: 109, variationIndex: 2, variationName: "Side Lying Leg Raise", youtubeUrl: "https://youtu.be/", isPrimary: false),
    ExerciseVariation(id: 367, exerciseId: 109, variationIndex: 3, variationName: "Side Lying Hip Raise", youtubeUrl: "https://youtu.be/", isPrimary: false),

    // Exercise ID 110 → G24 (2 variações)
    ExerciseVariation(id: 368, exerciseId: 110, variationIndex: 1, variationName: "Seated Weighted Calf Raise", youtubeUrl: "https://youtu.be/2TkLMol2bCo", isPrimary: true),
    ExerciseVariation(id: 369, exerciseId: 110, variationIndex: 2, variationName: "Seated Bodyweight Calf Raise", youtubeUrl: "https://youtu.be/jW-cNnwRJ7E", isPrimary: false),
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

