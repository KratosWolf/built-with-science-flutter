// SUPABASE SERVICE - STUB VERSION (Offline Mode)
// This is a stub implementation that doesn't require Supabase packages
// Used when building APK without Supabase dependencies

import '../models/workout_models.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  // Stub client
  dynamic get client => null;

  // Auth state - always null in offline mode
  dynamic get currentUser => null;

  bool get isLoggedIn => false;

  /// Initialize Supabase (stub - does nothing in offline mode)
  static Future<void> initialize() async {
    print('📱 Supabase desabilitado - Modo offline ativo');
  }

  /// Sign in with Google (stub - returns null)
  Future<dynamic> signInWithGoogle() async {
    print('❌ Supabase não disponível - Use modo offline');
    return null;
  }

  /// Sign in with Email/Password (stub - returns null)
  Future<dynamic> signInWithEmailPassword(String email, String password) async {
    print('❌ Supabase não disponível - Use modo offline');
    return null;
  }

  /// Sign up with Email/Password (stub - returns null)
  Future<dynamic> signUpWithEmailPassword(String email, String password, String fullName) async {
    print('❌ Supabase não disponível - Use modo offline');
    return null;
  }

  /// Reset Password (stub - returns false)
  Future<bool> resetPassword(String email) async {
    print('❌ Supabase não disponível - Use modo offline');
    return false;
  }

  /// Sign out (stub - does nothing)
  Future<void> signOut() async {
    print('📱 Modo offline - Nenhuma sessão para encerrar');
  }

  /// Save workout set to cloud (stub - returns false)
  Future<bool> saveWorkoutSet(WorkoutSet workoutSet, int programId, int dayId) async {
    print('📱 Modo offline - Dados salvos localmente');
    return false;
  }

  /// Load user's last workout data from cloud (stub - returns empty map)
  Future<Map<int, List<WorkoutSet>>> loadLastWorkoutData(int programId, int dayId) async {
    print('📱 Modo offline - Carregando dados locais');
    return {};
  }

  /// Listen to auth state changes (stub - returns empty stream)
  Stream<dynamic> get authStateChanges {
    return const Stream.empty();
  }
}
