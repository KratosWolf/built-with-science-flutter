import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/workout_models.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  SupabaseService._();
  
  // Supabase client
  SupabaseClient get client => Supabase.instance.client;
  
  // Auth state
  User? get currentUser => client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  
  // Google Sign-in instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  
  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://myqxlznxgmkfpgvwzsed.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im15cXhsem54Z21rZnBndnd6c2VkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjQ0MzExNTgsImV4cCI6MjA0MDAwNzE1OH0.eZlOKfJQfMLfJp2kFaWPj-9dQAJgfI-VhF0Y6n1WQsk',
    );
  }
  
  /// Sign in with Google
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      print('🔐 Iniciando Google Sign-in...');
      
      // Trigger Google Sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ Google Sign-in cancelado pelo usuário');
        return null;
      }
      
      print('✅ Google user: ${googleUser.email}');
      
      // Get Google Auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('❌ Erro: tokens Google não encontrados');
        return null;
      }
      
      print('🔑 Tokens Google obtidos, fazendo login no Supabase...');
      
      // Sign in to Supabase with Google credentials
      final AuthResponse response = await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );
      
      if (response.user != null) {
        print('✅ Login Supabase realizado: ${response.user!.email}');
        
        // Create user profile if doesn't exist
        await _createUserProfileIfNeeded(response.user!);
      }
      
      return response;
      
    } catch (error) {
      print('❌ Erro no Google Sign-in: $error');
      return null;
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    try {
      print('🔐 Fazendo logout...');
      
      // Sign out from Google
      await _googleSignIn.signOut();
      
      // Sign out from Supabase
      await client.auth.signOut();
      
      print('✅ Logout realizado');
    } catch (error) {
      print('❌ Erro no logout: $error');
    }
  }
  
  /// Create user profile in database if needed
  Future<void> _createUserProfileIfNeeded(User user) async {
    try {
      // Check if profile already exists
      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      if (response == null) {
        // Create new profile
        await client.from('user_profiles').insert({
          'id': user.id,
          'email': user.email,
          'full_name': user.userMetadata?['full_name'] ?? user.email?.split('@')[0],
          'avatar_url': user.userMetadata?['avatar_url'],
          'created_at': DateTime.now().toIso8601String(),
        });
        
        print('✅ Perfil de usuário criado');
      } else {
        print('📊 Perfil de usuário já existe');
      }
    } catch (error) {
      print('❌ Erro ao criar perfil: $error');
    }
  }
  
  /// Save workout set to cloud
  Future<bool> saveWorkoutSet(WorkoutSet workoutSet, int programId, int dayId) async {
    if (!isLoggedIn) {
      print('❌ Usuário não logado - salvando apenas localmente');
      return false;
    }
    
    try {
      print('☁️ Salvando set na nuvem...');
      
      await client.from('workout_sessions').upsert({
        'user_id': currentUser!.id,
        'program_id': programId,
        'day_id': dayId,
        'exercise_id': workoutSet.exerciseId,
        'set_number': workoutSet.setNumber,
        'weight_kg': workoutSet.weightKg,
        'reps': workoutSet.reps,
        'difficulty': workoutSet.difficulty,
        'completed_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,program_id,day_id,exercise_id,set_number');
      
      print('✅ Set salvo na nuvem');
      return true;
      
    } catch (error) {
      print('❌ Erro ao salvar na nuvem: $error');
      return false;
    }
  }
  
  /// Load user's last workout data from cloud
  Future<Map<int, List<WorkoutSet>>> loadLastWorkoutData(int programId, int dayId) async {
    if (!isLoggedIn) {
      print('❌ Usuário não logado - usando apenas cache local');
      return {};
    }
    
    try {
      print('☁️ Carregando dados do último treino da nuvem...');
      
      final response = await client
          .from('workout_sessions')
          .select()
          .eq('user_id', currentUser!.id)
          .eq('program_id', programId)
          .eq('day_id', dayId)
          .order('completed_at', ascending: false);
      
      Map<int, List<WorkoutSet>> workoutData = {};
      
      for (final row in response) {
        final exerciseId = row['exercise_id'] as int;
        final workoutSet = WorkoutSet(
          sessionId: row['id'] ?? 1,
          exerciseId: exerciseId,
          setNumber: row['set_number'] as int,
          weightKg: (row['weight_kg'] as num?)?.toDouble(),
          reps: row['reps'] as int?,
          difficulty: row['difficulty'] as String?,
        );
        
        if (!workoutData.containsKey(exerciseId)) {
          workoutData[exerciseId] = [];
        }
        workoutData[exerciseId]!.add(workoutSet);
      }
      
      print('✅ Dados carregados da nuvem: ${workoutData.length} exercícios');
      return workoutData;
      
    } catch (error) {
      print('❌ Erro ao carregar da nuvem: $error');
      return {};
    }
  }
  
  /// Get user's workout statistics
  Future<Map<String, dynamic>> getUserStats() async {
    if (!isLoggedIn) return {};
    
    try {
      final response = await client
          .from('workout_sessions')
          .select()
          .eq('user_id', currentUser!.id);
      
      final totalSets = response.length;
      final exerciseIds = response.map((r) => r['exercise_id']).toSet();
      final totalExercises = exerciseIds.length;
      
      // Calculate total weight lifted
      double totalWeight = 0;
      for (final row in response) {
        final weight = (row['weight_kg'] as num?)?.toDouble() ?? 0;
        final reps = (row['reps'] as num?)?.toInt() ?? 0;
        totalWeight += weight * reps;
      }
      
      return {
        'total_sets': totalSets,
        'total_exercises': totalExercises,
        'total_weight_kg': totalWeight,
        'total_workouts': response.map((r) => '${r['program_id']}_${r['day_id']}').toSet().length,
      };
      
    } catch (error) {
      print('❌ Erro ao carregar estatísticas: $error');
      return {};
    }
  }
  
  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}