import 'package:flutter/material.dart';
import 'dart:async';

class RestTimer extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback onComplete;
  final VoidCallback onSkip;
  final bool isActive;

  const RestTimer({
    super.key,
    required this.initialSeconds,
    required this.onComplete,
    required this.onSkip,
    required this.isActive,
  });

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> with TickerProviderStateMixin {
  late int timeLeft;
  late bool isRunning;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    timeLeft = widget.initialSeconds;
    isRunning = widget.isActive;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    
    if (widget.isActive) {
      _startTimer();
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(RestTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      setState(() {
        timeLeft = widget.initialSeconds;
        isRunning = true;
      });
      _startTimer();
      _animationController.forward();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && isRunning && timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
        
        if (timeLeft == 0) {
          _timer?.cancel();
          setState(() {
            isRunning = false;
          });
          widget.onComplete();
        }
      }
    });
  }

  void _toggleTimer() {
    setState(() {
      isRunning = !isRunning;
    });
    
    if (isRunning) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
  }

  void _addTime(int seconds) {
    setState(() {
      timeLeft = (timeLeft + seconds).clamp(0, widget.initialSeconds + 60);
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double _getProgressPercentage() {
    if (widget.initialSeconds == 0) return 0.0;
    return (widget.initialSeconds - timeLeft) / widget.initialSeconds;
  }

  Color _getTimerColor() {
    final percentage = timeLeft / widget.initialSeconds;
    if (percentage > 0.5) return Colors.green;
    if (percentage > 0.25) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive && timeLeft == 0) {
      return const SizedBox.shrink();
    }

    final timerColor = _getTimerColor();
    final shouldPulse = timeLeft <= 10;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: timerColor,
                width: 3,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    timerColor.withOpacity(0.1),
                    timerColor.withOpacity(0.05),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Timer Display
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time,
                                color: timerColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Rest Time',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Large Timer Display
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: shouldPulse ? 52 : 48,
                              fontWeight: FontWeight.bold,
                              color: timerColor,
                              fontFamily: 'monospace',
                            ),
                            child: Text(_formatTime(timeLeft)),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Progress Bar
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey.shade300,
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _getProgressPercentage(),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: timerColor,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Circular Progress
                    SizedBox(
                      height: 80,
                      width: 80,
                      child: Stack(
                        children: [
                          CircularProgressIndicator(
                            value: _getProgressPercentage(),
                            strokeWidth: 6,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                          ),
                          Center(
                            child: Text(
                              _formatTime(timeLeft),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: timerColor,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Status Text
                    Text(
                      timeLeft > 0 ? 'Ready for next set!' : 'Take your time to recover',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: timerColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Control Buttons
                    Column(
                      children: [
                        // Play/Pause and +30s
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _toggleTimer,
                              icon: Icon(
                                isRunning ? Icons.pause : Icons.play_arrow,
                                size: 18,
                              ),
                              label: Text(isRunning ? 'Pause' : 'Resume'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                            ),
                            
                            OutlinedButton.icon(
                              onPressed: () => _addTime(30),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('+30s'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Done and Skip buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: widget.onComplete,
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Done Resting'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: widget.onSkip,
                                icon: const Icon(Icons.skip_next, size: 18),
                                label: const Text('Skip Rest'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}