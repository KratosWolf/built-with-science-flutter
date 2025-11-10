import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout_models.dart';
import '../services/supabase_service.dart';

/// Statistics Screen - Track progress and workout analytics  
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  
  bool _isLoading = true;
  String? _error;
  
  // Statistics data
  int _totalWorkouts = 0;
  int _totalSets = 0;
  double _totalVolumeKg = 0.0;
  int _currentStreak = 0;
  List<PersonalRecord> _recentPRs = [];
  Map<String, double> _exerciseProgress = {};
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadStatistics();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // TODO: Load statistics from Supabase when implemented
      final stats = <String, dynamic>{}; // SupabaseService.getUserStatistics();
      final recentPRs = <PersonalRecord>[]; // SupabaseService.getRecentPersonalRecords(limit: 5);
      final exerciseProgress = <String, double>{}; // SupabaseService.getExerciseProgressOverTime();

      setState(() {
        _totalWorkouts = stats['total_workouts'] ?? 0;
        _totalSets = stats['total_sets'] ?? 0;
        _totalVolumeKg = (stats['total_volume_kg'] ?? 0.0).toDouble();
        _currentStreak = stats['current_streak'] ?? 0;
        _recentPRs = recentPRs;
        _exerciseProgress = exerciseProgress;
        _isLoading = false;
      });
      
      _animationController.forward();
      
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _refresh() {
    HapticFeedback.lightImpact();
    _loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Your Progress',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Statistics',
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading your progress...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header stats
                    _buildHeaderStats(),
                    
                    const SizedBox(height: 24),
                    
                    // Personal Records section
                    _buildPersonalRecordsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Exercise progress section
                    _buildExerciseProgressSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Motivational section
                    _buildMotivationalSection(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderStats() {
    final stats = [
      StatCard(
        title: 'Total Workouts',
        value: _totalWorkouts.toString(),
        icon: Icons.fitness_center,
        color: Colors.blue,
      ),
      StatCard(
        title: 'Total Sets',
        value: _totalSets.toString(),
        icon: Icons.repeat,
        color: Colors.green,
      ),
      StatCard(
        title: 'Total Volume',
        value: '${(_totalVolumeKg / 1000).toStringAsFixed(1)}t',
        icon: Icons.trending_up,
        color: Colors.orange,
      ),
      StatCard(
        title: 'Current Streak',
        value: '$_currentStreak days',
        icon: Icons.local_fire_department,
        color: Colors.red,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + (index * 200)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        stat.color.withOpacity(0.1),
                        Colors.white,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: stat.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          stat.icon,
                          color: stat.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        stat.value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stat.title,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPersonalRecordsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.emoji_events,
              color: Colors.amber.shade600,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Recent Personal Records',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        if (_recentPRs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 48,
                  color: Colors.blue.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'No PRs yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep training to set your first personal record!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...List.generate(_recentPRs.length, (index) {
            final pr = _recentPRs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 800 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(50 * (1 - value), 0),
                    child: Opacity(
                      opacity: value,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.emoji_events,
                              color: Colors.amber.shade600,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            pr.exerciseName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${pr.weightKg}kg × ${pr.reps} reps',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'NEW PR!',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade600,
                                ),
                              ),
                              Text(
                                _formatDate(pr.achievedAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
      ],
    );
  }

  Widget _buildExerciseProgressSection() {
    if (_exerciseProgress.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.show_chart,
              color: Colors.purple.shade600,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Exercise Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        ..._exerciseProgress.entries.map((entry) {
          final exerciseName = entry.key;
          final progressPercent = entry.value.clamp(0.0, 1.0);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exerciseName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progressPercent,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.purple.shade400,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '+${(progressPercent * 100).round()}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMotivationalSection() {
    final messages = [
      'Every rep counts toward your goal! 💪',
      'Consistency is the key to success! 🔥',
      'You\'re stronger than you were yesterday! 📈',
      'Science-based training delivers results! 🧪',
      'Keep pushing your limits! 🚀',
    ];
    
    final randomMessage = messages[DateTime.now().millisecond % messages.length];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 12),
          const Text(
            'Keep It Up!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            randomMessage,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference}d ago';
    
    return '${date.day}/${date.month}';
  }
}

/// Data model for stat cards
class StatCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}