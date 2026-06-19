import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const _pre = 'cache_';
  static const _tsP = 'cache_ts_';
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _p async =>
      _prefs ??= await SharedPreferences.getInstance();

  static Future<void> save(String key, dynamic data) async {
    final p = await _p;
    await p.setString('$_pre$key', jsonEncode(data));
    await p.setInt('$_tsP$key', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<dynamic> getData(String key) async {
    final p = await _p;
    final raw = p.getString('$_pre$key');
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isFresh(String key, {int maxAgeMinutes = 120}) async {
    final p = await _p;
    final ts = p.getInt('$_tsP$key');
    if (ts == null) return false;
    return (DateTime.now().millisecondsSinceEpoch - ts) <
        maxAgeMinutes * 60 * 1000;
  }

  static Future<bool> hasCache(String key) async {
    final p = await _p;
    return p.containsKey('$_pre$key');
  }

  static Future<void> remove(String key) async {
    final p = await _p;
    await p.remove('$_pre$key');
    await p.remove('$_tsP$key');
  }

  static Future<void> clearAll() async {
    final p = await _p;
    for (final k in [...p.getKeys()]) {
      if (k.startsWith(_pre) || k.startsWith(_tsP)) await p.remove(k);
    }
  }
}
