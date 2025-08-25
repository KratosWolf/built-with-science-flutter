import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class RestTimerWidget extends StatefulWidget {
  final int seconds;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const RestTimerWidget({
    super.key,
    required this.seconds,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<RestTimerWidget> createState() => _RestTimerWidgetState();
}

class _RestTimerWidgetState extends State<RestTimerWidget>
    with TickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.seconds;
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _progressController = AnimationController(
      duration: Duration(seconds: widget.seconds),
      vsync: this,
    );
    
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _progressController.forward();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        
        // Vibração nos últimos 3 segundos
        if (_remainingSeconds <= 3 && _remainingSeconds > 0) {
          HapticFeedback.mediumImpact();
        }
        
        // Timer completo
        if (_remainingSeconds == 0) {
          HapticFeedback.heavyImpact();
          timer.cancel();
          widget.onComplete();
        }
      }
    });
  }

  void _pauseResumeTimer() {
    if (_isPaused) {
      _startTimer();
      _progressController.forward();
    } else {
      _timer?.cancel();
      _progressController.stop();
    }
    
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _addTime(int seconds) {
    setState(() {
      _remainingSeconds += seconds;
    });
    HapticFeedback.selectionClick();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Descanso',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Timer circular
              Stack(
                alignment: Alignment.center,
                children: [
                  // Progress ring
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return CircularProgressIndicator(
                          value: 1 - _progressController.value,
                          strokeWidth: 8,
                          backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation(
                            _remainingSeconds <= 10 
                                ? Colors.red 
                                : Theme.of(context).colorScheme.secondary,
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Timer text
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _remainingSeconds <= 3 
                            ? 1.0 + (_pulseController.value * 0.1)
                            : 1.0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(_remainingSeconds),
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _remainingSeconds <= 10 
                                    ? Colors.red 
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            if (_remainingSeconds <= 3 && _remainingSeconds > 0)
                              Text(
                                'Prepare-se!',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Botões de controle de tempo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeButton('-30s', () => _addTime(-30)),
                  _buildTimeButton('-10s', () => _addTime(-10)),
                  _buildTimeButton('+10s', () => _addTime(10)),
                  _buildTimeButton('+30s', () => _addTime(30)),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Botões de ação
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pauseResumeTimer,
                      icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                      label: Text(_isPaused ? 'Retomar' : 'Pausar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: widget.onSkip,
                      icon: const Icon(Icons.skip_next),
                      label: const Text('Pular'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(60, 36),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}