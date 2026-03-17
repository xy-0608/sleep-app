import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/alarm_model.dart';
import 'dart:convert';

class AlarmProvider extends ChangeNotifier {
  List<Alarm> _alarms = [];
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<Alarm> get alarms => List.unmodifiable(_alarms);

  AlarmProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadAlarms();
    await _initNotifications();
    _scheduleAllAlarms();
  }

  Future<void> _initNotifications() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _notificationsPlugin.initialize(initializationSettings);
  }

  void addAlarm(DateTime time) {
    final alarm = Alarm(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      time: time,
    );
    _alarms.add(alarm);
    _scheduleAlarm(alarm);
    _saveAlarms();
    notifyListeners();
  }

  void deleteAlarm(String id) {
    _cancelAlarm(id);
    _alarms.removeWhere((alarm) => alarm.id == id);
    _saveAlarms();
    notifyListeners();
  }

  void toggleAlarm(String id) {
    final index = _alarms.indexWhere((alarm) => alarm.id == id);
    if (index != -1) {
      final alarm = _alarms[index];
      _alarms[index] = alarm.copyWith(enabled: !alarm.enabled);
      if (_alarms[index].enabled) {
        _scheduleAlarm(_alarms[index]);
      } else {
        _cancelAlarm(id);
      }
      _saveAlarms();
      notifyListeners();
    }
  }

  Future<void> _scheduleAlarm(Alarm alarm) async {
    if (!alarm.enabled) return;

    final notificationId = alarm.id.hashCode;
    final scheduledNotificationDateTime = alarm.time;

    const androidNotificationDetails = AndroidNotificationDetails(
      'sleep_alarm',
      'Sleep Alarm',
      channelDescription: 'Alarm notification for sleep app',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      '起床时间到了',
      '该起床了，祝你一天好心情',
      scheduledNotificationDateTime,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: alarm.repeat
          ? DateTimeComponents.time
          : null,
    );
  }

  void _cancelAlarm(String id) {
    final notificationId = id.hashCode;
    _notificationsPlugin.cancel(notificationId);
  }

  void _scheduleAllAlarms() {
    for (final alarm in _alarms) {
      if (alarm.enabled) {
        _scheduleAlarm(alarm);
      }
    }
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _alarms.map((a) => a.toJson()).toList();
    await prefs.setString('alarms', jsonEncode(jsonList));
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('alarms');
    if (jsonStr != null) {
      final jsonList = jsonDecode(jsonStr) as List;
      _alarms = jsonList.map((json) => Alarm.fromJson(json)).toList();
    }
    notifyListeners();
  }
}
