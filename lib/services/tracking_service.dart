import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'distance_store.dart';

/// GPS orqali masofani hisoblaydi va kunlar bo'yicha saqlaydi.
/// Sahifalar bu obyektni tinglab (ListenableBuilder) o'zini yangilaydi.
class TrackingService extends ChangeNotifier {
  final _dayFmt = DateFormat('yyyy-MM-dd');

  DistanceStore? _store;
  StreamSubscription<Position>? _sub;
  Timer? _clock;
  Position? _last;

  Map<String, double> days = {};
  bool ready = false;
  bool tracking = false;
  String? error;

  String get todayKey => _dayFmt.format(DateTime.now());
  double get today => days[todayKey] ?? 0;
  double get total => days.values.fold(0.0, (s, v) => s + v);
  double get average => days.isEmpty ? 0 : total / days.length;
  double get maxDay => days.values.fold(1.0, (m, v) => v > m ? v : m);

  /// Kunlar ro'yxati: yangisi birinchi.
  List<String> get sortedKeys =>
      days.keys.toList()..sort((a, b) => b.compareTo(a));

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _store = DistanceStore(prefs);
    days = _store!.load();
    ready = true;
    // Yarim tunda "Bugun" yangi kunga o'tishi uchun ekranni yangilab turamiz.
    _clock = Timer.periodic(const Duration(minutes: 1), (_) => notifyListeners());
    notifyListeners();
  }

  LocationSettings _settings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Yurish hisoblanmoqda',
          notificationText: 'Masofa fonda hisoblab borilmoqda',
          enableWakeLock: true,
        ),
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 5,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    }
    return const LocationSettings(
        accuracy: LocationAccuracy.high, distanceFilter: 5);
  }

  Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      error = 'GPS o\'chiq. Iltimos, uni yoqing.';
      notifyListeners();
      return false;
    }
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    if (p == LocationPermission.denied) {
      error = 'Joylashuvga ruxsat berilmadi.';
      notifyListeners();
      return false;
    }
    if (p == LocationPermission.deniedForever) {
      error = 'Ruxsat butunlay rad etilgan. Sozlamalardan yoqing.';
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<void> start() async {
    if (!await _ensurePermission()) return;
    error = null;
    tracking = true;
    _last = null;
    notifyListeners();

    _sub = Geolocator.getPositionStream(locationSettings: _settings()).listen(
      _onPosition,
      onError: (e) {
        error = '$e';
        stop();
      },
    );
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    tracking = false;
    notifyListeners();
  }

  void _onPosition(Position p) {
    if (p.accuracy > 30) return; // GPS aniqligi past — o'tkazib yuboramiz

    final prev = _last;
    if (prev == null) {
      _last = p;
      return;
    }

    final d = Geolocator.distanceBetween(
        prev.latitude, prev.longitude, p.latitude, p.longitude);
    if (d < 3) return; // GPS "titrashi"ni hisobga olmaymiz

    final secs = p.timestamp.difference(prev.timestamp).inMilliseconds / 1000;
    _last = p;
    if (secs > 0 && d / secs > 10) return; // ~36 km/soatdan tez — yurish emas

    final key = todayKey;
    days[key] = (days[key] ?? 0) + d;
    _store?.save(days);
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _clock?.cancel();
    super.dispose();
  }
}