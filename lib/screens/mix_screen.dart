import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/audio_provider.dart';
import '../../models/sound_model.dart';
import '../../widgets/sound_card.dart';

class MixScreen extends StatefulWidget {
  const MixScreen({super.key});

  @override
  State<MixScreen> createState() => _MixScreenState();
}

class _MixScreenState extends State<MixScreen> {
  String _selectedCategory = '自然';

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final sounds = audioProvider.availableSounds
        .where((s) => s.category == _selectedCategory)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌙 睡眠混音'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分类选择
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: ['自然', '环境', '冥想'].length,
              itemBuilder: (context, index) {
                final category = ['自然', '环境', '冥想'][index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // 主音量控制
          if (audioProvider.isPlaying) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '主音量',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(audioProvider.masterVolume * 100).toInt()}%',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Slider(
                    value: audioProvider.masterVolume,
                    onChanged: (value) {
                      audioProvider.setMasterVolume(value);
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            audioProvider.stopAll();
                          },
                          icon: const Icon(Icons.stop),
                          label: const Text('停止全部'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // 声音网格
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: sounds.length,
              itemBuilder: (context, index) {
                return SoundCard(
                  sound: sounds[index],
                  onTap: () {
                    audioProvider.togglePlay(sounds[index]);
                  },
                  isPlaying: audioProvider.playingSounds
                      .any((s) => s.id == sounds[index].id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
