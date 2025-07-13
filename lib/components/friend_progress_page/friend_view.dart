import 'package:flutter/material.dart';
import 'package:quitter/assets/colors.dart';

class FriendView extends StatelessWidget {
  final String name;
  final int hitsToday;
  final Duration sinceLastHit;

  const FriendView({
    super.key,
    required this.name,
    required this.hitsToday,
    required this.sinceLastHit,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.main_color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📝 Friend Name
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // 💥 Hits Today
          Row(
            children: [
              Icon(Icons.show_chart, color: AppColors.main_color, size: 20),
              const SizedBox(width: 8),
              Text(
                "$hitsToday hits today",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // ⏱️ Time Since Last Hit
          Row(
            children: [
              Icon(Icons.timer, color: AppColors.secondary_color, size: 20),
              const SizedBox(width: 8),
              Text(
                "Last hit: ${_formatDuration(sinceLastHit)} ago",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
