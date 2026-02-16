import 'package:flutter/material.dart';
import '../models/user_stats.dart';

/// Profile header widget showing user photo, name and email
class ProfileHeader extends StatelessWidget {
  final UserProfile profile;

  const ProfileHeader({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Photo/Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: profile.photoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          profile.photoUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildInitialsAvatar(context);
                          },
                        ),
                      )
                    : _buildInitialsAvatar(context),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // User Name
          Text(
            profile.displayName ?? 'Usuário',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          // User Email
          Text(
            profile.email ?? 'email@exemplo.com',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),

          const SizedBox(height: 8),

          // Member Since
          if (profile.createdAt != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(width: 6),
                Text(
                  'Membro desde ${_formatMemberSince(profile.createdAt!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(BuildContext context) {
    return Text(
      profile.initials,
      style: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  String _formatMemberSince(DateTime date) {
    final months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

/// Statistics card widget showing user workout stats
class StatsCard extends StatelessWidget {
  final UserStats stats;

  const StatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Estatísticas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatItem(
                context,
                icon: Icons.fitness_center,
                value: stats.totalWorkouts.toString(),
                label: 'Treinos',
                color: Theme.of(context).colorScheme.primary,
              ),
              _buildStatItem(
                context,
                icon: Icons.local_fire_department,
                value: stats.currentStreak.toString(),
                label: 'Sequência',
                color: Colors.orange,
              ),
              _buildStatItem(
                context,
                icon: Icons.trending_up,
                value: stats.formattedVolume,
                label: 'Volume Total',
                color: Theme.of(context).colorScheme.secondary,
              ),
              _buildStatItem(
                context,
                icon: Icons.calendar_today,
                value: '${stats.formattedWeeklyAverage}/sem',
                label: 'Média Semanal',
                color: Colors.blue,
              ),
              _buildStatItem(
                context,
                icon: Icons.emoji_events,
                value: stats.bestStreak.toString(),
                label: 'Melhor Sequência',
                color: Colors.amber,
              ),
              _buildStatItem(
                context,
                icon: Icons.schedule,
                value: _formatLastWorkout(stats.lastWorkoutDate),
                label: 'Último Treino',
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatLastWorkout(DateTime? date) {
    if (date == null) return 'Nunca';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Hoje';
    if (difference.inDays == 1) return 'Ontem';
    if (difference.inDays < 7) return '${difference.inDays}d atrás';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}sem';
    return '${(difference.inDays / 30).floor()}m';
  }
}

/// Settings section widget
class SettingsSection extends StatelessWidget {
  final VoidCallback? onNotificationsToggle;
  final VoidCallback? onLanguageChange;
  final bool notificationsEnabled;

  const SettingsSection({
    super.key,
    this.onNotificationsToggle,
    this.onLanguageChange,
    this.notificationsEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Configurações',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Notifications (Placeholder)
          _buildSettingItem(
            context,
            icon: Icons.notifications,
            title: 'Notificações',
            subtitle: 'Em breve',
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: null, // Disabled for now
            ),
          ),

          const Divider(height: 24),

          // Language (Placeholder)
          _buildSettingItem(
            context,
            icon: Icons.language,
            title: 'Idioma',
            subtitle: 'Português',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: null, // Disabled for now
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

/// Actions section widget (Logout, Delete Account)
class ActionsSection extends StatelessWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onDeleteAccount;

  const ActionsSection({
    super.key,
    this.onLogout,
    this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logout Button
          if (onLogout != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Fazer Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

          if (onDeleteAccount != null) ...[
            const SizedBox(height: 12),

            // Delete Account Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onDeleteAccount,
                icon: const Icon(Icons.delete_forever),
                label: const Text('Excluir Conta'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade700),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
