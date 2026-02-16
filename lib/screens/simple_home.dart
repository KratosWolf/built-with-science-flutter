import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dashboard_screen.dart';
import 'workout_tracking_screen.dart';
import 'program_selection_screen.dart';

class SimpleHomeScreen extends StatefulWidget {
  const SimpleHomeScreen({super.key});

  @override
  State<SimpleHomeScreen> createState() => _SimpleHomeScreenState();
}

class _SimpleHomeScreenState extends State<SimpleHomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startWorkout() async {
    final prefs = await SharedPreferences.getInstance();

    // Debug: ver todas as keys disponíveis
    debugPrint('🔍 DEBUG: Verificando programa selecionado...');
    debugPrint('🔍 Keys disponíveis: ${prefs.getKeys()}');

    var programId = prefs.getInt('selected_program_id');
    debugPrint('🔍 Program ID encontrado: $programId');

    // MIGRAÇÃO AUTOMÁTICA - detectar programa de dados antigos
    if (programId == null) {
      debugPrint('🔄 Tentando migrar dados antigos...');

      // Detectar programa dos dados de treino
      if (prefs.containsKey('next_workout_day_1')) {
        debugPrint('✅ Encontrado next_workout_day_1 - Migrando para programa 1');
        await prefs.setInt('selected_program_id', 1);
        await prefs.setString('selected_program_name', 'Full Body 3-Day');
        await prefs.setInt('selected_program_days', 3);
        programId = 1;
        debugPrint('✅ Migração completa! Program ID agora: $programId');
      }
    }

    if (programId == null) {
      debugPrint('❌ Nenhum programa selecionado - navegando para seleção');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Selecione um programa primeiro'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProgramSelectionScreen(),
        ),
      );
    } else {
      final nextDay = prefs.getInt('next_workout_day_$programId') ?? 1;
      final programName = prefs.getString('selected_program_name') ?? '';

      debugPrint('✅ Programa encontrado: ID=$programId, Nome=$programName');
      debugPrint('🔍 Próximo dia: $nextDay');
      debugPrint('🔍 Navegando para WorkoutTrackingScreen...');

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkoutTrackingScreen(
            programId: programId!, // Safe to use ! here, we know it's not null
            dayId: nextDay,
            dayName: 'Day $nextDay',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏋️ Built With Science'),
        backgroundColor: const Color(0xFF6A1B9A), // Deep Purple
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section with improved gradient
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6A1B9A), // Deep Purple
                          Color(0xFF8E24AA), // Purple
                          Color(0xFFAB47BC), // Light Purple
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6A1B9A).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Ready for your next workout?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grid of action cards with improved styling
                  SizedBox(
                    height: 400,
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildActionCard(
                          context,
                          'Start Workout',
                          Icons.play_circle_outline,
                          const Color(0xFFFB8C00), // Orange
                          _startWorkout,
                        ),
                        _buildActionCard(
                          context,
                          'Programs',
                          Icons.fitness_center_outlined,
                          const Color(0xFF43A047), // Green
                          () => Navigator.pushNamed(context, '/programs'),
                        ),
                        _buildActionCard(
                          context,
                          'Dashboard',
                          Icons.bar_chart_outlined,
                          const Color(0xFF8E24AA), // Purple
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DashboardScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtle status indicator
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_done_outlined,
                            color: Colors.green.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Cloud Synced',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
