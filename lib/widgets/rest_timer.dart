import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

class RestTimer extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback onComplete;
  final VoidCallback onSkip;
  final bool isActive;
  final String? exerciseName;
  final bool enableVibration;
  final bool enableSound;

  const RestTimer({
    super.key,
    required this.initialSeconds,
    required this.onComplete,
    required this.onSkip,
    required this.isActive,
    this.exerciseName,
    this.enableVibration = true,
    this.enableSound = false,
  });

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> 
    with TickerProviderStateMixin, WidgetsBindingObserver {
  
  late int timeLeft;
  late int originalTime;
  late bool isRunning;
  late bool isPaused;
  Timer? _timer;
  
  // Animations
  late AnimationController _scaleAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _colorAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation;
  
  // Mobile optimizations
  bool _isAppInBackground = false;
  DateTime? _backgroundStartTime;
  int _backgroundTimeElapsed = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    timeLeft = widget.initialSeconds;
    originalTime = widget.initialSeconds;
    isRunning = widget.isActive;
    isPaused = false;
    
    _initializeAnimations();
    
    if (widget.isActive) {
      _startTimer();
      _scaleAnimationController.forward();
    }
  }

  void _initializeAnimations() {
    // Scale animation for entry
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleAnimationController, curve: Curves.elasticOut),
    );
    
    // Pulse animation for urgency
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseAnimationController, curve: Curves.easeInOut),
    );
    
    // Color transition animation
    _colorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: Colors.green,
      end: Colors.red,
    ).animate(_colorAnimationController);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        if (isRunning && !isPaused) {
          _isAppInBackground = true;
          _backgroundStartTime = DateTime.now();
        }
        break;
      case AppLifecycleState.resumed:
        if (_isAppInBackground && _backgroundStartTime != null) {
          _handleBackgroundTimer();
        }
        _isAppInBackground = false;
        _backgroundStartTime = null;
        break;
      default:
        break;
    }
  }

  void _handleBackgroundTimer() {
    if (_backgroundStartTime == null) return;
    
    final elapsedInBackground = DateTime.now().difference(_backgroundStartTime!).inSeconds;
    
    setState(() {
      timeLeft = (timeLeft - elapsedInBackground).clamp(0, originalTime);
    });
    
    if (timeLeft <= 0) {
      _onTimerComplete();
    }
    
    _updateAnimations();
  }

  @override
  void didUpdateWidget(RestTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _resetTimer();
    }
  }

  void _resetTimer() {
    setState(() {
      timeLeft = widget.initialSeconds;
      originalTime = widget.initialSeconds;
      isRunning = true;
      isPaused = false;
    });
    _startTimer();
    _scaleAnimationController.forward();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && isRunning && !isPaused && timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
        
        _updateAnimations();
        _handleTimerEffects();
        
        if (timeLeft == 0) {
          _onTimerComplete();
        }
      }
    });
  }

  void _updateAnimations() {
    final progress = 1 - (timeLeft / originalTime);
    _colorAnimationController.animateTo(progress);
    
    // Start pulsing when time is low
    if (timeLeft <= 10 && timeLeft > 0) {
      if (!_pulseAnimationController.isAnimating) {
        _pulseAnimationController.repeat(reverse: true);
      }
    } else {
      _pulseAnimationController.stop();
      _pulseAnimationController.reset();
    }
  }

  void _handleTimerEffects() {
    // Vibration at specific intervals
    if (widget.enableVibration) {
      if (timeLeft == 10 || timeLeft == 5 || (timeLeft <= 3 && timeLeft > 0)) {
        HapticFeedback.mediumImpact();
      }
    }
    
    // Different vibration patterns
    if (timeLeft == 1) {
      HapticFeedback.heavyImpact();
    }
  }

  void _onTimerComplete() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
      timeLeft = 0;
    });
    
    // Strong haptic feedback for completion
    if (widget.enableVibration) {
      HapticFeedback.lightImpact();
      // Double vibration for emphasis
      Future.delayed(const Duration(milliseconds: 200), () {
        HapticFeedback.lightImpact();
      });
    }
    
    _pulseAnimationController.stop();
    widget.onComplete();
  }

  void _toggleTimer() {
    setState(() {
      isPaused = !isPaused;
    });
    
    HapticFeedback.lightImpact();
    
    if (!isPaused && timeLeft > 0) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
  }

  void _addTime(int seconds) {
    setState(() {
      timeLeft = (timeLeft + seconds).clamp(0, originalTime + 120); // Max 2 minutes extra
      originalTime = math.max(originalTime, timeLeft);
    });
    
    HapticFeedback.lightImpact();
    _updateAnimations();
    
    if (!isRunning && timeLeft > 0) {
      setState(() {
        isRunning = true;
        isPaused = false;
      });
      _startTimer();
    }
  }

  void _subtractTime(int seconds) {
    setState(() {
      timeLeft = (timeLeft - seconds).clamp(0, originalTime);
    });
    
    HapticFeedback.lightImpact();
    _updateAnimations();
    
    if (timeLeft == 0) {
      _onTimerComplete();
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double _getProgressPercentage() {
    if (originalTime == 0) return 1.0;
    return (originalTime - timeLeft) / originalTime;
  }

  Color _getTimerColor() {
    final percentage = timeLeft / originalTime;
    if (percentage > 0.6) return Colors.green;
    if (percentage > 0.3) return Colors.orange;
    if (percentage > 0.1) return Colors.deepOrange;
    return Colors.red;
  }

  String _getStatusText() {
    if (timeLeft == 0) {
      return 'Rest complete! Ready for your next set 💪';
    } else if (isPaused) {
      return 'Timer paused - tap resume when ready';
    } else if (timeLeft <= 10) {
      return 'Get ready! Next set coming up...';
    } else if (timeLeft <= 30) {
      return 'Almost ready for your next set';
    } else {
      return widget.exerciseName != null 
        ? 'Resting after ${widget.exerciseName}'
        : 'Take your time to recover properly';
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _scaleAnimationController.dispose();
    _pulseAnimationController.dispose();
    _colorAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive && timeLeft == 0) {
      return const SizedBox.shrink();
    }

    final timerColor = _getTimerColor();
    final shouldPulse = timeLeft <= 10 && timeLeft > 0;
    final isUrgent = timeLeft <= 5 && timeLeft > 0;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _pulseAnimation,
        _colorAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * (shouldPulse ? _pulseAnimation.value : 1.0),
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: timerColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: timerColor,
                  width: isUrgent ? 4 : 2,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      timerColor.withOpacity(0.1),
                      timerColor.withOpacity(0.05),
                      Colors.white.withOpacity(0.9),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: timerColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isPaused ? Icons.pause_circle : Icons.timer,
                              color: timerColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isPaused ? 'Timer Paused' : 'Rest Time',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: timerColor,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Large Timer Display
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: timerColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          _formatTime(timeLeft),
                          style: TextStyle(
                            fontSize: isUrgent ? 60 : 56,
                            fontWeight: FontWeight.w900,
                            color: timerColor,
                            fontFamily: 'monospace',
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Progress Ring
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: Stack(
                          children: [
                            // Background circle
                            SizedBox.expand(
                              child: CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 8,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.grey.shade300,
                                ),
                              ),
                            ),
                            // Progress circle
                            SizedBox.expand(
                              child: Transform.rotate(
                                angle: -math.pi / 2,
                                child: CircularProgressIndicator(
                                  value: _getProgressPercentage(),
                                  strokeWidth: 8,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                            ),
                            // Center percentage
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${((_getProgressPercentage()) * 100).round()}%',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: timerColor,
                                    ),
                                  ),
                                  Text(
                                    'complete',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Status Message
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: timerColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: timerColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Time adjustment buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTimeButton(
                            icon: Icons.remove,
                            label: '-15s',
                            onPressed: timeLeft >= 15 ? () => _subtractTime(15) : null,
                            color: Colors.red.shade400,
                          ),
                          _buildTimeButton(
                            icon: isPaused ? Icons.play_arrow : Icons.pause,
                            label: isPaused ? 'Resume' : 'Pause',
                            onPressed: _toggleTimer,
                            color: timerColor,
                            isMainAction: true,
                          ),
                          _buildTimeButton(
                            icon: Icons.add,
                            label: '+30s',
                            onPressed: () => _addTime(30),
                            color: Colors.green.shade400,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: widget.onComplete,
                              icon: const Icon(Icons.check_circle, size: 20),
                              label: const Text('Ready for Next Set'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: widget.onSkip,
                              icon: const Icon(Icons.skip_next, size: 20),
                              label: const Text('Skip Rest'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey.shade400),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Background timer indicator
                      if (_isAppInBackground)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh,
                                color: Colors.blue.shade600,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Timer continues in background',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    bool isMainAction = false,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: onPressed != null ? color.withOpacity(0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: onPressed != null ? color.withOpacity(0.3) : Colors.grey.shade300,
              width: isMainAction ? 2 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Icon(
                  icon,
                  color: onPressed != null ? color : Colors.grey.shade400,
                  size: isMainAction ? 28 : 24,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: onPressed != null ? color : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}