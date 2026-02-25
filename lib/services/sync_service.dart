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
}
