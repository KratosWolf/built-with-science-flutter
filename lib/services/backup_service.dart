import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class BackupService {
  static BackupService? _instance;
  static BackupService get instance => _instance ??= BackupService._();
  
  BackupService._();

  /// Export all workout data to JSON file
  Future<String?> exportData() async {
    try {
      print('🔄 Iniciando export dos dados...');
      
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      // Filter only workout-related keys
      final workoutKeys = keys.where((key) => 
        key.startsWith('workout_session_') ||
        key.startsWith('last_workout_') ||
        key.startsWith('program_') ||
        key.contains('exercise_') ||
        key.contains('set_') ||
        key.contains('weight_') ||
        key.contains('reps_') ||
        key.contains('difficulty_')
      ).toList();
      
      if (workoutKeys.isEmpty) {
        print('⚠️ Nenhum dado de treino encontrado');
        return null;
      }
      
      // Create backup data structure
      final Map<String, dynamic> backupData = {
        'version': '2.0',
        'exported_at': DateTime.now().toIso8601String(),
        'app_name': 'Built With Science',
        'total_keys': workoutKeys.length,
        'data': <String, dynamic>{},
      };
      
      // Export all workout data
      final Map<String, dynamic> dataMap = backupData['data'] as Map<String, dynamic>;
      for (final key in workoutKeys) {
        final value = prefs.get(key);
        if (value != null) {
          dataMap[key] = value;
        }
      }
      
      // Convert to JSON
      final jsonData = jsonEncode(backupData);
      
      // Save to Downloads folder
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Não foi possível acessar o armazenamento externo');
      }
      
      final fileName = 'built_with_science_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonData);
      
      print('✅ Export realizado com sucesso: ${file.path}');
      print('📊 Total de ${workoutKeys.length} chaves exportadas');
      
      return file.path;
      
    } catch (error) {
      print('❌ Erro no export: $error');
      return null;
    }
  }

  /// Import workout data from JSON file
  Future<bool> importData(String filePath) async {
    try {
      print('🔄 Iniciando import dos dados...');
      
      final file = File(filePath);
      if (!await file.exists()) {
        print('❌ Arquivo não encontrado: $filePath');
        return false;
      }
      
      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate backup format
      if (!backupData.containsKey('version') || 
          !backupData.containsKey('data') ||
          !backupData.containsKey('app_name')) {
        print('❌ Formato de backup inválido');
        return false;
      }
      
      if (backupData['app_name'] != 'Built With Science') {
        print('❌ Backup não é do Built With Science app');
        return false;
      }
      
      final data = backupData['data'] as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();
      
      // Import all data
      int importedCount = 0;
      for (final entry in data.entries) {
        final key = entry.key;
        final value = entry.value;
        
        if (value is String) {
          await prefs.setString(key, value);
          importedCount++;
        } else if (value is int) {
          await prefs.setInt(key, value);
          importedCount++;
        } else if (value is double) {
          await prefs.setDouble(key, value);
          importedCount++;
        } else if (value is bool) {
          await prefs.setBool(key, value);
          importedCount++;
        } else if (value is List<String>) {
          await prefs.setStringList(key, value);
          importedCount++;
        }
      }
      
      print('✅ Import realizado com sucesso');
      print('📊 Total de $importedCount chaves importadas');
      print('📅 Backup de: ${backupData['exported_at']}');
      
      return true;
      
    } catch (error) {
      print('❌ Erro no import: $error');
      return false;
    }
  }

  /// Get backup summary information
  Future<Map<String, dynamic>> getBackupInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      final workoutKeys = keys.where((key) => 
        key.startsWith('workout_session_') ||
        key.startsWith('last_workout_') ||
        key.startsWith('program_') ||
        key.contains('exercise_') ||
        key.contains('set_') ||
        key.contains('weight_') ||
        key.contains('reps_') ||
        key.contains('difficulty_')
      ).toList();
      
      // Count workout sessions
      final sessionKeys = keys.where((key) => key.startsWith('workout_session_')).toList();
      
      // Get programs with data
      final programsWithData = <int>{};
      for (final key in workoutKeys) {
        final parts = key.split('_');
        if (parts.length >= 3) {
          try {
            final programId = int.tryParse(parts[2]);
            if (programId != null) {
              programsWithData.add(programId);
            }
          } catch (e) {
            // Ignore parsing errors
          }
        }
      }
      
      return {
        'total_keys': workoutKeys.length,
        'workout_sessions': sessionKeys.length,
        'programs_with_data': programsWithData.length,
        'has_data': workoutKeys.isNotEmpty,
        'last_updated': DateTime.now().toIso8601String(),
      };
      
    } catch (error) {
      print('❌ Erro ao obter info do backup: $error');
      return {
        'total_keys': 0,
        'workout_sessions': 0,
        'programs_with_data': 0,
        'has_data': false,
        'error': error.toString(),
      };
    }
  }

  /// Clear all workout data (use with caution)
  Future<bool> clearAllData() async {
    try {
      print('🔄 Limpando todos os dados de treino...');
      
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      final workoutKeys = keys.where((key) => 
        key.startsWith('workout_session_') ||
        key.startsWith('last_workout_') ||
        key.startsWith('program_') ||
        key.contains('exercise_') ||
        key.contains('set_') ||
        key.contains('weight_') ||
        key.contains('reps_') ||
        key.contains('difficulty_')
      ).toList();
      
      for (final key in workoutKeys) {
        await prefs.remove(key);
      }
      
      print('✅ ${workoutKeys.length} chaves de treino removidas');
      return true;
      
    } catch (error) {
      print('❌ Erro ao limpar dados: $error');
      return false;
    }
  }
}