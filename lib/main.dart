import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/programs_screen.dart';
import 'screens/program_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuração Supabase - MyFirstBA project
  await Supabase.initialize(
    url: 'https://mqcfdwyhbtvaclslured.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1xY2Zkd3loYnR2YWNsc2x1cmVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUzNDUzMjcsImV4cCI6MjA3MDkyMTMyN30.lpiqxTq-V18FhRSDd0V4xV4GvsTMVlU-GrHdvtzjQ4U',
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
      home: const HomeScreen(),
      routes: {
        '/programs': (context) => const ProgramsScreen(),
        '/program-detail': (context) => const ProgramDetailScreen(),
      },
    );
  }
}

// Helper para acessar Supabase client
final supabase = Supabase.instance.client;