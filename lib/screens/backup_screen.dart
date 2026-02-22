import 'package:flutter/material.dart';
import '../services/backup_service.dart';
import '../config/theme.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isLoading = false;
  String? _message;
  Map<String, dynamic>? _backupInfo;

  @override
  void initState() {
    super.initState();
    _loadBackupInfo();
  }

  Future<void> _loadBackupInfo() async {
    final info = await BackupService.instance.getBackupInfo();
    setState(() {
      _backupInfo = info;
    });
  }

  Future<void> _exportData() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final filePath = await BackupService.instance.exportData();
      
      if (filePath != null) {
        setState(() {
          _message = 'Backup exportado com sucesso!\n\nArquivo salvo em:\n$filePath';
        });
        
        // Show success dialog
        _showSuccessDialog(
          'Export Realizado!',
          'Seus dados foram exportados com sucesso.\n\nO arquivo está salvo na pasta de downloads do seu dispositivo.',
        );
      } else {
        setState(() {
          _message = 'Erro: Nenhum dado encontrado para exportar.';
        });
      }
    } catch (error) {
      setState(() {
        _message = 'Erro no export: ${error.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _importData() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      // For now, we'll need file picker - simplified approach
      _showInfoDialog(
        'Import de Dados',
        'Para importar seus dados:\n\n1. Coloque o arquivo de backup na pasta Downloads\n2. O arquivo deve ter nome como "built_with_science_backup_*.json"\n3. Clique em "Confirmar Import"',
        showImportButton: true,
      );
    } catch (error) {
      setState(() {
        _message = 'Erro no import: ${error.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _performImport() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      // This is a simplified approach - look for backup files in downloads
      // In a real implementation, you'd use file_picker package
      _showInfoDialog(
        'Import Manual',
        'Funcionalidade de import será implementada na próxima versão.\n\nPor enquanto, certifique-se de fazer backup regularmente!',
      );
    } catch (error) {
      setState(() {
        _message = 'Erro no import: ${error.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundCard,
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.success, size: 28),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(color: AppTheme.textPrimary)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: AppTheme.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: AppTheme.primaryOrange)),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message, {bool showImportButton = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundCard,
        title: Text(title, style: const TextStyle(color: AppTheme.textPrimary)),
        content: Text(message, style: const TextStyle(color: AppTheme.textPrimary)),
        actions: [
          if (showImportButton)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performImport();
              },
              child: const Text('Confirmar Import', style: TextStyle(color: AppTheme.primaryOrange)),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              showImportButton ? 'Cancelar' : 'OK',
              style: TextStyle(color: showImportButton ? AppTheme.textSecondary : AppTheme.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restauração'),
        backgroundColor: AppTheme.backgroundPrimary,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.backgroundCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryOrange.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryOrange,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Sistema de Backup',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mantenha seus dados de treino seguros! '
                    'Exporte seus dados regularmente para não perder seu progresso.',
                    style: TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Backup Info
            if (_backupInfo != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dados Atuais:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Total de dados:', '${_backupInfo!['total_keys']} itens'),
                    _buildInfoRow('Sessões de treino:', '${_backupInfo!['workout_sessions']}'),
                    _buildInfoRow('Programas com dados:', '${_backupInfo!['programs_with_data']}'),
                    _buildInfoRow('Status:', _backupInfo!['has_data'] ? 'Dados disponíveis ✅' : 'Sem dados ❌'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _exportData,
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.textPrimary),
                      )
                    : const Icon(Icons.backup, size: 28),
                label: Text(
                  _isLoading ? 'Exportando...' : 'EXPORTAR DADOS',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: AppTheme.textPrimary,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _importData,
                icon: const Icon(Icons.restore, size: 28),
                label: const Text(
                  'IMPORTAR DADOS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.backgroundElevated,
                  foregroundColor: AppTheme.textPrimary,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppTheme.primaryOrange, width: 1.5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Message Display
            if (_message != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _message!.contains('sucesso') ? AppTheme.success : AppTheme.error,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _message!.contains('sucesso') ? Icons.check_circle : Icons.error,
                      color: _message!.contains('sucesso') ? AppTheme.success : AppTheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _message!,
                        style: TextStyle(
                          color: _message!.contains('sucesso') ? AppTheme.success : AppTheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Spacer(),

            // Help Text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryOrange.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.help_outline, color: AppTheme.primaryOrange),
                      SizedBox(width: 8),
                      Text(
                        'Dicas:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Faça backup regularmente\n'
                    '• Guarde os arquivos em local seguro\n'
                    '• Use para transferir dados entre celulares\n'
                    '• O arquivo contém todos os seus treinos',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}