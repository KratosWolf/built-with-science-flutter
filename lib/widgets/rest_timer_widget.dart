import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/background_timer_service.dart';
import '../config/theme.dart';

class RestTimerWidget extends StatefulWidget {
  final VoidCallback? onTimerComplete;

  const RestTimerWidget({Key? key, this.onTimerComplete}) : super(key: key);

  @override
  _RestTimerWidgetState createState() => _RestTimerWidgetState();
}

class _RestTimerWidgetState extends State<RestTimerWidget> {
  Timer? _timer;
  int _selectedSeconds = 60; // Padrão 60s
  int _currentSeconds = 0;
  bool _isRunning = false;

  // OPÇÕES DE TEMPO
  final List<int> _timeOptions = [60, 75, 90];
  final Map<int, String> _timeLabels = {
    60: '1:00',
    75: '1:15',
    90: '1:30',
  };

  @override
  void initState() {
    super.initState();
    _loadPreferredTime();
  }

  // Carregar última preferência
  Future<void> _loadPreferredTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSeconds = prefs.getInt('preferred_rest_time') ?? 60;
      _currentSeconds = _selectedSeconds;
    });
  }

  // Salvar preferência
  Future<void> _savePreferredTime(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('preferred_rest_time', seconds);
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _currentSeconds = _selectedSeconds;
    });

    // Usar o BackgroundTimerService para continuar em background
    BackgroundTimerService.startRestTimer(
      _selectedSeconds,
      onComplete: () {
        if (mounted) {
          setState(() {
            _isRunning = false;
            _currentSeconds = _selectedSeconds;
          });
          widget.onTimerComplete?.call();
        }
      },
    );

    // Timer local para atualizar UI
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentSeconds--;
          if (_currentSeconds <= 0) {
            _isRunning = false;
            _currentSeconds = _selectedSeconds;
            timer.cancel();
          }
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    BackgroundTimerService.cancelTimer();
    setState(() {
      _isRunning = false;
      _currentSeconds = _selectedSeconds;
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TÍTULO
            const Text(
              'REST TIMER',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 8),

            // SELETOR DE TEMPO (só aparece quando parado)
            if (!_isRunning) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _timeOptions.map((seconds) {
                  bool isSelected = _selectedSeconds == seconds;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: ChoiceChip(
                      label: Text(
                        _timeLabels[seconds]!,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppTheme.textPrimary : AppTheme.textPrimary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryOrange,
                      onSelected: (selected) {
                        if (selected && !_isRunning) {
                          setState(() {
                            _selectedSeconds = seconds;
                            _currentSeconds = seconds;
                          });
                          _savePreferredTime(seconds);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
            ],

            // DISPLAY DO TIMER
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isRunning
                    ? (_currentSeconds <= 10 ? AppTheme.error : AppTheme.primaryOrange)
                    : AppTheme.borderColor,
                  width: 4,
                ),
              ),
              child: Center(
                child: Text(
                  _formatTime(_currentSeconds),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _isRunning
                      ? (_currentSeconds <= 10 ? AppTheme.error : AppTheme.textPrimary)
                      : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // BOTÕES
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // BOTÃO START/STOP
                ElevatedButton.icon(
                  onPressed: _isRunning ? _stopTimer : _startTimer,
                  icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                  label: Text(_isRunning ? 'PARAR' : 'INICIAR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRunning ? AppTheme.error : AppTheme.primaryOrange,
                    foregroundColor: AppTheme.textPrimary,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),

                // BOTÃO SKIP (só quando rodando)
                if (_isRunning) ...[
                  SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () {
                      _stopTimer();
                      widget.onTimerComplete?.call();
                    },
                    child: Text('PULAR'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ],
            ),

            // DICA
            if (!_isRunning) ...[
              SizedBox(height: 12),
              const Text(
                'Escolha o tempo de descanso acima',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            // INDICADOR BACKGROUND
            if (_isRunning) ...[
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.info_outline, size: 14, color: AppTheme.info),
                  SizedBox(width: 4),
                  Text(
                    'Timer continua no background',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.info,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
