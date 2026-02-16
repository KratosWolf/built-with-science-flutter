import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isLoginMode = true; // true = login, false = register

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      if (_isLoginMode) {
        // Login
        final user = await SupabaseService.instance.signInWithEmailPassword(email, password);
        if (user != null && mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        // Register
        final fullName = _nameController.text.trim();
        final user = await SupabaseService.instance.signUpWithEmailPassword(email, password, fullName);
        if (user != null && mounted) {
          _showSuccessSnackBar('Conta criada com sucesso! Verifique seu email.');
          setState(() {
            _isLoginMode = true;
          });
        }
      }
    } catch (error) {
      String message = error.toString();
      if (message.contains('Invalid login credentials')) {
        message = 'Email ou senha incorretos';
      } else if (message.contains('User already registered')) {
        message = 'Este email já está cadastrado';
      } else if (message.contains('Password should be')) {
        message = 'Senha deve ter pelo menos 6 caracteres';
      } else if (message.contains('Unable to validate email address')) {
        message = 'Email inválido';
      }
      _showErrorSnackBar(message);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showErrorSnackBar('Digite seu email primeiro');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await SupabaseService.instance.resetPassword(email);
      _showSuccessSnackBar('Email de recuperação enviado!');
    } catch (error) {
      _showErrorSnackBar('Erro ao enviar email: ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      print('🔵 [UI] Iniciando Google Sign-In...');
      final user = await SupabaseService.instance.signInWithGoogle();

      if (user != null && mounted) {
        print('✅ [UI] Login bem-sucedido, navegando para home...');
        _showSuccessSnackBar('Bem-vindo, ${user.email}!');

        // Navigate to home after short delay to show success message
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        });
      }
    } catch (error) {
      print('❌ [UI] Erro no Google Sign-In: $error');

      String message = error.toString();
      if (message.contains('cancelado')) {
        message = 'Login cancelado';
      } else if (message.contains('network')) {
        message = 'Erro de conexão. Verifique sua internet.';
      } else {
        message = 'Erro ao fazer login com Google. Tente novamente.';
      }

      _showErrorSnackBar(message);
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // App Logo and Title
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Built With Science',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Seu treino baseado em ciência',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Login/Register Form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Toggle between Login/Register
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => setState(() => _isLoginMode = true),
                                  style: TextButton.styleFrom(
                                    backgroundColor: _isLoginMode 
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    foregroundColor: _isLoginMode 
                                        ? Colors.white 
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                  child: const Text('Entrar', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextButton(
                                  onPressed: () => setState(() => _isLoginMode = false),
                                  style: TextButton.styleFrom(
                                    backgroundColor: !_isLoginMode 
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    foregroundColor: !_isLoginMode 
                                        ? Colors.white 
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                  child: const Text('Criar Conta', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Name Field (only for register)
                          if (!_isLoginMode) ...[
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nome Completo',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (!_isLoginMode && (value == null || value.isEmpty)) {
                                  return 'Digite seu nome';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite seu email';
                              }
                              if (!value.contains('@')) {
                                return 'Email inválido';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite sua senha';
                              }
                              if (!_isLoginMode && value.length < 6) {
                                return 'Senha deve ter pelo menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Submit Button
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      _isLoginMode ? 'ENTRAR' : 'CRIAR CONTA',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          
                          // Forgot Password (only for login)
                          if (_isLoginMode) ...[
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _isLoading ? null : _resetPassword,
                              child: const Text('Esqueci minha senha'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.white54)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'ou',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Colors.white54)),
                    ],
                  ),
                  
                  const SizedBox(height: 32),

                  // Google Sign-In Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_isLoading || _isGoogleLoading) ? null : _handleGoogleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Colors.black12, width: 1),
                        ),
                      ),
                      child: _isGoogleLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Google Icon
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        'https://www.google.com/images/branding/googleg/1x/googleg_standard_color_128dp.png',
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'CONTINUAR COM GOOGLE',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Offline Mode Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/home');
                      },
                      icon: const Icon(Icons.phone_android, size: 28),
                      label: const Text(
                        'USAR OFFLINE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Info text
                  Text(
                    'Modo offline: seus dados ficam apenas no celular\n'
                    'Modo online: dados sincronizados na nuvem',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}