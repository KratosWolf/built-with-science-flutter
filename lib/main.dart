import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/supabase_service.dart';
import 'screens/program_selection_screen.dart';
import 'screens/simple_home.dart';
import 'screens/programs_screen.dart';
import 'screens/program_detail_screen.dart';
import 'screens/workout_tracking_screen.dart';
import 'screens/simple_profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/backup_screen.dart';
import 'widgets/page_transition.dart';
import 'widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar UI do sistema para não interferir com a app
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  // Configurar status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // SUPABASE REATIVADO - Modo híbrido (online + offline)
  print('🔄 Inicializando Supabase...');

  // Inicialização mais robusta com timeout
  try {
    await SupabaseService.initialize().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print('⏰ Timeout na inicialização do Supabase - continuando offline');
        return;
      },
    );
    print('✅ Supabase initialized successfully');
  } catch (error) {
    print('❌ Error initializing Supabase: $error - continuando offline');
    print('ℹ️  App funcionará em modo offline');
  }
  
  runApp(const BuiltWithScienceApp());
}

class BuiltWithScienceApp extends StatelessWidget {
  const BuiltWithScienceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Built With Science',
      debugShowCheckedModeBanner: false, // Remove debug banner
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
      showPerformanceOverlay: false, // Remove performance overlay
      debugShowMaterialGrid: false, // Remove material grid
      showSemanticsDebugger: false, // Remove semantics debugger
      checkerboardRasterCacheImages: false, // Remove checkerboard
      checkerboardOffscreenLayers: false, // Remove checkerboard layers
      home: const AuthWrapper(), // Reativado com melhorias
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return FadePageRoute(child: const AuthWrapper(), settings: settings);
          case '/login':
            return FadePageRoute(child: const LoginScreen(), settings: settings);
          case '/program-selection':
            return FadePageRoute(child: const ProgramSelectionScreen(), settings: settings);
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
          case '/backup':
            return SlidePageRoute(
              child: const BackupScreen(),
              direction: SlideDirection.rightToLeft,
              settings: settings,
            );
          default:
            return FadePageRoute(child: const SimpleHomeScreen(), settings: settings);
        }
      },
    );
  }
}