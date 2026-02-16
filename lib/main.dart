import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart'; // Tema centralizado
import 'services/supabase_service.dart';
import 'services/theme_service.dart';
import 'screens/program_selection_screen.dart';
import 'screens/simple_home.dart';
import 'screens/main_navigation.dart';
import 'screens/programs_screen.dart';
import 'screens/program_detail_screen.dart';
import 'screens/workout_tracking_screen.dart';
import 'screens/profile_screen.dart';
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
  debugPrint('🔄 Inicializando Supabase...');

  // Inicialização mais robusta com timeout
  try {
    await SupabaseService.initialize().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('⏰ Timeout na inicialização do Supabase - continuando offline');
        return;
      },
    );
    debugPrint('✅ Supabase initialized successfully');
  } catch (error) {
    debugPrint('❌ Error initializing Supabase: $error - continuando offline');
    debugPrint('ℹ️  App funcionará em modo offline');
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const BuiltWithScienceApp(),
    ),
  );
}

class BuiltWithScienceApp extends StatelessWidget {
  const BuiltWithScienceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) => MaterialApp(
      title: 'Built With Science',
      debugShowCheckedModeBanner: false,

      // Tema dark centralizado (preto + laranja)
      // Referência: estilo premium fitness (Coach Sandow)
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,

      // ThemeMode controlado pelo ThemeService (mas ambos os temas são dark)
      themeMode: themeService.themeMode,
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
            return FadePageRoute(child: const MainNavigation(), settings: settings);
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
              child: const ProfileScreen(),
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
      ), // Close MaterialApp
    ); // Close Consumer
  }
}