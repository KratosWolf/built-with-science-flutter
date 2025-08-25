import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late final Stream<AuthState> _authStream;
  
  @override
  void initState() {
    super.initState();
    _authStream = SupabaseService.instance.authStateChanges;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authStream,
      builder: (context, snapshot) {
        // Show loading while determining auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          // User is logged in - show main app
          print('👤 Usuário logado: ${session.user.email}');
          return const HomeScreen();
        } else {
          // User is not logged in - show login screen
          print('🔐 Usuário não logado - mostrando tela de login');
          return const LoginScreen();
        }
      },
    );
  }
}