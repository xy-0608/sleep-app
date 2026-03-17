class Sound {
  final String id;
  final String name;
  final String category;
  final String icon;
  final String? assetPath;
  final bool isLocked;
  final double volume;

  Sound({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    this.assetPath,
    this.isLocked = false,
    this.volume = 0.7,
  });

  Sound copyWith({
    String? id,
    String? name,
    String? category,
    String? icon,
    String? assetPath,
    bool? isLocked,
    double? volume,
  }) {
    return Sound(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      assetPath: assetPath ?? this.assetPath,
      isLocked: isLocked ?? this.isLocked,
      volume: volume ?? this.volume,
    );
  }
}

class SleepRecord {
  final DateTime date;
  final Duration sleepDuration;
  final DateTime bedtime;
  final DateTime wakeTime;
  final int quality; // 1-5

  SleepRecord({
    required this.date,
    required this.sleepDuration,
    required this.bedtime,
    required this.wakeTime,
    required this.quality,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'sleepDurationInMinutes': sleepDuration.inMinutes,
      'bedtime': bedtime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'quality': quality,
    };
  }

  factory SleepRecord.fromJson(Map<String, dynamic> json) {
    return SleepRecord(
      date: DateTime.parse(json['date']),
      sleepDuration: Duration(minutes: json['sleepDurationInMinutes']),
      bedtime: DateTime.parse(json['bedtime']),
      wakeTime: DateTime.parse(json['wakeTime']),
      quality: json['quality'],
    );
  }

  String get formattedDuration {
    final hours = sleepDuration.inHours;
    final minutes = sleepDuration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}
