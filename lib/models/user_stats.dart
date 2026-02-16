/// Model for user statistics and profile data
class UserStats {
  final int totalWorkouts;
  final int currentStreak;
  final int bestStreak;
  final double totalVolumeKg;
  final double weeklyAverage;
  final DateTime? lastWorkoutDate;
  final DateTime? memberSince;

  UserStats({
    required this.totalWorkouts,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalVolumeKg,
    required this.weeklyAverage,
    this.lastWorkoutDate,
    this.memberSince,
  });

  /// Create UserStats from JSON (from Supabase)
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalWorkouts: json['total_workouts'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      bestStreak: json['best_streak'] ?? 0,
      totalVolumeKg: (json['total_volume_kg'] ?? 0).toDouble(),
      weeklyAverage: (json['weekly_average'] ?? 0).toDouble(),
      lastWorkoutDate: json['last_workout_date'] != null
          ? DateTime.parse(json['last_workout_date'])
          : null,
      memberSince: json['member_since'] != null
          ? DateTime.parse(json['member_since'])
          : null,
    );
  }

  /// Convert to JSON (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'total_workouts': totalWorkouts,
      'current_streak': currentStreak,
      'best_streak': bestStreak,
      'total_volume_kg': totalVolumeKg,
      'weekly_average': weeklyAverage,
      'last_workout_date': lastWorkoutDate?.toIso8601String(),
      'member_since': memberSince?.toIso8601String(),
    };
  }

  /// Create empty stats (for placeholder/offline mode)
  factory UserStats.empty() {
    return UserStats(
      totalWorkouts: 0,
      currentStreak: 0,
      bestStreak: 0,
      totalVolumeKg: 0.0,
      weeklyAverage: 0.0,
      lastWorkoutDate: null,
      memberSince: DateTime.now(),
    );
  }

  /// Create mock stats for testing
  factory UserStats.mock() {
    return UserStats(
      totalWorkouts: 48,
      currentStreak: 7,
      bestStreak: 12,
      totalVolumeKg: 12450.5,
      weeklyAverage: 3.2,
      lastWorkoutDate: DateTime.now().subtract(const Duration(days: 1)),
      memberSince: DateTime.now().subtract(const Duration(days: 90)),
    );
  }

  /// Format total volume for display
  String get formattedVolume {
    if (totalVolumeKg >= 1000) {
      return '${(totalVolumeKg / 1000).toStringAsFixed(1)}t';
    }
    return '${totalVolumeKg.toStringAsFixed(0)}kg';
  }

  /// Format weekly average for display
  String get formattedWeeklyAverage {
    return weeklyAverage.toStringAsFixed(1);
  }
}

/// Model for user profile data
class UserProfile {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;
  final UserStats stats;

  UserProfile({
    this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.createdAt,
    required this.stats,
  });

  /// Get first name from display name
  String get firstName {
    if (displayName == null || displayName!.isEmpty) return 'Usuário';
    return displayName!.split(' ').first;
  }

  /// Get initials for avatar placeholder
  String get initials {
    if (displayName == null || displayName!.isEmpty) return 'U';
    final names = displayName!.split(' ');
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  /// Create from Supabase user data
  factory UserProfile.fromSupabase({
    required String? uid,
    required String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    UserStats? stats,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: createdAt,
      stats: stats ?? UserStats.empty(),
    );
  }

  /// Create mock profile for testing
  factory UserProfile.mock() {
    return UserProfile(
      uid: 'mock-uid-123',
      email: 'tiago@example.com',
      displayName: 'Tiago Fernandes',
      photoUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      stats: UserStats.mock(),
    );
  }
}
