import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_models.dart';
import 'supabase_service.dart';

/// Serviço de sincronização robusta com pending queue
///
/// Gerencia fila de sets pendentes que falharam em sincronizar com o Supabase.
/// Implementa retry automático ao finalizar treino e no startup do app.
class SyncService {
  static SyncService? _instance;
  static SyncService get instance => _instance ??= SyncService._();

  SyncService._();

  static const String _pendingQueueKey = 'pending_sync_sets';
  final _uuid = const Uuid();

  /// Adiciona um set à fila de sincronização pendente
  ///
  /// Chamado quando saveWorkoutSet() falha (timeout, sem internet, erro)
  Future<void> addToPendingQueue({
    required WorkoutSet setData,
    required int programId,
    required int dayId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Obter fila atual
      final queue = await getPendingQueue();

      // Criar item da fila com ID único local
      final queueItem = {
        'id': _uuid.v4(), // UUID local para controle
        'setData': {
          'sessionId': setData.sessionId,
          'exerciseId': setData.exerciseId,
          'setNumber': setData.setNumber,
          'weightKg': setData.weightKg,
          'reps': setData.reps,
          'difficulty': setData.difficulty,
        },
        'programId': programId,
        'dayId': dayId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Adicionar à fila
      queue.add(queueItem);

      // Salvar fila atualizada
      final jsonString = jsonEncode(queue);
      await prefs.setString(_pendingQueueKey, jsonString);

      debugPrint('⏳ Set adicionado à fila pendente (${queue.length} total)');
      debugPrint('   → Ex${setData.exerciseId} Set${setData.setNumber} - ${setData.weightKg}kg x ${setData.reps}reps');

    } catch (error) {
      debugPrint('❌ Erro ao adicionar à fila pendente: $error');
    }
  }

  /// Retorna lista de sets pendentes de sincronização
  Future<List<Map<String, dynamic>>> getPendingQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_pendingQueueKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => item as Map<String, dynamic>).toList();

    } catch (error) {
      debugPrint('❌ Erro ao ler fila pendente: $error');
      return [];
    }
  }

  /// Remove um set específico da fila (após sincronização bem-sucedida)
  Future<void> clearFromQueue(String setId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queue = await getPendingQueue();

      // Remover item com o ID específico
      queue.removeWhere((item) => item['id'] == setId);

      // Salvar fila atualizada
      if (queue.isEmpty) {
        await prefs.remove(_pendingQueueKey);
        debugPrint('✅ Fila pendente vazia - removida do storage');
      } else {
        final jsonString = jsonEncode(queue);
        await prefs.setString(_pendingQueueKey, jsonString);
        debugPrint('✅ Set removido da fila (${queue.length} restantes)');
      }

    } catch (error) {
      debugPrint('❌ Erro ao remover da fila: $error');
    }
  }

  /// Tenta sincronizar todos os sets pendentes com o Supabase
  ///
  /// Retorna mapa com contadores: {synced: N, failed: M}
  ///
  /// - synced: número de sets sincronizados com sucesso
  /// - failed: número de sets que ainda falharam (ficam na fila para retry)
  Future<Map<String, int>> syncPendingQueue() async {
    int syncedCount = 0;
    int failedCount = 0;

    try {
      // Verificar se está logado
      if (!SupabaseService.instance.isLoggedIn) {
        debugPrint('⏸️ Sync pendente: usuário não logado');
        final queue = await getPendingQueue();
        return {'synced': 0, 'failed': queue.length};
      }

      final queue = await getPendingQueue();

      if (queue.isEmpty) {
        debugPrint('✅ Fila de sync vazia - nada a sincronizar');
        return {'synced': 0, 'failed': 0};
      }

      debugPrint('🔄 Iniciando sync de ${queue.length} sets pendentes...');

      // Tentar sincronizar cada item da fila
      final itemsToRemove = <String>[];

      for (final item in queue) {
        try {
          final setDataMap = item['setData'] as Map<String, dynamic>;
          final programId = item['programId'] as int;
          final dayId = item['dayId'] as int;
          final queueItemId = item['id'] as String;

          // Reconstruir WorkoutSet a partir dos dados salvos
          final workoutSet = WorkoutSet(
            sessionId: setDataMap['sessionId'] as int,
            exerciseId: setDataMap['exerciseId'] as int,
            setNumber: setDataMap['setNumber'] as int,
            weightKg: (setDataMap['weightKg'] as num?)?.toDouble(),
            reps: setDataMap['reps'] as int?,
            difficulty: setDataMap['difficulty'] as String?,
          );

          // Tentar salvar no Supabase com timeout de 10 segundos
          final success = await SupabaseService.instance.saveWorkoutSet(
            workoutSet,
            programId,
            dayId,
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () => false,
          );

          if (success) {
            // Sucesso - marcar para remoção da fila
            itemsToRemove.add(queueItemId);
            syncedCount++;
            debugPrint('   ✅ Ex${workoutSet.exerciseId} Set${workoutSet.setNumber} sincronizado');
          } else {
            // Falhou - manter na fila para próximo retry
            failedCount++;
            debugPrint('   ⚠️ Ex${workoutSet.exerciseId} Set${workoutSet.setNumber} falhou - mantido na fila');
          }

        } catch (error) {
          failedCount++;
          debugPrint('   ❌ Erro ao sincronizar item: $error');
        }
      }

      // Remover itens sincronizados da fila
      for (final itemId in itemsToRemove) {
        await clearFromQueue(itemId);
      }

      if (syncedCount > 0) {
        debugPrint('✅ Sync completo: $syncedCount sets sincronizados');
      }
      if (failedCount > 0) {
        debugPrint('⏳ $failedCount sets ainda pendentes (retry na próxima vez)');
      }

      return {'synced': syncedCount, 'failed': failedCount};

    } catch (error) {
      debugPrint('❌ Erro no sync da fila: $error');
      return {'synced': syncedCount, 'failed': failedCount};
    }
  }

  /// Retorna estatísticas da fila pendente
  Future<Map<String, dynamic>> getQueueStats() async {
    final queue = await getPendingQueue();

    if (queue.isEmpty) {
      return {
        'total': 0,
        'oldestTimestamp': null,
        'newestTimestamp': null,
      };
    }

    // Ordenar por timestamp para encontrar mais antigo e mais novo
    queue.sort((a, b) {
      final timestampA = DateTime.parse(a['timestamp'] as String);
      final timestampB = DateTime.parse(b['timestamp'] as String);
      return timestampA.compareTo(timestampB);
    });

    return {
      'total': queue.length,
      'oldestTimestamp': queue.first['timestamp'],
      'newestTimestamp': queue.last['timestamp'],
    };
  }

  /// Limpa toda a fila pendente (use com cuidado!)
  ///
  /// Útil apenas para debug ou quando usuário quer descartar sync pendente
  Future<void> clearAllPending() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingQueueKey);
      debugPrint('🗑️ Fila pendente completamente limpa');
    } catch (error) {
      debugPrint('❌ Erro ao limpar fila: $error');
    }
  }

  /// Restaura dados do Supabase para o cache local (auto-restore ao fazer login)
  ///
  /// Retorna mapa com contadores: {restored: N, skipped: M}
  ///
  /// - restored: número de exercícios restaurados do Supabase
  /// - skipped: número de exercícios mantidos (cache local mais recente)
  ///
  /// LÓGICA DE CONFLITO:
  /// - Se cache local vazio → restaurar do Supabase
  /// - Se cache existe → comparar timestamps:
  ///   - Supabase mais recente → sobrescrever cache
  ///   - Cache mais recente → manter cache (skip)
  Future<Map<String, int>> restoreFromCloud() async {
    int restoredCount = 0;
    int skippedCount = 0;

    try {
      // Verificar se está logado
      if (!SupabaseService.instance.isLoggedIn) {
        debugPrint('⏸️ Restore: usuário não logado');
        return {'restored': 0, 'skipped': 0};
      }

      debugPrint('🔄 Iniciando restore do Supabase...');

      // Buscar TODOS os workout_sets do usuário (query geral, sem filtro de programa/dia)
      final response = await SupabaseService.instance.client
          .from('workout_sets')
          .select()
          .eq('user_id', SupabaseService.instance.currentUser!.id)
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        debugPrint('ℹ️  Nenhum dado no Supabase - nada a restaurar');
        return {'restored': 0, 'skipped': 0};
      }

      debugPrint('📦 ${response.length} sets encontrados no Supabase');

      // Agrupar sets por (programId, dayId, exerciseId)
      final Map<String, List<Map<String, dynamic>>> groupedSets = {};

      for (final row in response) {
        final programId = row['program_id'] as int;
        final dayId = row['day_id'] as int;
        final exerciseId = row['exercise_id'] as int;

        final key = '${programId}_${dayId}_$exerciseId';

        if (!groupedSets.containsKey(key)) {
          groupedSets[key] = [];
        }

        groupedSets[key]!.add(row);
      }

      debugPrint('📊 ${groupedSets.length} exercícios únicos a processar');

      // Processar cada combinação (programId, dayId, exerciseId)
      final prefs = await SharedPreferences.getInstance();

      for (final entry in groupedSets.entries) {
        final keyParts = entry.key.split('_');
        final programId = int.parse(keyParts[0]);
        final dayId = int.parse(keyParts[1]);
        final exerciseId = int.parse(keyParts[2]);
        final cloudSets = entry.value;

        final cacheKey = 'last_workout_${programId}_${dayId}_$exerciseId';

        // Verificar se cache local existe
        final cachedStrings = prefs.getStringList(cacheKey);

        if (cachedStrings == null || cachedStrings.isEmpty) {
          // Cache vazio → RESTAURAR do Supabase
          await _restoreExerciseFromCloud(
            prefs,
            cacheKey,
            cloudSets,
            programId,
            dayId,
            exerciseId,
          );
          restoredCount++;
        } else {
          // Cache existe → COMPARAR timestamps
          final cacheNewest = _getNewestTimestampFromCache(cachedStrings);
          final cloudNewest = _getNewestTimestampFromCloud(cloudSets);

          if (cloudNewest != null && cacheNewest != null) {
            if (cloudNewest.isAfter(cacheNewest)) {
              // Supabase mais recente → SOBRESCREVER cache
              await _restoreExerciseFromCloud(
                prefs,
                cacheKey,
                cloudSets,
                programId,
                dayId,
                exerciseId,
              );
              restoredCount++;
              debugPrint('   📥 Ex$exerciseId restaurado (cloud mais recente)');
            } else {
              // Cache mais recente → MANTER cache (skip)
              skippedCount++;
              debugPrint('   ⏭️ Ex$exerciseId mantido (cache mais recente)');
            }
          } else {
            // Timestamps inválidos → restaurar por segurança
            await _restoreExerciseFromCloud(
              prefs,
              cacheKey,
              cloudSets,
              programId,
              dayId,
              exerciseId,
            );
            restoredCount++;
          }
        }
      }

      if (restoredCount > 0) {
        debugPrint('✅ Restore completo: $restoredCount exercícios restaurados');
      }
      if (skippedCount > 0) {
        debugPrint('ℹ️ $skippedCount exercícios mantidos (cache mais recente)');
      }

      return {'restored': restoredCount, 'skipped': skippedCount};

    } catch (error) {
      debugPrint('❌ Erro no restore: $error');
      return {'restored': restoredCount, 'skipped': skippedCount};
    }
  }

  /// Restaura sets de um exercício específico do Supabase para o cache local
  Future<void> _restoreExerciseFromCloud(
    SharedPreferences prefs,
    String cacheKey,
    List<Map<String, dynamic>> cloudSets,
    int programId,
    int dayId,
    int exerciseId,
  ) async {
    try {
      // Converter sets do Supabase para formato do cache
      // Formato: "{setNumber},{weight},{reps},{difficulty},{timestamp}"
      final setStrings = cloudSets.map((row) {
        final setNumber = row['set_number'] as int;
        final weight = (row['weight_kg'] as num?)?.toDouble() ?? 0.0;
        final reps = row['reps'] as int? ?? 0;
        final difficulty = row['difficulty'] as String? ?? 'Medium';
        final timestamp = row['created_at'] as String;

        return '$setNumber,$weight,$reps,$difficulty,$timestamp';
      }).toList();

      // Salvar no cache local
      await prefs.setStringList(cacheKey, setStrings);

      debugPrint('   📥 Ex$exerciseId restaurado (${setStrings.length} sets)');
    } catch (error) {
      debugPrint('   ❌ Erro ao restaurar Ex$exerciseId: $error');
    }
  }

  /// Extrai timestamp mais recente do cache local (List<String>)
  DateTime? _getNewestTimestampFromCache(List<String> cachedStrings) {
    try {
      DateTime? newest;

      for (final setString in cachedStrings) {
        final parts = setString.split(',');
        if (parts.length >= 5) {
          // Posição 4: timestamp
          final timestamp = DateTime.parse(parts[4]);
          if (newest == null || timestamp.isAfter(newest)) {
            newest = timestamp;
          }
        }
      }

      return newest;
    } catch (error) {
      debugPrint('⚠️ Erro ao extrair timestamp do cache: $error');
      return null;
    }
  }

  /// Extrai timestamp mais recente dos dados do Supabase
  DateTime? _getNewestTimestampFromCloud(List<Map<String, dynamic>> cloudSets) {
    try {
      DateTime? newest;

      for (final row in cloudSets) {
        final timestamp = DateTime.parse(row['created_at'] as String);
        if (newest == null || timestamp.isAfter(newest)) {
          newest = timestamp;
        }
      }

      return newest;
    } catch (error) {
      debugPrint('⚠️ Erro ao extrair timestamp do Supabase: $error');
      return null;
    }
  }
}
