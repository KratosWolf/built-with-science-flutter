import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

/// Background Timer Service - Mantém timer rodando mesmo quando app está em background
/// Uso: Timer de descanso entre sets que continua funcionando ao trocar pro Spotify
/// NOTA: Versão simplificada sem notificações (problemas de compatibilidade com Android SDK 34)
class BackgroundTimerService {
  static Timer? _restTimer;
  static int _remainingSeconds = 0;
  static bool _isInitialized = false;

  /// Inicializar serviço
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isInitialized = true;
      print('✅ BackgroundTimerService inicializado (modo simplificado)');
    } catch (e) {
      print('❌ Erro ao inicializar BackgroundTimerService: $e');
    }
  }

  /// Iniciar timer que continua em background
  static void startRestTimer(int seconds, {VoidCallback? onComplete}) {
    _restTimer?.cancel();
    _remainingSeconds = seconds;

    print('⏱️  Timer iniciado: $seconds segundos');

    // Timer isolado que sobrevive ao background
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;

      // Log a cada 10 segundos para debug
      if (_remainingSeconds > 0 && _remainingSeconds % 10 == 0) {
        print('⏱️  Timer: $_remainingSeconds segundos restantes');
      }

      // Timer completou!
      if (_remainingSeconds <= 0) {
        timer.cancel();
        print('✅ Timer completado!');
        _onTimerComplete();
        onComplete?.call();
      }
    });
  }

  /// Vibração ao completar (padrão Samsung Galaxy S21+)
  static Future<void> _onTimerComplete() async {
    try {
      // Verificar se dispositivo tem vibrador
      final hasVibrator = await Vibration.hasVibrator() ?? false;

      if (hasVibrator) {
        // Vibração forte 3x (padrão Samsung)
        // Pattern: [espera, vibra, espera, vibra, espera, vibra]
        await Vibration.vibrate(
          pattern: [0, 400, 200, 400, 200, 400],
          intensities: [0, 255, 0, 255, 0, 255], // Intensidade máxima
        );
        print('📳 Vibração ativada - Descanso completo!');
      } else {
        print('⚠️  Dispositivo não tem vibrador');
      }
    } catch (e) {
      print('❌ Erro na vibração: $e');
    }
  }

  /// Pausar timer
  static void pauseTimer() {
    _restTimer?.cancel();
    print('⏸️  Timer pausado');
  }

  /// Retomar timer
  static void resumeTimer({VoidCallback? onComplete}) {
    if (_remainingSeconds > 0) {
      print('▶️  Timer retomado: $_remainingSeconds segundos');
      startRestTimer(_remainingSeconds, onComplete: onComplete);
    }
  }

  /// Cancelar timer
  static void cancelTimer() {
    _restTimer?.cancel();
    _remainingSeconds = 0;
    print('❌ Timer cancelado');
  }

  /// Getter para tempo restante
  static int get remainingSeconds => _remainingSeconds;

  /// Verificar se timer está rodando
  static bool get isRunning => _restTimer?.isActive ?? false;
}
