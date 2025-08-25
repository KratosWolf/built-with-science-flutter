import 'package:flutter/material.dart';
import "supabase_service.dart";
import '../models/workout_models.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  WorkoutUser? _userProfile;
  final _displayNameController = TextEditingController();
  String _selectedUnit = 'kg';
  String _selectedAggressiveness = 'standard';
  String _selectedVideoPref = 'smart';
  Map<String, dynamic> _dashboardStats = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadDashboardStats();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await // SupabaseService.getUserProfile();
      if (profile != null && mounted) {
        setState(() {
          _userProfile = profile;
          _displayNameController.text = profile.displayName ?? '';
          _selectedUnit = profile.unit;
          _selectedAggressiveness = profile.suggestionAggressiveness;
          _selectedVideoPref = profile.videoPref;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _loadDashboardStats() async {
    try {
      final stats = await // SupabaseService.getDashboardStats();
      if (mounted) {
        setState(() {
          _dashboardStats = stats;
        });
      }
    } catch (e) {
      // Stats are optional, don't show error
    }
  }

  Future<void> _updateProfile() async {
    try {
      await // SupabaseService.createOrUpdateUserProfile(
        displayName: _displayNameController.text.trim().isEmpty 
            ? null 
            : _displayNameController.text.trim(),
        unit: _selectedUnit,
        suggestionAggressiveness: _selectedAggressiveness,
        videoPref: _selectedVideoPref,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadProfile(); // Refresh profile
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await // SupabaseService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                child: Icon(
                                  Icons.person,
                                  size: 32,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _userProfile?.displayName ?? 'User',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _userProfile?.email ?? 'Anonymous User',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Workout Stats Card
                  if (_dashboardStats.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Workout Stats',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _StatItem(
                                    label: 'Total Sessions',
                                    value: '${_dashboardStats['total_sessions'] ?? 0}',
                                    icon: Icons.fitness_center,
                                  ),
                                ),
                                Expanded(
                                  child: _StatItem(
                                    label: 'Completed',
                                    value: '${_dashboardStats['completed_sessions'] ?? 0}',
                                    icon: Icons.check_circle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _StatItem(
                              label: 'Completion Rate',
                              value: '${(_dashboardStats['completion_rate'] ?? 0).toInt()}%',
                              icon: Icons.trending_up,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Settings Section
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display Name
                          TextFormField(
                            controller: _displayNameController,
                            decoration: const InputDecoration(
                              labelText: 'Display Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Unit Selection
                          const Text(
                            'Weight Unit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('kg'),
                                  value: 'kg',
                                  groupValue: _selectedUnit,
                                  onChanged: (value) => setState(() => _selectedUnit = value!),
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('lb'),
                                  value: 'lb',
                                  groupValue: _selectedUnit,
                                  onChanged: (value) => setState(() => _selectedUnit = value!),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Progression Aggressiveness
                          const Text(
                            'Progression Style',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedAggressiveness,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'conservative', child: Text('Conservative')),
                              DropdownMenuItem(value: 'standard', child: Text('Standard')),
                              DropdownMenuItem(value: 'aggressive', child: Text('Aggressive')),
                            ],
                            onChanged: (value) => setState(() => _selectedAggressiveness = value!),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Video Preference
                          const Text(
                            'Video Preference',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedVideoPref,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'youtube', child: Text('Always YouTube')),
                              DropdownMenuItem(value: 'guide', child: Text('Text Guide Only')),
                              DropdownMenuItem(value: 'smart', child: Text('Smart (Both)')),
                            ],
                            onChanged: (value) => setState(() => _selectedVideoPref = value!),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Update Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _updateProfile,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text(
                                'Update Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _signOut,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}