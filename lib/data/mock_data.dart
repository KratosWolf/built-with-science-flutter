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

