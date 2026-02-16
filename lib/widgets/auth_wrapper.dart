import 'package:flutter/material.dart';
import 'dart:async';
import '../services/supabase_service.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation.dart';

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
      // SEGURANÇA: Verificar se Supabase foi inicializado com sucesso
      bool isLoggedIn = false;

      try {
        isLoggedIn = SupabaseService.instance.isLoggedIn;
        debugPrint('🔍 Auth status inicial: ${isLoggedIn ? 'Logado' : 'Não logado'}');
      } catch (e) {
        debugPrint('⚠️ Supabase não inicializado - continuando em modo offline');
        isLoggedIn = false;
      }

      setState(() {
        _showLoginScreen = !isLoggedIn;
        _isLoading = false;
      });

      // Listen for auth state changes (apenas se Supabase estiver OK)
      try {
        _authSubscription = SupabaseService.instance.authStateChanges.listen(
          (authState) {
            debugPrint('🔄 Auth state changed');

            if (mounted) {
              final newIsLoggedIn = authState.session != null;
              setState(() {
                _showLoginScreen = !newIsLoggedIn;
              });
            }
          },
          onError: (error) {
            debugPrint('❌ Erro no auth stream: $error');
          },
        );
      } catch (e) {
        debugPrint('⚠️ Não foi possível ouvir auth changes: $e');
        // Continua sem o listener - não é crítico
      }

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
      debugPrint('🏠 Usuário logado - indo para MainNavigation');
      // Usuário está logado, ir para MainNavigation (Home + Perfil)
      // TODO: No futuro, verificar se usuário já escolheu programa no banco
      return const MainNavigation();
    }
  }
}