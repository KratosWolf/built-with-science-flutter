import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../screens/login_screen.dart';
import '../screens/program_selection_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _hasError = false;
  bool _showLoginScreen = false;
  
  @override
  void initState() {
    super.initState();
    _checkAuthWithTimeout();
  }
  
  Future<void> _checkAuthWithTimeout() async {
    try {
      // Timeout mais agressivo para não travar
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Verificar se Supabase foi inicializado e se usuário está logado
      final isLoggedIn = SupabaseService.instance.isLoggedIn;
      print('🔍 Status inicial: ${isLoggedIn ? 'Logado' : 'Não logado'}');
      
      setState(() {
        _isLoading = false;
        _showLoginScreen = !isLoggedIn; // Mostrar login se não estiver logado
      });
    } catch (error) {
      print('❌ Erro no AuthWrapper: $error - continuando offline');
      setState(() {
        _isLoading = false;
        _hasError = false; // Não tratar como erro, só ir para app
        _showLoginScreen = false;
      });
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
      print('🔐 Mostrando tela de login');
      return const LoginScreen();
    } else {
      print('🏠 Indo direto para o app');
      return const ProgramSelectionScreen();
    }
  }
}