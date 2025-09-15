import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/workout_models.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  SupabaseService._();
  
  // Supabase client
  SupabaseClient? _client;
  SupabaseClient? get client => _client;
  
  // Auth state
  User? get currentUser {
    try {
      return _client?.auth.currentUser;
    } catch (e) {
      print('❌ Erro ao obter usuário: $e');
      return null;
    }
  }
  
  bool get isLoggedIn {
    try {
      return currentUser != null;
    } catch (e) {
      print('❌ Erro ao verificar login: $e');
      return false;
    }
  }
  
  // Google Sign-in instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  
  /// Initialize Supabase
  static Future<void> initialize() async {
    try {
      print('🔧 Inicializando Supabase...');
      
      instance._client = SupabaseClient(
        'https://gktvfldykmzhynqthbdn.supabase.co',
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdrdHZmbGR5a216aHlucXRoYmRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU5Nzg4NzAsImV4cCI6MjA3MTU1NDg3MH0.Nd2KdEGj8hQApxmTk8nkBM81R4ROJPhwRMtgPXadGVw',
      );
      
      print('✅ Supabase cliente criado');
      
      // Teste básico para verificar se está funcionando
      await instance._client!.from('user_profiles').select().limit(1);
      print('✅ Conexão com Supabase testada');
      
    } catch (error) {
      print('⚠️ Erro na inicialização do Supabase: $error');
      print('📱 Continuando em modo offline...');
      // Não throw error - app deve continuar funcionando offline
    }
  }
  
  /// Sign in with Google
  Future<AuthResponse?> signInWithGoogle() async {
    if (_client == null) {
      print('❌ Supabase não inicializado');
      return null;
    }
    
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
      final AuthResponse response = await _client!.auth.signInWithIdToken(
        provider: Provider.google,
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
  
  /// Sign in with Email/Password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    if (_client == null) {
      print('❌ Supabase não inicializado');
      return null;
    }
    
    try {
      print('🔐 Tentando login com email/password...');
      
      final response = await _client!.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        print('✅ Login com email realizado com sucesso!');
        // Create user profile if doesn't exist
        await _createUserProfileIfNeeded(response.user!);
        return response.user;
      } else {
        print('❌ Falha no login: usuário nulo');
        return null;
      }
      
    } catch (error) {
      print('❌ Erro no login com email: $error');
      throw error; // Re-throw to show specific error to user
    }
  }

  /// Sign up with Email/Password
  Future<User?> signUpWithEmailPassword(String email, String password, String fullName) async {
    if (_client == null) {
      print('❌ Supabase não inicializado');
      return null;
    }
    
    try {
      print('📝 Criando nova conta com email/password...');
      
      final response = await _client!.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'app_name': 'Built With Science',
        },
      );
      
      if (response.user != null) {
        print('✅ Conta criada com sucesso!');
        // Create user profile
        await _createUserProfileIfNeeded(response.user!);
        return response.user;
      } else {
        print('❌ Falha na criação: usuário nulo');
        return null;
      }
      
    } catch (error) {
      print('❌ Erro na criação da conta: $error');
      throw error; // Re-throw to show specific error to user
    }
  }

  /// Reset Password
  Future<bool> resetPassword(String email) async {
    if (_client == null) {
      print('❌ Supabase não inicializado');
      return false;
    }
    
    try {
      print('🔄 Enviando reset de senha para: $email');
      
      await _client!.auth.resetPasswordForEmail(email);
      
      print('✅ Email de reset enviado com sucesso!');
      return true;
      
    } catch (error) {
      print('❌ Erro no reset de senha: $error');
      throw error;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      print('🔐 Fazendo logout...');
      
      // Sign out from Google
      await _googleSignIn.signOut();
      
      // Sign out from Supabase
      if (_client != null) {
        await _client!.auth.signOut();
      }
      
      print('✅ Logout realizado');
    } catch (error) {
      print('❌ Erro no logout: $error');
    }
  }
  
  /// Create user profile in database if needed
  Future<void> _createUserProfileIfNeeded(User user) async {
    if (_client == null) return;
    
    try {
      // Check if profile already exists
      final response = await _client!
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      if (response == null) {
        // Create new profile
        await _client!.from('user_profiles').insert({
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
    if (!isLoggedIn || _client == null) {
      print('❌ Usuário não logado ou Supabase não inicializado');
      return false;
    }
    
    try {
      print('☁️ Salvando set na nuvem...');
      
      await _client!.from('workout_sessions').upsert({
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
    if (!isLoggedIn || _client == null) {
      print('❌ Usuário não logado ou Supabase não inicializado');
      return {};
    }
    
    try {
      print('☁️ Carregando dados do último treino da nuvem...');
      
      final response = await _client!
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
  
  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges {
    if (_client == null) {
      // Return empty stream if Supabase not initialized
      return const Stream.empty();
    }
    try {
      return _client!.auth.onAuthStateChange;
    } catch (e) {
      print('❌ Erro no stream de auth: $e');
      return const Stream.empty();
    }
  }
}