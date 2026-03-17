import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/sound_model.dart';

class AudioProvider extends ChangeNotifier {
  final Map<String, AudioPlayer> _players = {};
  final List<Sound> _playingSounds = [];
  double _masterVolume = 0.7;
  bool _isMixedPlaying = false;

  List<Sound> get playingSounds => List.unmodifiable(_playingSounds);
  double get masterVolume => _masterVolume;
  bool get isPlaying => _playingSounds.isNotEmpty;

  // 预定义的白噪音列表
  final List<Sound> availableSounds = [
    // 自然类
    Sound(id: 'rain', name: '雨声', category: '自然', icon: '🌧️', assetPath: 'rain'),
    Sound(id: 'waves', name: '海浪', category: '自然', icon: '🌊', assetPath: 'waves'),
    Sound(id: 'forest', name: '森林', category: '自然', icon: '🌲', assetPath: 'forest'),
    Sound(id: 'wind', name: '风声', category: '自然', icon: '🍃', assetPath: 'wind'),
    Sound(id: 'thunder', name: '雷暴', category: '自然', icon: '⚡', assetPath: 'thunder'),
    // 环境类
    Sound(id: 'fire', name: '篝火', category: '环境', icon: '🔥', assetPath: 'fire'),
    Sound(id: 'fan', name: '风扇', category: '环境', icon: '💨', assetPath: 'fan'),
    Sound(id: 'cafe', name: '咖啡馆', category: '环境', icon: '☕', assetPath: 'cafe'),
    Sound(id: 'train', name: '火车', category: '环境', icon: '🚂', assetPath: 'train'),
    Sound(id: 'plane', name: '飞机', category: '环境', icon: '✈️', assetPath: 'plane'),
    // 冥想类
    Sound(id: 'singing', name: '颂钵', category: '冥想', icon: '🔔', assetPath: 'singing'),
    Sound(id: 'binaural', name: '双脑同步', category: '冥想', icon: '🎵', isLocked: true),
    Sound(id: 'delta', name: 'Delta波', category: '冥想', icon: '🧘', isLocked: true),
  ];

  void togglePlay(Sound sound) {
    if (_playingSounds.any((s) => s.id == sound.id)) {
      _stopSound(sound);
    } else {
      _playSound(sound);
    }
    notifyListeners();
  }

  Future<void> _playSound(Sound sound) async {
    if (sound.isLocked) return;

    final player = AudioPlayer();
    _players[sound.id] = player;
    _playingSounds.add(sound);

    // 这里使用网络音源演示，实际项目中替换为本地 assets
    // 免费音效可以从 https://freesound.org/ 获取
    const baseUrl = 'https://codeskulptor-demos.commondatastorage.googleapis.com/';
    String url;
    switch (sound.id) {
      case 'rain':
        url = '${baseUrl}Galph_white_noise_rain.mp3';
        break;
      case 'waves':
        url = '${baseUrl}piano_example.mp3';
        break;
      default:
        url = '${baseUrl}Galph_white_noise_rain.mp3';
    }

    try {
      await player.setUrl(url);
      player.setVolume(sound.volume * _masterVolume);
      player.setLoopMode(LoopMode.all);
      player.play();
      _isMixedPlaying = _playingSounds.length > 1;
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _stopSound(Sound sound) {
    final player = _players[sound.id];
    player?.dispose();
    _players.remove(sound.id);
    _playingSounds.removeWhere((s) => s.id == sound.id);
    _isMixedPlaying = _playingSounds.length > 1;
  }

  void stopAll() {
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
    _playingSounds.clear();
    _isMixedPlaying = false;
    notifyListeners();
  }

  void setMasterVolume(double volume) {
    _masterVolume = volume;
    for (final entry in _players.entries) {
      final sound = _playingSounds.firstWhere((s) => s.id == entry.key);
      entry.value.setVolume(sound.volume * volume);
    }
    notifyListeners();
  }

  void setSoundVolume(Sound sound, double volume) {
    final index = _playingSounds.indexWhere((s) => s.id == sound.id);
    if (index != -1) {
      _playingSounds[index] = _playingSounds[index].copyWith(volume: volume);
      final player = _players[sound.id];
      player?.setVolume(volume * _masterVolume);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    super.dispose();
  }
}
