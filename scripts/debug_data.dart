import 'dart:io';
import 'package:supabase/supabase.dart';

/// Script para debugar dados do Supabase
/// Execute com: dart run scripts/debug_data.dart
void main() async {
  print('🔍 Built With Science - Debug Data');
  print('===================================\n');

  // Initialize Supabase client
  final supabase = SupabaseClient(
    'https://gktvfldykmzhynqthbdn.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdrdHZmbGR5a216aHlucXRoYmRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU5Nzg4NzAsImV4cCI6MjA3MTU1NDg3MH0.Nd2KdEGj8hQApxmTk8nkBM81R4ROJPhwRMtgPXadGVw',
  );

  try {
    await debugPrograms(supabase);
    await debugProgramDays(supabase);
    await debugExercises(supabase);
    await debugDayExercises(supabase);

  } catch (e) {
    print('❌ Debug failed: $e');
    exit(1);
  }
}

Future<void> debugPrograms(SupabaseClient supabase) async {
  print('📊 DEBUG: Programs');
  final programs = await supabase.from('programs').select().order('id');
  
  for (final program in programs) {
    print('Program ${program['id']}: ${program['name']} (${program['days_per_week']} days)');
  }
  print('');
}

Future<void> debugProgramDays(SupabaseClient supabase) async {
  print('📅 DEBUG: Program Days');
  final programDays = await supabase.from('program_days').select().order('program_id, day_index');
  
  int? currentProgramId;
  for (final day in programDays) {
    if (day['program_id'] != currentProgramId) {
      currentProgramId = day['program_id'];
      print('Program ${currentProgramId}:');
    }
    print('  - Day ${day['day_index']}: ${day['day_name']} (ID: ${day['id']})');
  }
  print('');
}

Future<void> debugExercises(SupabaseClient supabase) async {
  print('💪 DEBUG: Exercises');
  final exercises = await supabase.from('exercises').select().order('id');
  
  for (final exercise in exercises) {
    print('Exercise ${exercise['id']}: ${exercise['name']}');
    
    final variations = await supabase
        .from('exercise_variations')
        .select()
        .eq('exercise_id', exercise['id'])
        .order('variation_index');
    
    for (final variation in variations) {
      print('  - Variation ${variation['variation_index']}: ${variation['variation_name']}');
    }
  }
  print('');
}

Future<void> debugDayExercises(SupabaseClient supabase) async {
  print('🔗 DEBUG: Day Exercises');
  final dayExercises = await supabase
      .from('day_exercises')
      .select('''
        *,
        exercises (name),
        program_days (day_name, program_id)
      ''')
      .order('program_day_id, order_pos');
  
  int? currentDayId;
  for (final dayEx in dayExercises) {
    if (dayEx['program_day_id'] != currentDayId) {
      currentDayId = dayEx['program_day_id'];
      final dayInfo = dayEx['program_days'];
      print('Day ${currentDayId} (${dayInfo['day_name']}, Program ${dayInfo['program_id']}):');
    }
    
    final exerciseInfo = dayEx['exercises'];
    print('  - ${exerciseInfo['name']} (${dayEx['set_target']} sets)');
  }
  print('');
}