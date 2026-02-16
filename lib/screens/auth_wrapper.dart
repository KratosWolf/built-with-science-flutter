import 'package:flutter/material.dart';
import 'dart:async';
import '../services/supabase_service.dart';
import 'login_screen.dart';
import 'program_selection_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _showLoginScreen = true; // Start with login screen by default
  StreamSubscription? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeAuth() async {
    try {
      // Check initial auth state
      final isLoggedIn = SupabaseService.instance.isLoggedIn;
      debugPrint('🔍 Auth status inicial: ${isLoggedIn ? 'Logado' : 'Não logado'}');

      setState(() {
        _showLoginScreen = !isLoggedIn;
        _isLoading = false;
      });

      // Listen for auth state changes (stub - won't emit any events in offline mode)
      _authSubscription = SupabaseService.instance.authStateChanges.listen(
        (authState) {
          // In offline mode, this stream is empty and won't emit events
          // But keep the listener for future Supabase re-activation
          debugPrint('🔄 Auth state changed: Modo offline ativo');

          if (mounted) {
            setState(() {
              _showLoginScreen = true; // Always show login in offline mode
            });
          }
        },
        onError: (error) {
          debugPrint('❌ Erro no auth stream: $error');
        },
      );

    } catch (error) {
      debugPrint('❌ Erro na inicialização do auth: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showLoginScreen = true; // Default to login screen on error
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading durante verificação inicial (mais rápido)
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              CircularProgressIndicator(
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                'Built With Science',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Decidir qual tela mostrar baseado no status
    if (_showLoginScreen) {
      debugPrint('🔐 Mostrando tela de login');
      return const LoginScreen();
    } else {
      debugPrint('🏠 Indo direto para o app');
      return const ProgramSelectionScreen();
    }
  }
}
