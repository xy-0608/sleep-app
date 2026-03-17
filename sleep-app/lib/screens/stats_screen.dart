import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/sleep_provider.dart';
import '../../models/sound_model.dart';
import '../../widgets/sleep_stat_chart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sleepProvider = Provider.of<SleepProvider>(context);
    final records = sleepProvider.sleepRecords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 睡眠统计'),
        centerTitle: true,
      ),
      body: records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无睡眠记录',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '开始第一次睡眠追踪后，这里会显示统计数据',
                    style: TextStyle(
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 概览卡片
                  _buildOverviewCard(sleepProvider),
                  const SizedBox(height: 24),
                  // 最近7天图表
                  if (records.length >= 2) ...[
                    SleepStatChart(records: records),
                    const SizedBox(height: 24),
                  ],
                  const Text(
                    '最近记录',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 记录列表
                  ...records.take(10).map((record) {
                    return _buildRecordCard(record);
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewCard(SleepProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOverviewItem(
                  '平均睡眠',
                  _formatDuration(provider.averageSleepDuration),
                  Icons.timelapse,
                ),
                _buildOverviewItem(
                  '平均质量',
                  '${provider.averageQuality.toStringAsFixed(1)} ⭐',
                  Icons.star,
                ),
                _buildOverviewItem(
                  '记录天数',
                  '${provider.sleepRecords.length}',
                  Icons.calendar_today,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.indigo),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(SleepRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.withOpacity(0.1),
          child: Text(
            '${record.quality}⭐',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        title: Text(
          DateFormat.yMMMd().format(record.date),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${DateFormat.Hm().format(record.bedtime)} - ${DateFormat.Hm().format(record.wakeTime)}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            record.formattedDuration,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.indigo,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h${minutes}m';
  }
}
