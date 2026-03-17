import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/sound_model.dart';

class SleepProvider extends ChangeNotifier {
  bool _isTracking = false;
  DateTime? _bedtime;
  DateTime? _wakeTime;
  List<SleepRecord> _sleepRecords = [];

  bool get isTracking => _isTracking;
  DateTime? get bedtime => _bedtime;
  DateTime? get wakeTime => _wakeTime;
  List<SleepRecord> get sleepRecords => List.unmodifiable(_sleepRecords);

  SleepProvider() {
    _loadRecords();
  }

  void startSleepTracking() {
    _isTracking = true;
    _bedtime = DateTime.now();
    _wakeTime = null;
    notifyListeners();
  }

  Future<void> stopSleepTracking(int quality) async {
    _isTracking = false;
    _wakeTime = DateTime.now();
    if (_bedtime != null) {
      final duration = _wakeTime!.difference(_bedtime!);
      final record = SleepRecord(
        date: DateTime.now(),
        sleepDuration: duration,
        bedtime: _bedtime!,
        wakeTime: _wakeTime!,
        quality: quality,
      );
      _sleepRecords.add(record);
      await _saveRecords();
    }
    notifyListeners();
  }

  void cancelTracking() {
    _isTracking = false;
    _bedtime = null;
    _wakeTime = null;
    notifyListeners();
  }

  Duration? get currentSleepDuration {
    if (_bedtime == null) return null;
    return DateTime.now().difference(_bedtime!);
  }

  Duration get averageSleepDuration {
    if (_sleepRecords.isEmpty) return Duration.zero;
    final total = _sleepRecords.fold<Duration>(
      Duration.zero,
      (sum, record) => sum + record.sleepDuration,
    );
    return Duration(
      minutes: total.inMinutes ~/ _sleepRecords.length,
    );
  }

  double get averageQuality {
    if (_sleepRecords.isEmpty) return 0;
    final total = _sleepRecords.fold<int>(
      0,
      (sum, record) => sum + record.quality,
    );
    return total / _sleepRecords.length;
  }

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _sleepRecords.map((r) => r.toJson()).toList();
    await prefs.setString('sleep_records', jsonEncode(jsonList));
  }

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('sleep_records');
    if (jsonStr != null) {
      final jsonList = jsonDecode(jsonStr) as List;
      _sleepRecords = jsonList
          .map((json) => SleepRecord.fromJson(json))
          .toList()
          .reversed
          .toList();
    }
    notifyListeners();
  }

  void clearOldRecords() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    _sleepRecords = _sleepRecords
        .where((record) => record.date.isAfter(thirtyDaysAgo))
        .toList();
    _saveRecords();
    notifyListeners();
  }
}
