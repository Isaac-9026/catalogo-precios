import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';

class SyncRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> getLastSyncedAt() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('app_config', where: 'id = 1');
    if (result.isNotEmpty) {
      return result.first['last_synced_at'] as String?;
    }
    return null;
  }

  Future<void> performSync() async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      // Chequeo rápido de conexión para evitar bloqueos prolongados
      await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 5));
      
      final lastSyncedAt = await getLastSyncedAt() ?? '1970-01-01T00:00:00.000Z';
      final syncStartTime = DateTime.now().toUtc().toIso8601String();

      // ==========================================
      // PASO 1: PUSH (Local -> Nube)
      // ==========================================
      
      // 1.1 Productos
      final localProductsToPush = await db.query(
        'products',
        where: 'updated_at > ?',
        whereArgs: [lastSyncedAt],
      );
      
      if (localProductsToPush.isNotEmpty) {
        await _supabase.from('products').upsert(localProductsToPush);
      }

      // 1.2 Historial de precios (Append-only)
      final localPriceHistoryToPush = await db.query(
        'price_history',
        where: 'changed_at > ?',
        whereArgs: [lastSyncedAt],
      );

      if (localPriceHistoryToPush.isNotEmpty) {
        await _supabase
            .from('price_history')
            .upsert(localPriceHistoryToPush, onConflict: 'id', ignoreDuplicates: true);
      }

      // ==========================================
      // PASO 2: PULL (Nube -> Local)
      // ==========================================
      
      // 2.1 Productos
      final remoteProducts = await _supabase
          .from('products')
          .select()
          .gt('updated_at', lastSyncedAt);

      if (remoteProducts.isNotEmpty) {
        await db.transaction((txn) async {
          for (final product in remoteProducts) {
            await txn.insert(
              'products',
              product,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        });
      }

      // 2.2 Historial de precios (Append-only)
      final remotePriceHistory = await _supabase
          .from('price_history')
          .select()
          .gt('changed_at', lastSyncedAt);

      if (remotePriceHistory.isNotEmpty) {
        await db.transaction((txn) async {
          for (final history in remotePriceHistory) {
            await txn.insert(
              'price_history',
              history,
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        });
      }

      // ==========================================
      // PASO 3: FINALIZAR
      // ==========================================
      await db.update(
        'app_config',
        {'last_synced_at': syncStartTime},
        where: 'id = 1',
      );

    } on SocketException catch (_) {
      throw const SyncOfflineException('Sin conexión a internet. Intenta más tarde.');
    } catch (e) {
      if (e.toString().contains('Failed host lookup') || e.toString().contains('SocketException')) {
        throw const SyncOfflineException('Sin conexión a internet. Intenta más tarde.');
      }
      throw SyncException('Error al sincronizar: $e');
    }
  }
}

class SyncOfflineException implements Exception {
  final String message;
  const SyncOfflineException(this.message);
}

class SyncException implements Exception {
  final String message;
  const SyncException(this.message);
}
