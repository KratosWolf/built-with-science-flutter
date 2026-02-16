import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../services/theme_service.dart';
import '../models/user_stats.dart';
import '../widgets/profile_widgets.dart';
import 'program_selection_screen.dart';

/// Complete Profile Screen with user stats, settings, and actions
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// Load user profile and statistics from Supabase
  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final profile = await SupabaseService.instance.getUserProfile();

      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar perfil: $e';
        _isLoading = false;
        // Use mock profile on error
        _userProfile = UserProfile.mock();
      });
      debugPrint('❌ Error loading profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserProfile,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Error Message (if any)
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.orange.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Usando dados de exemplo',
                                style: TextStyle(color: Colors.orange.shade900),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Profile Header
                    if (_userProfile != null) ProfileHeader(profile: _userProfile!),

                    const SizedBox(height: 20),

                    // Statistics Card
                    if (_userProfile != null) StatsCard(stats: _userProfile!.stats),

                    const SizedBox(height: 20),

                    // Theme Toggle Section
                    Consumer<ThemeService>(
                      builder: (context, themeService, child) => Container(
                        width: double.infinity,
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
                                  themeService.isDark ? Icons.dark_mode : Icons.light_mode,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Tema',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SegmentedButton<ThemeMode>(
                              segments: const [
                                ButtonSegment(
                                  value: ThemeMode.light,
                                  label: Text('Light'),
                                  icon: Icon(Icons.light_mode, size: 18),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.dark,
                                  label: Text('Dark'),
                                  icon: Icon(Icons.dark_mode, size: 18),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.system,
                                  label: Text('Auto'),
                                  icon: Icon(Icons.brightness_auto, size: 18),
                                ),
                              ],
                              selected: {themeService.themeMode},
                              onSelectionChanged: (Set<ThemeMode> newSelection) {
                                themeService.setThemeMode(newSelection.first);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Settings Section (Placeholder)
                    const SettingsSection(
                      notificationsEnabled: false,
                    ),

                    const SizedBox(height: 20),

                    // Quick Actions Section
                    Container(
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
                          // Section Title
                          Row(
                            children: [
                              Icon(
                                Icons.settings_applications,
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Ações Rápidas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Change Program Button
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.swap_horiz,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 28,
                            ),
                            title: const Text(
                              'Trocar Programa',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: const Text('Alterar entre 3-day, 4-day ou 5-day'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProgramSelectionScreen(),
                                ),
                              );
                            },
                          ),

                          const Divider(),

                          // Backup Button (as ListTile)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.backup,
                              color: Theme.of(context).colorScheme.primary,
                              size: 28,
                            ),
                            title: const Text(
                              'Backup & Restauração',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: const Text('Salvar e restaurar seus dados'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.pushNamed(context, '/backup'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Auth Status & Actions
                    if (SupabaseService.instance.isLoggedIn) ...[
                      // Logged In Status
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.cloud_done, color: Colors.green.shade600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Conectado à nuvem',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  Text(
                                    SupabaseService.instance.currentUser?.email ?? '',
                                    style: TextStyle(
                                      color: Colors.green.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Logout & Delete Actions
                      ActionsSection(
                        onLogout: _handleLogout,
                        onDeleteAccount: _handleDeleteAccount,
                      ),
                    ] else ...[
                      // Offline Mode Status
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.phone_android, color: Colors.orange.shade600),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Modo offline - dados salvos apenas no celular',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                          },
                          icon: const Icon(Icons.login),
                          label: const Text('Fazer Login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Back Button
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Voltar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Version Info
                    Center(
                      child: Text(
                        'Versão 5.10 - Build 20251123-EMOJI 🚀',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  /// Handle logout action
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fazer Logout'),
        content: const Text(
          'Seus dados locais serão mantidos. Você pode fazer login novamente a qualquer momento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await SupabaseService.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  /// Handle delete account action
  Future<void> _handleDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: const Text(
          'ATENÇÃO: Esta ação é irreversível! Todos os seus dados serão permanentemente excluídos.\n\nDeseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // TODO: Implement account deletion in Supabase
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funcionalidade em desenvolvimento'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
