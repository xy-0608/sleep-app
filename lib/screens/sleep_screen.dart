import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/sleep_provider.dart';
import '../../providers/audio_provider.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sleepProvider = Provider.of<SleepProvider>(context);
    final audioProvider = Provider.of<AudioProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('😴 睡眠追踪'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!sleepProvider.isTracking) ...[
                const Icon(
                  Icons.bedtime_outlined,
                  size: 100,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 24),
                const Text(
                  '准备好入睡了吗？',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '开始追踪后，我们会记录你的睡眠时长，帮助你了解睡眠习惯',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),
                FilledButton.icon(
                  onPressed: () {
                    sleepProvider.startSleepTracking();
                    if (audioProvider.playingSounds.isNotEmpty) {
                      // 继续播放混音帮助入睡
                    }
                  },
                  icon: const Icon(Icons.bedtime),
                  label: const Text('开始睡眠'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ] else ...[
                // 正在追踪
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(
                              0.3 + 0.2 * _animationController.value,
                            ),
                            blurRadius: 30,
                            spreadRadius: 10 * _animationController.value,
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.indigo,
                        child: Icon(
                          Icons.bedtime,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  '睡眠中...',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _formatDuration(sleepProvider.currentSleepDuration!),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '入睡时间: ${DateFormat.Hm().format(sleepProvider.bedtime!)}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        sleepProvider.cancelTracking();
                        audioProvider.stopAll();
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text('取消'),
                    ),
                    const SizedBox(width: 24),
                    FilledButton.icon(
                      onPressed: () {
                        _showQualityDialog(context);
                      },
                      icon: const Icon(Icons.wb_sunny),
                      label: const Text('起床'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void _showQualityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('睡眠质量如何？'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('给昨晚的睡眠打个分吧（1-5）'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < 3 ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    iconSize: 40,
                    onPressed: () {
                      final sleepProvider = Provider.of<SleepProvider>(
                        context,
                        listen: false,
                      );
                      sleepProvider.stopSleepTracking(index + 1);
                      Navigator.pop(context);
                      Provider.of<AudioProvider>(
                        context, listen: false
                      ).stopAll();
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
