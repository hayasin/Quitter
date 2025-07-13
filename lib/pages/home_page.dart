import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quitter/assets/colors.dart';
import 'package:quitter/components/powerup.dart';
import 'package:quitter/services/auth_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int hitCount = 0;
  DateTime? lastHitTime;
  late Timer _timer;
  Duration timeSinceLastHit = Duration.zero;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (lastHitTime != null) {
          timeSinceLastHit = DateTime.now().difference(lastHitTime!);
        }
      });
    });

    _loadInitialData();
  }

  void _loadInitialData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        print("No user logged in");
        return;
      }

      final count = await getTodaysHitCount(user.id);
      final lastHit = await getLastHitTime(user.id);

      setState(() {
        hitCount = count;
        lastHitTime = lastHit;
        if (lastHit != null) {
          timeSinceLastHit = DateTime.now().difference(lastHit);
        }
      });

      print("Initial data: $count hits today, last hit at $lastHit");
    } catch (e) {
      print("Failed to load initial data: $e");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Simulate logging a vape hit
  void _logVapeHit() async {
    try {
      await logVapeHitToSupabase();

      final user = supabase.auth.currentUser;
      if (user == null) {
        print("No user logged in");
        return;
      }

      final count = await getTodaysHitCount(user.id);
      final lastHit = await getLastHitTime(user.id);

      setState(() {
        hitCount = count;
        lastHitTime = lastHit ?? DateTime.now();
        timeSinceLastHit = Duration.zero; // Reset timer
      });

      print("✅ Updated dashboard: $count hits today, last hit at $lastHit");
    } catch (e) {
      print("❌ Error logging hit: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error logging hit: $e')));
    }
  }

  /// Format Duration to HH:MM:SS
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🌟 Glowing Animated Counter
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Text(
                  "$hitCount",
                  key: ValueKey<int>(hitCount),
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 40,
                        color: AppColors.main_color.withOpacity(0.8),
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                "hits logged today",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                _formatDuration(timeSinceLastHit),
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      blurRadius: 30,
                      color: AppColors.main_color.withOpacity(0.6),
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _logVapeHit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.main_color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 12,
                  shadowColor: AppColors.main_color.withOpacity(0.5),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text("Took a Hit"),
              ),

              const SizedBox(height: 40),

              const Text(
                "“Every hit you skip is progress.”",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60), // Add breathing space before runes
              // 🔥 Your Power-Ups Section
              Text(
                "Your Power-Ups",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true, 
                physics: NeverScrollableScrollPhysics(), 

                children: [
                  PowerUp(imagePath: "assets/images/vitalsparks.svg", title: "Vital Spark"),
                ]
              )

            ],
          ),
        ),
      ),
    );
  }
}
