// Modelos de dados baseados no schema Supabase e CSVs fornecidos

class Program {
  final int id;
  final String name;

  Program({
    required this.id,
    required this.name,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class ProgramDay {
  final int id;
  final int programId;
  final int dayIndex;
  final String dayName;

  ProgramDay({
    required this.id,
    required this.programId,
    required this.dayIndex,
    required this.dayName,
  });

  factory ProgramDay.fromJson(Map<String, dynamic> json) {
    return ProgramDay(
      id: json['id'] as int,
      programId: json['program_id'] as int,
      dayIndex: json['day_index'] as int,
      dayName: json['day_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'program_id': programId,
      'day_index': dayIndex,
      'day_name': dayName,
    };
  }
}

class Exercise {
  final int id;
  final String name;

  Exercise({
    required this.id,
    required this.name,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class DayExercise {
  final int id;
  final int programDayId;
  final int exerciseId;
  final int orderPos;
  final int setTarget;

  DayExercise({
    required this.id,
    required this.programDayId,
    required this.exerciseId,
    required this.orderPos,
    required this.setTarget,
  });

  factory DayExercise.fromJson(Map<String, dynamic> json) {
    return DayExercise(
      id: json['id'] as int,
      programDayId: json['program_day_id'] as int,
      exerciseId: json['exercise_id'] as int,
      orderPos: json['order_pos'] as int,
      setTarget: json['set_target'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'program_day_id': programDayId,
      'exercise_id': exerciseId,
      'order_pos': orderPos,
      'set_target': setTarget,
    };
  }
}

class DayExerciseSet {
  final int id;
  final int dayExerciseId;
  final int setNumber;
  final String repsTarget;

  DayExerciseSet({
    required this.id,
    required this.dayExerciseId,
    required this.setNumber,
    required this.repsTarget,
  });

  factory DayExerciseSet.fromJson(Map<String, dynamic> json) {
    return DayExerciseSet(
      id: json['id'] as int,
      dayExerciseId: json['day_exercise_id'] as int,
      setNumber: json['set_number'] as int,
      repsTarget: json['reps_target'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day_exercise_id': dayExerciseId,
      'set_number': setNumber,
      'reps_target': repsTarget,
    };
  }
}

class ExerciseVariation {
  final int id;
  final int exerciseId;
  final int variationIndex;
  final String variationName;
  final String youtubeUrl;

  ExerciseVariation({
    required this.id,
    required this.exerciseId,
    required this.variationIndex,
    required this.variationName,
    required this.youtubeUrl,
  });

  factory ExerciseVariation.fromJson(Map<String, dynamic> json) {
    return ExerciseVariation(
      id: json['id'] as int,
      exerciseId: json['exercise_id'] as int,
      variationIndex: json['variation_index'] as int,
      variationName: json['variation_name'] as String,
      youtubeUrl: json['youtube_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'variation_index': variationIndex,
      'variation_name': variationName,
      'youtube_url': youtubeUrl,
    };
  }
}

class WorkoutUser {
  final String id;
  final String? email;
  final String? displayName;
  final String unit; // 'kg' | 'lb'
  final String suggestionAggressiveness; // 'conservative' | 'standard' | 'aggressive'
  final String videoPref; // 'youtube' | 'guide' | 'smart'

  WorkoutUser({
    required this.id,
    this.email,
    this.displayName,
    this.unit = 'kg',
    this.suggestionAggressiveness = 'standard',
    this.videoPref = 'smart',
  });

  factory WorkoutUser.fromJson(Map<String, dynamic> json) {
    return WorkoutUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      unit: json['unit'] as String? ?? 'kg',
      suggestionAggressiveness: json['suggestion_aggressiveness'] as String? ?? 'standard',
      videoPref: json['video_pref'] as String? ?? 'smart',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'unit': unit,
      'suggestion_aggressiveness': suggestionAggressiveness,
      'video_pref': videoPref,
    };
  }
}

class WorkoutSession {
  final int? id;
  final String userId;
  final int programId;
  final int programDayId;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final String status; // 'in_progress' | 'done'

  WorkoutSession({
    this.id,
    required this.userId,
    required this.programId,
    required this.programDayId,
    required this.startedAt,
    this.finishedAt,
    this.status = 'in_progress',
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      programId: json['program_id'] as int,
      programDayId: json['program_day_id'] as int,
      startedAt: DateTime.parse(json['started_at'] as String),
      finishedAt: json['finished_at'] != null ? DateTime.parse(json['finished_at'] as String) : null,
      status: json['status'] as String? ?? 'in_progress',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'program_id': programId,
      'program_day_id': programDayId,
      'started_at': startedAt.toIso8601String(),
      'finished_at': finishedAt?.toIso8601String(),
      'status': status,
    };
  }
}

class WorkoutSet {
  final int? id;
  final int sessionId;
  final int exerciseId;
  final int? variationIndex;
  final int setNumber;
  final double? weightKg;
  final int? reps;
  final int? restSec;
  final double? rpe;
  final String? difficulty; // 'easy' | 'ok' | 'hard'
  final DateTime createdAt;

  WorkoutSet({
    this.id,
    required this.sessionId,
    required this.exerciseId,
    this.variationIndex,
    required this.setNumber,
    this.weightKg,
    this.reps,
    this.restSec,
    this.rpe,
    this.difficulty,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      id: json['id'] as int?,
      sessionId: json['session_id'] as int,
      exerciseId: json['exercise_id'] as int,
      variationIndex: json['variation_index'] as int?,
      setNumber: json['set_number'] as int,
      weightKg: json['weight_kg'] != null ? (json['weight_kg'] as num).toDouble() : null,
      reps: json['reps'] as int?,
      restSec: json['rest_sec'] as int?,
      rpe: json['rpe'] != null ? (json['rpe'] as num).toDouble() : null,
      difficulty: json['difficulty'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'exercise_id': exerciseId,
      'variation_index': variationIndex,
      'set_number': setNumber,
      'weight_kg': weightKg,
      'reps': reps,
      'rest_sec': restSec,
      'rpe': rpe,
      'difficulty': difficulty,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class LastSetCache {
  final String userId;
  final int exerciseId;
  final int? variationIndex;
  final double? weightKg;
  final int? reps;
  final int? restSec;
  final DateTime updatedAt;

  LastSetCache({
    required this.userId,
    required this.exerciseId,
    this.variationIndex,
    this.weightKg,
    this.reps,
    this.restSec,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory LastSetCache.fromJson(Map<String, dynamic> json) {
    return LastSetCache(
      userId: json['user_id'] as String,
      exerciseId: json['exercise_id'] as int,
      variationIndex: json['variation_index'] as int?,
      weightKg: json['weight_kg'] != null ? (json['weight_kg'] as num).toDouble() : null,
      reps: json['reps'] as int?,
      restSec: json['rest_sec'] as int?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'exercise_id': exerciseId,
      'variation_index': variationIndex,
      'weight_kg': weightKg,
      'reps': reps,
      'rest_sec': restSec,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Classe para sugestão de progressão
class ProgressionSuggestion {
  final double suggestedWeight;
  final String rationale;
  final double percentageChange;
  final double? previousWeight;
  final int? previousReps;
  final String targetReps;

  ProgressionSuggestion({
    required this.suggestedWeight,
    required this.rationale,
    required this.percentageChange,
    this.previousWeight,
    this.previousReps,
    required this.targetReps,
  });
}

// Enums para melhor type safety
enum Unit { kg, lb }
enum SuggestionAggressiveness { conservative, standard, aggressive }
enum VideoPref { youtube, guide, smart }
enum WorkoutStatus { inProgress, done }
enum Difficulty { easy, ok, hard }

