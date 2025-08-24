import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/program_selection_screen.dart';
import 'screens/simple_home.dart';
import 'screens/programs_screen.dart';
import 'screens/program_detail_screen.dart';
import 'screens/workout_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://gktvfldykmzhynqthbdn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdrdHZmbGR5a216aHlucXRoYmRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjQzMzQ1NzQsImV4cCI6MjAzOTkxMDU3NH0.WGkqrCyHe1AYD8D9HHLCD_g_7i2k8RyQNjZN5wPJmUE',
  );
  
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
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const SimpleHomeScreen());
          case '/home':
            return MaterialPageRoute(builder: (context) => const SimpleHomeScreen());
          case '/programs':
            return MaterialPageRoute(builder: (context) => const ProgramsScreen());
          case '/program-detail':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null && args['program'] != null) {
              return MaterialPageRoute(
                builder: (context) => ProgramDetailScreen(program: args['program']),
              );
            }
            return MaterialPageRoute(builder: (context) => const SimpleHomeScreen());
          case '/workout':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => WorkoutScreen(
                programId: args['programId'] as int,
                dayId: args['dayId'] as int,
              ),
            );
          case '/profile':
            return MaterialPageRoute(builder: (context) => const ProfileScreen());
          default:
            return MaterialPageRoute(builder: (context) => const SimpleHomeScreen());
        }
      },
    );
  }
}

// Helper para acessar Supabase client
final supabase = Supabase.instance.client;