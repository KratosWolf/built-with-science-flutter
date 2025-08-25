import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/program_selection_screen.dart';
import 'screens/simple_home.dart';
import 'screens/programs_screen.dart';
import 'screens/program_detail_screen.dart';
import 'screens/workout_tracking_screen.dart';
import 'screens/simple_profile_screen.dart';
import 'widgets/page_transition.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // await Supabase.initialize(
  //   url: 'https://gktvfldykmzhynqthbdn.supabase.co',
  //   anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdrdHZmbGR5a216aHlucXRoYmRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjQzMzQ1NzQsImV4cCI6MjAzOTkxMDU3NH0.WGkqrCyHe1AYD8D9HHLCD_g_7i2k8RyQNjZN5wPJmUE',
  // );
  
  runApp(const BuiltWithScienceApp());
}

class BuiltWithScienceApp extends StatelessWidget {
  const BuiltWithScienceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Built With Science',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Modern indigo
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF6366F1), // Indigo 500
          secondary: const Color(0xFF10B981), // Emerald 500
          tertiary: const Color(0xFFEF4444), // Red 500 for intensity
          surface: const Color(0xFFF8FAFC), // Slate 50
          surfaceContainerHighest: const Color(0xFFF1F5F9), // Slate 100
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF6366F1),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF818CF8), // Indigo 400
          secondary: const Color(0xFF34D399), // Emerald 400
          tertiary: const Color(0xFFF87171), // Red 400
          surface: const Color(0xFF0F172A), // Slate 900
          surfaceContainerHighest: const Color(0xFF1E293B), // Slate 800
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const ProgramSelectionScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return FadePageRoute(child: const SimpleHomeScreen(), settings: settings);
          case '/home':
            return FadePageRoute(child: const SimpleHomeScreen(), settings: settings);
          case '/programs':
            return SlidePageRoute(
              child: const ProgramsScreen(),
              direction: SlideDirection.rightToLeft,
              settings: settings,
            );
          case '/program-detail':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null && args['program'] != null) {
              return SlidePageRoute(
                child: ProgramDetailScreen(program: args['program']),
                direction: SlideDirection.rightToLeft,
                settings: settings,
              );
            }
            return FadePageRoute(child: const SimpleHomeScreen(), settings: settings);
          case '/workout':
            final args = settings.arguments as Map<String, dynamic>;
            return ScalePageRoute(
              child: WorkoutTrackingScreen(
                programId: args['programId'] as int,
                dayId: args['dayId'] as int,
                dayName: args['dayName'] as String,
              ),
              curve: Curves.easeOutBack,
              settings: settings,
            );
          case '/profile':
            return SlidePageRoute(
              child: const SimpleProfileScreen(),
              direction: SlideDirection.bottomToTop,
              settings: settings,
            );
          default:
            return FadePageRoute(child: const SimpleHomeScreen(), settings: settings);
        }
      },
    );
  }
}

// Helper para acessar Supabase client
// final supabase = Supabase.instance.client;