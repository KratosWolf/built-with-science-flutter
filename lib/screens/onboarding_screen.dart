import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'program_selection_screen.dart';

/// Onboarding Screen - Welcome and introduction to the app
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  late AnimationController _animationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    HapticFeedback.lightImpact();
    
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    HapticFeedback.mediumImpact();
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    // Mark onboarding as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ProgramSelectionScreen(),
        ),
      );
    }
  }

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Welcome to\nBuilt With Science',
      description: 'Science-based workout programs designed for maximum muscle growth and strength development.',
      image: Icons.fitness_center,
      color: Colors.blue,
      backgroundColor: Colors.blue.shade50,
    ),
    OnboardingData(
      title: 'Smart Progression\nSystem',
      description: 'Our AI-powered system automatically suggests weight and rep progressions based on your performance.',
      image: Icons.trending_up,
      color: Colors.green,
      backgroundColor: Colors.green.shade50,
    ),
    OnboardingData(
      title: 'Track Every Set\n& Rep',
      description: 'Log your workouts with precision. Track weight, reps, difficulty, and rest times for optimal results.',
      image: Icons.analytics,
      color: Colors.orange,
      backgroundColor: Colors.orange.shade50,
    ),
    OnboardingData(
      title: 'Video Guidance\n& Form Tips',
      description: 'Access exercise tutorials and form guidance to ensure you\'re performing every movement correctly.',
      image: Icons.play_circle_outline,
      color: Colors.purple,
      backgroundColor: Colors.purple.shade50,
    ),
    OnboardingData(
      title: 'Ready to Build\nYour Best Physique?',
      description: 'Choose a program that fits your experience level and start your transformation journey today.',
      image: Icons.rocket_launch,
      color: Colors.red,
      backgroundColor: Colors.red.shade50,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _onboardingData[_currentPage].backgroundColor,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: _onboardingData[_currentPage].color,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Page indicator
              Container(
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: List.generate(
                    _onboardingData.length,
                    (index) => Expanded(
                      child: Container(
                        height: 8,
                        margin: EdgeInsets.only(
                          right: index < _onboardingData.length - 1 ? 8 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: index <= _currentPage
                            ? _onboardingData[_currentPage].color
                            : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    _animationController.reset();
                    _animationController.forward();
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    final data = _onboardingData[index];
                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: data.color.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: data.color.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      data.image,
                                      size: 60,
                                      color: data.color,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 48),
                                  
                                  // Title
                                  Text(
                                    data.title,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Description
                                  Text(
                                    data.description,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade700,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              
              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  children: [
                    // Previous button
                    if (_currentPage > 0) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _previousPage,
                          icon: const Icon(Icons.arrow_back, size: 20),
                          label: const Text('Previous'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: _onboardingData[_currentPage].color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    
                    // Next/Get Started button
                    Expanded(
                      flex: _currentPage > 0 ? 1 : 2,
                      child: AnimatedBuilder(
                        animation: _buttonScaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _buttonScaleAnimation.value,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _buttonAnimationController.forward().then((_) {
                                  _buttonAnimationController.reverse();
                                  _nextPage();
                                });
                              },
                              icon: Icon(
                                _currentPage < _onboardingData.length - 1
                                  ? Icons.arrow_forward
                                  : Icons.rocket_launch,
                                size: 20,
                              ),
                              label: Text(
                                _currentPage < _onboardingData.length - 1
                                  ? 'Next'
                                  : 'Get Started',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _onboardingData[_currentPage].color,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Data model for onboarding pages
class OnboardingData {
  final String title;
  final String description;
  final IconData image;
  final Color color;
  final Color backgroundColor;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
    required this.backgroundColor,
  });
}