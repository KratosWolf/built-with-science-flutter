import 'dart:io';
import 'package:supabase/supabase.dart';

/// Script para testar todas as queries do SupabaseService
/// Execute com: dart run scripts/test_supabase_queries.dart
void main() async {
  print('🧪 Built With Science - Supabase Queries Test');
  print('==============================================\n');

  // Initialize Supabase client
  final supabase = SupabaseClient(
    'https://gktvfldykmzhynqthbdn.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdrdHZmbGR5a216aHlucXRoYmRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU5Nzg4NzAsImV4cCI6MjA3MTU1NDg3MH0.Nd2KdEGj8hQApxmTk8nkBM81R4ROJPhwRMtgPXadGVw',
  );

  try {
    print('📊 Testing Program Queries...');
    await testProgramQueries(supabase);

    print('\n💪 Testing Exercise Queries...');  
    await testExerciseQueries(supabase);

    print('\n🎯 Testing Program Structure Queries...');
    await testProgramStructureQueries(supabase);

    print('\n🔗 Testing Day Exercise Queries...');
    await testDayExerciseQueries(supabase);

    print('\n📱 Testing Complete Program Flow...');
    await testCompleteFlow(supabase);

    print('\n🎉 All queries tested successfully!');
    print('SupabaseService is ready for Flutter integration.');

  } catch (e) {
    print('❌ Test failed: $e');
    exit(1);
  }
}

Future<void> testProgramQueries(SupabaseClient supabase) async {
  // Test getPrograms()
  final programs = await supabase
      .from('programs')
      .select()
      .order('id');
  
  print('✅ Programs: Found ${programs.length} programs');
  for (final program in programs) {
    print('  - ${program['name']} (${program['days_per_week']} days)');
  }
}

Future<void> testExerciseQueries(SupabaseClient supabase) async {
  // Test getExercises()
  final exercises = await supabase
      .from('exercises')
      .select()
      .order('name');
  
  print('✅ Exercises: Found ${exercises.length} exercises');
  
  // Test exercise variations
  if (exercises.isNotEmpty) {
    final firstExercise = exercises.first;
    final variations = await supabase
        .from('exercise_variations')
        .select()
        .eq('exercise_id', firstExercise['id'])
        .order('variation_index');
    
    print('✅ Exercise Variations: ${firstExercise['name']} has ${variations.length} variations');
    for (final variation in variations) {
      print('  - ${variation['variation_name']} (${variation['difficulty_level']})');
    }
  }
}

Future<void> testProgramStructureQueries(SupabaseClient supabase) async {
  // Test getProgramDays()
  final programs = await supabase.from('programs').select().limit(1);
  
  if (programs.isNotEmpty) {
    final programId = programs.first['id'];
    final programDays = await supabase
        .from('program_days')
        .select()
        .eq('program_id', programId)
        .order('day_index');
    
    print('✅ Program Days: Program ${programId} has ${programDays.length} days');
    for (final day in programDays) {
      print('  - Day ${day['day_index']}: ${day['day_name']}');
    }
  }
}

Future<void> testDayExerciseQueries(SupabaseClient supabase) async {
  // Test getDayExercises()
  final programDays = await supabase.from('program_days').select().limit(1);
  
  if (programDays.isNotEmpty) {
    final programDayId = programDays.first['id'];
    final dayExercises = await supabase
        .from('day_exercises')
        .select('''
          *,
          exercises (
            id,
            name
          )
        ''')
        .eq('program_day_id', programDayId)
        .order('order_pos');
    
    print('✅ Day Exercises: Day ${programDayId} has ${dayExercises.length} exercises');
    for (final dayEx in dayExercises) {
      final exercise = dayEx['exercises'];
      print('  - ${exercise['name']} (${dayEx['set_target']} sets)');
      
      // Test day exercise sets
      final sets = await supabase
          .from('day_exercise_sets')
          .select()
          .eq('day_exercise_id', dayEx['id'])
          .order('set_number');
      
      print('    Sets: ${sets.length} sets configured');
      for (final set in sets) {
        print('    - Set ${set['set_number']}: ${set['reps_target']} reps');
      }
    }
  }
}

Future<void> testCompleteFlow(SupabaseClient supabase) async {
  print('🔄 Testing complete workout flow...');
  
  // 1. Get all programs
  final programs = await supabase.from('programs').select();
  print('✅ Step 1: Retrieved ${programs.length} programs');
  
  if (programs.isEmpty) {
    throw Exception('No programs found');
  }
  
  // 2. Get program days for program with data (ID 8, 9, or 10)
  final validProgram = programs.firstWhere(
    (p) => [8, 9, 10].contains(p['id']),
    orElse: () => programs.first,
  );
  final programDays = await supabase
      .from('program_days')
      .select()
      .eq('program_id', validProgram['id'])
      .order('day_index');
  
  print('✅ Step 2: Program "${validProgram['name']}" has ${programDays.length} days');
  
  if (programDays.isEmpty) {
    throw Exception('No program days found');
  }
  
  // 3. Get exercises for first day
  final firstDay = programDays.first;
  final dayExercises = await supabase
      .from('day_exercises')
      .select('''
        *,
        exercises (
          id,
          name,
          muscle_groups,
          category
        )
      ''')
      .eq('program_day_id', firstDay['id'])
      .order('order_pos');
  
  print('✅ Step 3: Day "${firstDay['day_name']}" has ${dayExercises.length} exercises');
  
  if (dayExercises.isEmpty) {
    throw Exception('No day exercises found');
  }
  
  // 4. Get exercise variations for first exercise
  final firstExercise = dayExercises.first;
  final exerciseId = firstExercise['exercises']['id'];
  final variations = await supabase
      .from('exercise_variations')
      .select()
      .eq('exercise_id', exerciseId)
      .order('variation_index');
  
  print('✅ Step 4: Exercise "${firstExercise['exercises']['name']}" has ${variations.length} variations');
  
  // 5. Get sets configuration
  final sets = await supabase
      .from('day_exercise_sets')
      .select()
      .eq('day_exercise_id', firstExercise['id'])
      .order('set_number');
  
  print('✅ Step 5: Exercise has ${sets.length} sets configured');
  
  // 6. Test view query (if exists)
  try {
    final structureView = await supabase
        .from('program_structure')
        .select()
        .eq('program_id', validProgram['id'])
        .limit(3);
    
    print('✅ Step 6: Program structure view returned ${structureView.length} rows');
  } catch (e) {
    print('⚠️  Step 6: Program structure view not available: $e');
  }
  
  print('✅ Complete flow test successful!');
}