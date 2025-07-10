// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:postgrest/postgrest.dart'
    show CountOption; // ← to expose CountOption

final supabase = Supabase.instance.client;

/* ─────────────────────────  SIGN-UP  ───────────────────────── */
Future<void> signUpUser(String email, String password) async {
  try {
    final resp = await supabase.auth.signUp(email: email, password: password);
    final user = resp.user;
    if (user == null) {
      print('Signup failed: no user returned');
      return;
    }

    print('Signup successful: ${user.id}');
    // Auto-login if e-mail confirmation not required
    await loginUser(email, password);
  } on AuthException catch (e) {
    print('Auth error: ${e.message}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}

/* ───────────────────────────  LOGIN  ───────────────────────── */
Future<void> loginUser(String email, String password) async {
  try {
    final resp = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = resp.user;
    if (user == null) {
      print('Login failed');
      return;
    }

    print('✅ Login successful: ${user.id}');
    // Ensure row exists in user_data
    await supabase.from('user_data').upsert({
      'user_id': user.id,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  } on AuthException catch (e) {
    print('Auth error: ${e.message}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}

/* ──────────────────  INSERT A VAPE HIT  ─────────────────────── */
Future<void> logVapeHitToSupabase() async {
  final user = supabase.auth.currentUser;
  if (user == null) throw Exception('No user logged in');

  await supabase.from('vape_hits').insert({
    'user_id': user.id,
    'created_at': DateTime.now().toUtc().toIso8601String(),
  });
  // print('Vape hit logged for user ${user.id}');
}

/* ──────  COUNT TODAY’S HITS (client-side, no RPC)  ─────── */
Future<int> getTodaysHitCount() async {
  final user = supabase.auth.currentUser;
  if (user == null) return 0;

  final now = DateTime.now().toUtc();
  final start = DateTime.utc(now.year, now.month, now.day); // 00:00 UTC
  final end = start.add(const Duration(days: 1)); // next midnight

  final response = await supabase
      .from('vape_hits')
      .select()
      .eq('user_id', user.id)
      .gte('created_at', start.toIso8601String())
      .lt('created_at', end.toIso8601String());

  return response.length;
}

/* ───────────────  LAST HIT TIMESTAMP  ─────────────── */
Future<DateTime?> getLastHitTime() async {
  final user = supabase.auth.currentUser;
  if (user == null) return null;

  final resp =
      await supabase
          .from('vape_hits')
          .select('created_at')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

  final ts = resp?['created_at'] as String?;
  return ts == null ? null : DateTime.parse(ts);
}

Future<List<int>> getWeeklyHitCounts() async {
  final user = supabase.auth.currentUser;
  if (user == null) throw Exception('No user logged in');

  final now = DateTime.now().toUtc();
  // final startOfToday = DateTime.utc(now.year, now.month, now.day);
  //Found sunday of the week
  final subtractVal = now.weekday % 7;
  final startofWeek = DateTime.utc(
    now.year,
    now.month,
    now.day,
  ).subtract(Duration(days: subtractVal));

  List<int> dailyCounts = [];

  for (int i = 0; i <= 6; i++) {
    final dayStart = startofWeek.add(Duration(days: i));
    final dayEnd = dayStart.add(const Duration(days: 1));

    //TODO: Fill in days from startofWeek all the way to Saturday. So for loop should increment 7 times?
    final response = await supabase
        .from('vape_hits')
        .select()
        .eq('user_id', user.id)
        .gte('created_at', dayStart.toIso8601String())
        .lt('created_at', dayEnd.toIso8601String());

    dailyCounts.add(response.length); // Insert at start
  }

  print("HERE IS DAILY COUNTS:");
  print(dailyCounts);
  return dailyCounts;
}
