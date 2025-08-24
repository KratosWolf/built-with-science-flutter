// Exercícios baseados no CSV do usuário - Programa 3 dias Built With Science
// Sistema inteligente com cache de último treino e sugestões automáticas

import '../models/workout_models.dart';

class UserExerciseData {
  // Exercícios do programa 3 dias do usuário
  static final List<Exercise> userExercises = [
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

  static final List<ExerciseVariation> userExerciseVariations = [
    // BARBELL BENCH PRESS (id: 1) - 6 variações
    ExerciseVariation(id: 1, exerciseId: 1, variationIndex: 1, variationName: "Barbell Bench Press", youtubeUrl: "https://youtu.be/pCGVSBk0bIQ", isPrimary: true),
    ExerciseVariation(id: 2, exerciseId: 1, variationIndex: 2, variationName: "Flat Dumbbell Press", youtubeUrl: "https://youtu.be/g14dhC5KYBM"),
    ExerciseVariation(id: 3, exerciseId: 1, variationIndex: 3, variationName: "Flat Machine Chest Press", youtubeUrl: "https://youtu.be/sO8lFa9CidE"),
    ExerciseVariation(id: 4, exerciseId: 1, variationIndex: 4, variationName: "Flat Smith Machine Chest Press", youtubeUrl: "https://youtu.be/3Z3C44SXSQE"),
    ExerciseVariation(id: 5, exerciseId: 1, variationIndex: 5, variationName: "Seated Flat Cable Press", youtubeUrl: "https://youtu.be/hPpNTAEDnxM"),
    ExerciseVariation(id: 6, exerciseId: 1, variationIndex: 6, variationName: "Neutral Grip DB Press*", youtubeUrl: "https://youtu.be/N-kUwH1uf9c"),
    
    // FLAT DUMBBELL PRESS (id: 2) - 4 variações
    ExerciseVariation(id: 33, exerciseId: 2, variationIndex: 1, variationName: "Flat Dumbbell Press", youtubeUrl: "https://youtu.be/VmB1G1K7v94", isPrimary: true),
    ExerciseVariation(id: 34, exerciseId: 2, variationIndex: 2, variationName: "Flat Machine Chest Press", youtubeUrl: "https://youtu.be/xUm0BiZCWlQ"),
    ExerciseVariation(id: 35, exerciseId: 2, variationIndex: 3, variationName: "Flat Smith Machine Chest Press", youtubeUrl: "https://youtu.be/rT7DgCr-3pg"),
    ExerciseVariation(id: 36, exerciseId: 2, variationIndex: 4, variationName: "Seated Flat Cable Press", youtubeUrl: "https://youtu.be/5j5KlnDtSmY"),
    
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

  // Programa 3 dias - Treino A (Full Body A)
  static final List<DayExerciseData> day1Exercises = [
    DayExerciseData(exerciseId: 1, sets: 3, repsTarget: "8-10"), // Barbell Bench Press (tem 6 variações)
    DayExerciseData(exerciseId: 7, sets: 3, repsTarget: "8-10"), // Barbell Romanian Deadlift (tem 3 variações)
    DayExerciseData(exerciseId: 10, sets: 3, repsTarget: "6-12"), // (Weighted) Pull-Ups (tem 7 variações)
    DayExerciseData(exerciseId: 17, sets: 3, repsTarget: "8-10 per leg"), // Walking Lunges (tem 5 variações)
    
    // Superset A
    DayExerciseData(exerciseId: 22, sets: 3, repsTarget: "10-15", isSuperset: true, supersetLabel: "A", supersetExerciseLabel: "A1"), // Standing Mid-Chest Cable Fly (tem 5 variações)
    DayExerciseData(exerciseId: 27, sets: 3, repsTarget: "15-20", isSuperset: true, supersetLabel: "A", supersetExerciseLabel: "A2"), // Dumbbell Lateral Raise (tem 5 variações)
    
    // Superset B  
    DayExerciseData(exerciseId: 32, sets: 3, repsTarget: "10-15", isSuperset: true, supersetLabel: "B", supersetExerciseLabel: "B1"), // Single Leg Weighted Calf Raise (tem 4 variações)
    DayExerciseData(exerciseId: 36, sets: 3, repsTarget: "10", isSuperset: true, supersetLabel: "B", supersetExerciseLabel: "B2"), // Standing Face Pulls (tem 4 variações)
  ];

  // Função para obter exercício por ID
  static Exercise? getUserExerciseById(int id) {
    try {
      return userExercises.firstWhere((ex) => ex.id == id);
    } catch (e) {
      return null;
    }
  }

  // Função para obter variações de um exercício (sempre primeira é padrão)
  static List<ExerciseVariation> getUserExerciseVariations(int exerciseId) {
    final variations = userExerciseVariations.where((ev) => ev.exerciseId == exerciseId).toList();
    // Garantir que a primeira variação (is_primary) vem primeiro
    variations.sort((a, b) {
      if (a.isPrimary && !b.isPrimary) return -1;
      if (!a.isPrimary && b.isPrimary) return 1;
      return a.variationIndex.compareTo(b.variationIndex);
    });
    return variations;
  }

  // Função para obter URL do exercício selecionado
  static String getExerciseVideoUrl(int exerciseId, {int variationIndex = 1}) {
    try {
      final variation = userExerciseVariations.firstWhere(
        (ev) => ev.exerciseId == exerciseId && ev.variationIndex == variationIndex
      );
      return variation.youtubeUrl;
    } catch (e) {
      return '';
    }
  }

  // Sistema inteligente de sugestão de progressão
  static ProgressionSuggestion getProgressionSuggestion(
    double lastWeight,
    int lastReps,
    String difficulty,
    String targetRepsRange
  ) {
    final repsRange = targetRepsRange.split('-').map((r) => int.tryParse(r.replaceAll(RegExp(r'[^\d]'), '')) ?? 0).toList();
    final minReps = repsRange.isNotEmpty ? repsRange[0] : 8;
    final maxReps = repsRange.length > 1 ? repsRange[1] : minReps + 2;
    
    if (difficulty == 'easy') {
      if (lastReps < maxReps) {
        // Aumentar 1 rep até chegar no máximo
        return ProgressionSuggestion(
          type: 'reps',
          current: ProgressionData(weight: lastWeight, reps: lastReps),
          suggested: ProgressionData(weight: lastWeight, reps: lastReps + 1),
          reason: 'Última série foi fácil. Aumente para ${lastReps + 1} reps.',
        );
      } else {
        // Já está no máximo de reps, aumentar peso e voltar pro mínimo
        final suggestedWeight = lastWeight + (lastWeight * 0.025); // 2.5% de aumento
        final roundedWeight = (suggestedWeight * 2).round() / 2;
        return ProgressionSuggestion(
          type: 'weight',
          current: ProgressionData(weight: lastWeight, reps: lastReps),
          suggested: ProgressionData(weight: roundedWeight, reps: minReps),
          reason: 'Máximo de reps atingido com facilidade. Aumente peso para ${roundedWeight}kg e volte para $minReps reps.',
        );
      }
    } else if (difficulty == 'medium') {
      // Manter peso e reps, está no ponto ideal
      return ProgressionSuggestion(
        type: 'both',
        current: ProgressionData(weight: lastWeight, reps: lastReps),
        suggested: ProgressionData(weight: lastWeight, reps: lastReps),
        reason: 'Dificuldade ideal. Mantenha o mesmo peso e reps.',
      );
    } else if (difficulty == 'hard') {
      if (lastReps > minReps) {
        // Diminuir 1 rep para facilitar
        return ProgressionSuggestion(
          type: 'reps',
          current: ProgressionData(weight: lastWeight, reps: lastReps),
          suggested: ProgressionData(weight: lastWeight, reps: lastReps - 1),
          reason: 'Última série foi muito difícil. Diminua para ${lastReps - 1} reps.',
        );
      } else {
        // Diminuir peso em 5%
        final suggestedWeight = lastWeight - (lastWeight * 0.05);
        final roundedWeight = (suggestedWeight * 2).round() / 2;
        return ProgressionSuggestion(
          type: 'weight',
          current: ProgressionData(weight: lastWeight, reps: lastReps),
          suggested: ProgressionData(weight: roundedWeight, reps: lastReps),
          reason: 'Muito difícil no mínimo de reps. Diminua peso para ${roundedWeight}kg.',
        );
      }
    } else if (difficulty == 'max_effort') {
      // Diminuir levemente o peso ou reps
      if (lastReps > minReps) {
        return ProgressionSuggestion(
          type: 'reps',
          current: ProgressionData(weight: lastWeight, reps: lastReps),
          suggested: ProgressionData(weight: lastWeight, reps: lastReps - 1),
          reason: 'Máximo esforço. Diminua para ${lastReps - 1} reps para manter qualidade.',
        );
      } else {
        final suggestedWeight = lastWeight - (lastWeight * 0.025);
        final roundedWeight = (suggestedWeight * 2).round() / 2;
        return ProgressionSuggestion(
          type: 'weight',
          current: ProgressionData(weight: lastWeight, reps: lastReps),
          suggested: ProgressionData(weight: roundedWeight, reps: lastReps),
          reason: 'Máximo esforço no mínimo de reps. Diminua peso para ${roundedWeight}kg.',
        );
      }
    } else if (difficulty == 'failed') {
      // Diminuir peso significativamente
      final suggestedWeight = lastWeight - (lastWeight * 0.10); // 10% de redução
      final roundedWeight = (suggestedWeight * 2).round() / 2;
      return ProgressionSuggestion(
        type: 'weight',
        current: ProgressionData(weight: lastWeight, reps: lastReps),
        suggested: ProgressionData(weight: roundedWeight, reps: minReps),
        reason: 'Falha na execução. Diminua peso para ${roundedWeight}kg e volte para $minReps reps.',
      );
    }

    // Default case
    return ProgressionSuggestion(
      type: 'both',
      current: ProgressionData(weight: lastWeight, reps: lastReps),
      suggested: ProgressionData(weight: lastWeight, reps: lastReps),
      reason: 'Mantenha o mesmo peso e reps.',
    );
  }

  // Labels para dificuldades
  static const Map<String, String> difficultyLabels = {
    'easy': '😎 Easy - I could have done 3 more reps',
    'medium': '😊 Medium - I could have done 2 more reps', 
    'hard': '😅 Hard - I could have done 1 more rep',
    'max_effort': '🔥 Max effort - I could not have done any more reps',
    'failed': '💥 Failed - I tried to do another rep but couldn\'t'
  };
}