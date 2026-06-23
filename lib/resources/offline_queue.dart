import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores write operations (add category, add product) that couldn't be sent
/// due to no internet. Images are copied to permanent app storage so they
/// survive restarts. Processed when connectivity is restored.
class OfflineQueue {
  static const _key = 'offline_queue';
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _p async =>
      _prefs ??= await SharedPreferences.getInstance();

  static Future<List<Map<String, dynamic>>> _all() async {
    final p = await _p;
    final raw = p.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _save(List<Map<String, dynamic>> items) async {
    final p = await _p;
    await p.setString(_key, jsonEncode(items));
  }

  /// Copy [sourceFile] to permanent app documents dir and return the new path.
  static Future<String> copyFilePermanent(File sourceFile) async {
    final dir = await getApplicationDocumentsDirectory();
    final dest = Directory('${dir.path}/offline_uploads');
    if (!await dest.exists()) await dest.create(recursive: true);
    final ext = sourceFile.path.split('.').last;
    final name =
        '${DateTime.now().millisecondsSinceEpoch}_${sourceFile.hashCode}.$ext';
    final copied = await sourceFile.copy('${dest.path}/$name');
    return copied.path;
  }

  /// Add a pending operation.
  /// [type] is 'add_category' | 'add_product'.
  static Future<void> enqueue({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final items = await _all();
    items.add({
      'id': '${type}_${DateTime.now().millisecondsSinceEpoch}',
      'type': type,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    await _save(items);
  }

  static Future<List<Map<String, dynamic>>> getAll() => _all();

  static Future<void> remove(String id) async {
    final items = await _all();
    items.removeWhere((e) => e['id'] == id);
    await _save(items);
  }

  static Future<void> clear() async {
    final p = await _p;
    await p.remove(_key);
  }

  static Future<bool> get isEmpty async => (await _all()).isEmpty;

  /// Rewrites categoryId on still-queued 'add_product' items that reference
  /// a local (not-yet-synced) category id, now that it has a real server id.
  /// Called right after a category finishes syncing so any product queued
  /// against it can sync correctly afterwards.
  static Future<void> remapProductCategoryIds(
    Map<String, String> localToRealId,
  ) async {
    if (localToRealId.isEmpty) return;
    final items = await _all();
    var changed = false;
    for (final item in items) {
      if (item['type'] != 'add_product') continue;
      final data = item['data'] as Map<String, dynamic>?;
      final categoryId = data?['categoryId'] as String?;
      if (categoryId != null && localToRealId.containsKey(categoryId)) {
        data!['categoryId'] = localToRealId[categoryId];
        changed = true;
      }
    }
    if (changed) await _save(items);
  }
}
