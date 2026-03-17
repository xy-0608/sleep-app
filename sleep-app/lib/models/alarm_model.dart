import 'package:intl/intl.dart';

class Alarm {
  final String id;
  final DateTime time;
  final bool enabled;
  final bool repeat;
  final List<int> repeatDays; // 0=周日, 1=周一...

  Alarm({
    required this.id,
    required this.time,
    this.enabled = true,
    this.repeat = false,
    this.repeatDays = const [],
  });

  Alarm copyWith({
    String? id,
    DateTime? time,
    bool? enabled,
    bool? repeat,
    List<int>? repeatDays,
  }) {
    return Alarm(
      id: id ?? this.id,
      time: time ?? this.time,
      enabled: enabled ?? this.enabled,
      repeat: repeat ?? this.repeat,
      repeatDays: repeatDays ?? this.repeatDays,
    );
  }

  String get formattedTime {
    return DateFormat.Hm().format(time);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'enabled': enabled,
      'repeat': repeat,
      'repeatDays': repeatDays,
    };
  }

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'],
      time: DateTime.parse(json['time']),
      enabled: json['enabled'],
      repeat: json['repeat'] ?? false,
      repeatDays: List<int>.from(json['repeatDays'] ?? []),
    );
  }
}
