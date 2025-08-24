import 'dart:io';
import 'dart:convert';
import 'package:supabase/supabase.dart';

/// Script para setup inicial do banco de dados Supabase
/// Versão Dart pura (sem Flutter dependencies)
/// Execute com: dart run scripts/setup_database_dart.dart
void main() async {
  print('🚀 Built With Science - Database Setup');
  print('=====================================\n');

  // Initialize Supabase client
  final supabase = SupabaseClient(
    'https://gktvfldykmzhynqthbdn.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdrdHZmbGR5a216aHlucXRoYmRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU5Nzg4NzAsImV4cCI6MjA3MTU1NDg3MH0.Nd2KdEGj8hQApxmTk8nkBM81R4ROJPhwRMtgPXadGVw',
  );

  try {
    print('📊 Step 1: Testing connection...');
    await testConnection(supabase);

    print('\n🏗️  Step 2: Creating sample programs...');
    await createSamplePrograms(supabase);

    print('\n💪 Step 3: Creating exercises...');
    await createExercises(supabase);

    print('\n🔗 Step 4: Linking exercises to programs...');
    await linkExercisesToPrograms(supabase);

    print('\n✅ Step 5: Creating test user profile...');
    await createTestUserProfile(supabase);

    print('\n🎉 Database setup completed successfully!');
    print('Ready to test the full workout flow.');

  } catch (e) {
    print('❌ Error during setup: $e');
    exit(1);
  }
}

Future<void> testConnection(SupabaseClient supabase) async {
  try {
    final response = await supabase.from('programs').select('*').count();
    print('✅ Connection successful. Current programs count: ${response.count}');
  } catch (e) {
    throw Exception('Connection failed: $e');
  }
}

Future<void> createSamplePrograms(SupabaseClient supabase) async {
  final programs = [
    {
      'name': '3-Day Science-Based Full Body',
      'description': 'Optimal full-body routine for maximum muscle growth and strength. Perfect for beginners to intermediates.',
      'days_per_week': 3,
    },
    {
      'name': '4-Day Upper/Lower Split',
      'description': 'Balanced upper and lower body split for intermediate to advanced trainees.',
      'days_per_week': 4,
    },
    {
      'name': '5-Day Push/Pull/Legs',
      'description': 'High-frequency training for advanced lifters seeking maximum muscle development.',
      'days_per_week': 5,
    },
  ];

  for (final program in programs) {
    try {
      final result = await supabase
          .from('programs')
          .upsert(program)
          .select()
          .single();
      
      print('✅ Created program: ${program['name']} (ID: ${result['id']})');
      
      // Create program days
      await createProgramDays(supabase, result['id'], program['days_per_week'] as int);
      
    } catch (e) {
      print('⚠️  Program ${program['name']} might already exist: $e');
    }
  }
}

Future<void> createProgramDays(SupabaseClient supabase, int programId, int daysPerWeek) async {
  List<Map<String, dynamic>> programDays;

  switch (daysPerWeek) {
    case 3:
      programDays = [
        {'program_id': programId, 'day_index': 1, 'day_name': 'Full Body A'},
        {'program_id': programId, 'day_index': 2, 'day_name': 'Full Body B'},
        {'program_id': programId, 'day_index': 3, 'day_name': 'Full Body C'},
      ];
      break;
    case 4:
      programDays = [
        {'program_id': programId, 'day_index': 1, 'day_name': 'Upper Body'},
        {'program_id': programId, 'day_index': 2, 'day_name': 'Lower Body'},
        {'program_id': programId, 'day_index': 3, 'day_name': 'Upper Body'},
        {'program_id': programId, 'day_index': 4, 'day_name': 'Lower Body'},
      ];
      break;
    case 5:
      programDays = [
        {'program_id': programId, 'day_index': 1, 'day_name': 'Push'},
        {'program_id': programId, 'day_index': 2, 'day_name': 'Pull'},
        {'program_id': programId, 'day_index': 3, 'day_name': 'Legs'},
        {'program_id': programId, 'day_index': 4, 'day_name': 'Push'},
        {'program_id': programId, 'day_index': 5, 'day_name': 'Pull'},
      ];
      break;
    default:
      throw Exception('Unsupported days per week: $daysPerWeek');
  }

  for (final day in programDays) {
    try {
      await supabase.from('program_days').upsert(day);
      print('  ✅ Created day: ${day['day_name']}');
    } catch (e) {
      print('  ⚠️  Day ${day['day_name']} might already exist');
    }
  }
}

Future<void> createExercises(SupabaseClient supabase) async {
  final exercises = [
    // Compound movements
    {
      'name': 'Barbell Back Squat',
      'muscle_groups': ['quadriceps', 'glutes', 'hamstrings', 'core'],
      'category': 'compound',
      'equipment': 'barbell',
    },
    {
      'name': 'Deadlift',
      'muscle_groups': ['hamstrings', 'glutes', 'erector_spinae', 'traps'],
      'category': 'compound',
      'equipment': 'barbell',
    },
    {
      'name': 'Bench Press',
      'muscle_groups': ['chest', 'triceps', 'anterior_deltoids'],
      'category': 'compound',
      'equipment': 'barbell',
    },
    {
      'name': 'Pull-ups',
      'muscle_groups': ['latissimus_dorsi', 'biceps', 'rear_deltoids'],
      'category': 'compound',
      'equipment': 'bodyweight',
    },
    {
      'name': 'Overhead Press',
      'muscle_groups': ['shoulders', 'triceps', 'core'],
      'category': 'compound',
      'equipment': 'barbell',
    },
    // Isolation movements
    {
      'name': 'Dumbbell Bicep Curls',
      'muscle_groups': ['biceps'],
      'category': 'isolation',
      'equipment': 'dumbbells',
    },
    {
      'name': 'Tricep Dips',
      'muscle_groups': ['triceps'],
      'category': 'isolation',
      'equipment': 'bodyweight',
    },
    {
      'name': 'Lateral Raises',
      'muscle_groups': ['lateral_deltoids'],
      'category': 'isolation',
      'equipment': 'dumbbells',
    },
    {
      'name': 'Calf Raises',
      'muscle_groups': ['calves'],
      'category': 'isolation',
      'equipment': 'bodyweight',
    },
    {
      'name': 'Plank',
      'muscle_groups': ['core', 'shoulders'],
      'category': 'isolation',
      'equipment': 'bodyweight',
    },
  ];

  for (final exercise in exercises) {
    try {
      final result = await supabase
          .from('exercises')
          .upsert(exercise)
          .select()
          .single();
      
      print('✅ Created exercise: ${exercise['name']} (ID: ${result['id']})');
      
      // Create variations for each exercise
      await createExerciseVariations(supabase, result['id'], exercise['name'] as String);
      
    } catch (e) {
      print('⚠️  Exercise ${exercise['name']} might already exist: $e');
    }
  }
}

Future<void> createExerciseVariations(SupabaseClient supabase, int exerciseId, String exerciseName) async {
  final variations = _getVariationsForExercise(exerciseName);
  
  for (int i = 0; i < variations.length; i++) {
    final variation = variations[i];
    try {
      await supabase.from('exercise_variations').upsert({
        'exercise_id': exerciseId,
        'variation_index': i + 1,
        'variation_name': variation['name'],
        'youtube_url': variation['youtube_url'],
        'is_primary': i == 0, // First variation is primary
        'difficulty_level': variation['difficulty'],
      });
      print('  ✅ Created variation: ${variation['name']}');
    } catch (e) {
      print('  ⚠️  Variation might already exist: ${variation['name']}');
    }
  }
}

List<Map<String, String>> _getVariationsForExercise(String exerciseName) {
  switch (exerciseName) {
    case 'Barbell Back Squat':
      return [
        {
          'name': 'High Bar Back Squat',
          'youtube_url': 'https://www.youtube.com/watch?v=ultWZbUMPL8',
          'difficulty': 'intermediate'
        },
        {
          'name': 'Low Bar Back Squat',
          'youtube_url': 'https://www.youtube.com/watch?v=vmNPOjaGrVE',
          'difficulty': 'advanced'
        },
        {
          'name': 'Goblet Squat',
          'youtube_url': 'https://www.youtube.com/watch?v=MeIiIdhvXT4',
          'difficulty': 'beginner'
        },
      ];
    case 'Deadlift':
      return [
        {
          'name': 'Conventional Deadlift',
          'youtube_url': 'https://www.youtube.com/watch?v=op9kVnSso6Q',
          'difficulty': 'intermediate'
        },
        {
          'name': 'Sumo Deadlift',
          'youtube_url': 'https://www.youtube.com/watch?v=6ucdKlZkZCU',
          'difficulty': 'intermediate'
        },
        {
          'name': 'Romanian Deadlift',
          'youtube_url': 'https://www.youtube.com/watch?v=jEy_czb3RKA',
          'difficulty': 'beginner'
        },
      ];
    case 'Bench Press':
      return [
        {
          'name': 'Flat Barbell Bench Press',
          'youtube_url': 'https://www.youtube.com/watch?v=gRVjAtPip0Y',
          'difficulty': 'intermediate'
        },
        {
          'name': 'Incline Barbell Bench Press',
          'youtube_url': 'https://www.youtube.com/watch?v=DbFgADa2PL8',
          'difficulty': 'intermediate'
        },
        {
          'name': 'Dumbbell Bench Press',
          'youtube_url': 'https://www.youtube.com/watch?v=QsYre__-aro',
          'difficulty': 'beginner'
        },
      ];
    case 'Pull-ups':
      return [
        {
          'name': 'Standard Pull-up',
          'youtube_url': 'https://www.youtube.com/watch?v=eGo4IYlbE5g',
          'difficulty': 'intermediate'
        },
        {
          'name': 'Chin-ups',
          'youtube_url': 'https://www.youtube.com/watch?v=jfzjti-f2ME',
          'difficulty': 'beginner'
        },
        {
          'name': 'Wide Grip Pull-ups',
          'youtube_url': 'https://www.youtube.com/watch?v=iU3LfJWNBgA',
          'difficulty': 'advanced'
        },
      ];
    default:
      return [
        {
          'name': exerciseName,
          'youtube_url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', // Placeholder
          'difficulty': 'intermediate'
        },
      ];
  }
}

Future<void> linkExercisesToPrograms(SupabaseClient supabase) async {
  // Get all program days
  final programDays = await supabase
      .from('program_days')
      .select('id, day_name, program_id')
      .order('program_id, day_index');

  final exercises = await supabase
      .from('exercises')
      .select('id, name');

  for (final day in programDays) {
    final dayExercises = _getExercisesForDay(day['day_name'] as String, exercises);
    
    for (int i = 0; i < dayExercises.length; i++) {
      final exercise = dayExercises[i];
      try {
        // Create day exercise
        final dayExercise = await supabase.from('day_exercises').upsert({
          'program_day_id': day['id'],
          'exercise_id': exercise['exercise_id'],
          'order_pos': i + 1,
          'set_target': exercise['sets'],
          'rest_sec': exercise['rest_sec'] ?? 120,
        }).select().single();

        // Create sets for this exercise
        for (int setNum = 1; setNum <= exercise['sets']; setNum++) {
          await supabase.from('day_exercise_sets').upsert({
            'day_exercise_id': dayExercise['id'],
            'set_number': setNum,
            'reps_target': exercise['reps_target'],
          });
        }

        print('✅ Added ${exercise['name']} to ${day['day_name']}');
      } catch (e) {
        print('⚠️  Exercise might already be linked: ${exercise['name']} to ${day['day_name']}');
      }
    }
  }
}

List<Map<String, dynamic>> _getExercisesForDay(String dayName, List<dynamic> availableExercises) {
  final exerciseMap = <String, int>{};
  for (final ex in availableExercises) {
    exerciseMap[ex['name']] = ex['id'];
  }

  switch (dayName) {
    case 'Full Body A':
    case 'Full Body B':
    case 'Full Body C':
      return [
        {'exercise_id': exerciseMap['Barbell Back Squat']!, 'name': 'Barbell Back Squat', 'sets': 3, 'reps_target': '8-10', 'rest_sec': 180},
        {'exercise_id': exerciseMap['Bench Press']!, 'name': 'Bench Press', 'sets': 3, 'reps_target': '8-10', 'rest_sec': 180},
        {'exercise_id': exerciseMap['Pull-ups']!, 'name': 'Pull-ups', 'sets': 3, 'reps_target': '6-12', 'rest_sec': 120},
        {'exercise_id': exerciseMap['Overhead Press']!, 'name': 'Overhead Press', 'sets': 3, 'reps_target': '8-12', 'rest_sec': 120},
        {'exercise_id': exerciseMap['Dumbbell Bicep Curls']!, 'name': 'Dumbbell Bicep Curls', 'sets': 3, 'reps_target': '12-15', 'rest_sec': 90},
      ];
    case 'Upper Body':
      return [
        {'exercise_id': exerciseMap['Bench Press']!, 'name': 'Bench Press', 'sets': 4, 'reps_target': '6-8', 'rest_sec': 180},
        {'exercise_id': exerciseMap['Pull-ups']!, 'name': 'Pull-ups', 'sets': 4, 'reps_target': '8-12', 'rest_sec': 120},
        {'exercise_id': exerciseMap['Overhead Press']!, 'name': 'Overhead Press', 'sets': 3, 'reps_target': '8-12', 'rest_sec': 120},
        {'exercise_id': exerciseMap['Dumbbell Bicep Curls']!, 'name': 'Dumbbell Bicep Curls', 'sets': 3, 'reps_target': '12-15', 'rest_sec': 90},
        {'exercise_id': exerciseMap['Tricep Dips']!, 'name': 'Tricep Dips', 'sets': 3, 'reps_target': '10-15', 'rest_sec': 90},
      ];
    case 'Lower Body':
      return [
        {'exercise_id': exerciseMap['Barbell Back Squat']!, 'name': 'Barbell Back Squat', 'sets': 4, 'reps_target': '6-8', 'rest_sec': 180},
        {'exercise_id': exerciseMap['Deadlift']!, 'name': 'Deadlift', 'sets': 3, 'reps_target': '5-8', 'rest_sec': 180},
        {'exercise_id': exerciseMap['Calf Raises']!, 'name': 'Calf Raises', 'sets': 4, 'reps_target': '15-20', 'rest_sec': 60},
        {'exercise_id': exerciseMap['Plank']!, 'name': 'Plank', 'sets': 3, 'reps_target': '30-60s', 'rest_sec': 60},
      ];
    case 'Push':
      return [
        {'exercise_id': exerciseMap['Bench Press']!, 'name': 'Bench Press', 'sets': 4, 'reps_target': '6-8', 'rest_sec': 180},
        {'exercise_id': exerciseMap['Overhead Press']!, 'name': 'Overhead Press', 'sets': 4, 'reps_target': '8-12', 'rest_sec': 120},
        {'exercise_id': exerciseMap['Tricep Dips']!, 'name': 'Tricep Dips', 'sets': 3, 'reps_target': '10-15', 'rest_sec': 90},
        {'exercise_id': exerciseMap['Lateral Raises']!, 'name': 'Lateral Raises', 'sets': 3, 'reps_target': '12-15', 'rest_sec': 90},
      ];
    case 'Pull':
      return [
        {'exercise_id': exerciseMap['Pull-ups']!, 'name': 'Pull-ups', 'sets': 4, 'reps_target': '6-12', 'rest_sec': 120},
        {'exercise_id': exerciseMap['Deadlift']!, 'name': 'Deadlift', 'sets': 3, 'reps_target': '5-8', 'rest_sec': 180},
        {'exercise_id': exerciseMap['Dumbbell Bicep Curls']!, 'name': 'Dumbbell Bicep Curls', 'sets': 4, 'reps_target': '12-15', 'rest_sec': 90},
      ];
    case 'Legs':
      return [
        {'exercise_id': exerciseMap['Barbell Back Squat']!, 'name': 'Barbell Back Squat', 'sets': 4, 'reps_target': '6-10', 'rest_sec': 180},
        {'exercise_id': exerciseMap['Deadlift']!, 'name': 'Deadlift', 'sets': 4, 'reps_target': '6-10', 'rest_sec': 180},
        {'exercise_id': exerciseMap['Calf Raises']!, 'name': 'Calf Raises', 'sets': 4, 'reps_target': '15-20', 'rest_sec': 60},
        {'exercise_id': exerciseMap['Plank']!, 'name': 'Plank', 'sets': 3, 'reps_target': '30-60s', 'rest_sec': 60},
      ];
    default:
      return [];
  }
}

Future<void> createTestUserProfile(SupabaseClient supabase) async {
  // Note: This would normally be done through auth, but for testing we can simulate
  try {
    // First sign in anonymously to get a user
    final authResponse = await supabase.auth.signInAnonymously();
    
    if (authResponse.user != null) {
      // Create user profile
      final userProfile = {
        'id': authResponse.user!.id,
        'email': 'test@builtwithscience.com',
        'display_name': 'Test User',
        'unit': 'kg',
        'suggestion_aggressiveness': 'standard',
        'video_pref': 'smart',
        'onboarding_completed': true,
      };

      await supabase.from('workout_users').upsert(userProfile);
      print('✅ Created test user profile: ${userProfile['display_name']}');
    }
  } catch (e) {
    print('⚠️  User profile creation: $e');
    // This is okay - user might already exist or auth might be different
  }
}