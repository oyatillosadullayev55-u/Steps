import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


/// Kunlik masofalarni ("2025-01-31": metr) telefon xotirasida saqlaydi.
class DistanceStore {
  static const _key = 'daily_distances';
  final SharedPreferences _prefs;

  DistanceStore(this._prefs);

  Map<String, double> load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  Future<void> save(Map<String, double> data) =>
      _prefs.setString(_key, jsonEncode(data));
}