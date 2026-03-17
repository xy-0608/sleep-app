import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/sound_model.dart';

class SleepStatChart extends StatelessWidget {
  final List<SleepRecord> records;

  const SleepStatChart({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const SizedBox.shrink();
    }

    // 取最近7天
    final recentRecords = records.take(7).toList().reversed.toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最近7天睡眠',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: recentRecords.map((record) {
                return _buildBar(context, record);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context, SleepRecord record) {
    const maxHours = 12.0;
    final hours = record.sleepDuration.inHours.toDouble();
    final percentage = (hours / maxHours).clamp(0.0, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 120 * percentage,
          decoration: BoxDecoration(
            color: _getQualityColor(record.quality),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('d').format(record.date),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Color _getQualityColor(int quality) {
    switch (quality) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.indigo;
    }
  }
}
