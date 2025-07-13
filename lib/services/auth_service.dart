// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:postgrest/postgrest.dart'
    show CountOption; // ← to expose CountOption

final supabase = Supabase.instance.client;

/* ─────────────────────────  SIGN-UP  ───────────────────────── */
Future<void> signUpUser(String email, String password, String username) async {
  try {
    // Check if username already exists
    final existing =
        await supabase
            .from('user_data')
            .select('user_id')
            .eq('username', username)
            .maybeSingle();

    if (existing != null) {
      throw AuthException('Username already taken');
    }

    final resp = await supabase.auth.signUp(email: email, password: password);
    final user = resp.user;

    if (user == null) {
      print('Signup failed: no user returned');
      return;
    }

    print('✅ Signup successful: ${user.id}');

    // Insert user data
    await supabase.from('user_data').insert({
      'user_id': user.id,
      'username': username,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });

    // Auto-login
    await loginUser(email, password);
  } on AuthException catch (e) {
    print('Auth error: ${e.message}');
    rethrow; // so UI can show message
  } catch (e) {
    print('Unexpected error: $e');
    rethrow;
  }
}

/* ───────────────────────────  LOGIN  ───────────────────────── */
Future<bool> loginUser(String email, String password) async {
  try {
    final resp = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = resp.user;
    if (user == null) {
      print('Login failed: No user returned');
      return false;
    }

    print('✅ Login successful: ${user.id}');
    return true; // ✅ Success
  } on AuthException catch (e) {
    print('Auth error: ${e.message}');
    return false; // ❌ Invalid credentials
  } catch (e) {
    print('Unexpected error: $e');
    return false;
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
Future<int> getTodaysHitCount(String userId) async {

  final now = DateTime.now().toUtc();
  final start = DateTime.utc(now.year, now.month, now.day); // 00:00 UTC
  final end = start.add(const Duration(days: 1)); // next midnight

  final response = await supabase
      .from('vape_hits')
      .select()
      .eq('user_id', userId)
      .gte('created_at', start.toIso8601String())
      .lt('created_at', end.toIso8601String());

  return response.length;
}

/* ───────────────  LAST HIT TIMESTAMP  ─────────────── */
Future<DateTime?> getLastHitTime(String userId) async {
  final resp =
      await supabase
          .from('vape_hits')
          .select('created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

  final ts = resp?['created_at'] as String?;
  return ts == null ? null : DateTime.parse(ts);
}

/* ───────────────  WEEKLY HIT DATA  ─────────────── */

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

/* ───────────────  QUERY FOR A USER USING USERNAME ─────────────── */
Future<String?> getUserIdByUsername(String username) async {
  try {
    final resp =
        await supabase
            .from('user_data')
            .select('user_id')
            .eq('username', username)
            .maybeSingle();

    if (resp == null) {
      print("no user found with username : $username");
      return null;
    }

    final userId = resp['user_id'] as String;
    return userId;
  } catch (e) {
    print("error fetching user_id by username: $e");
    return null;
  }
}

/* ───────────────  FRIEND LOGIC ─────────────── */

Future<bool> areUsersFriends(String userId1, String userId2) async {
  final resp =
      await supabase
          .from('friends')
          .select('id')
          .or(
            'and(user_a_id.eq.$userId1,user_b_id.eq.$userId2),and(user_a_id.eq.$userId2,user_b_id.eq.$userId1)',
          )
          .maybeSingle();

  return resp != null; // true = already friends
}

Future<void> sendFriendRequest(String senderId, String receiverId) async {
  // Step 1: Check if already friends
  final alreadyFriends = await areUsersFriends(senderId, receiverId);
  if (alreadyFriends) {
    print("Already friends");
    throw Exception("You’re already friends");
  }

  // Step 2: Check if receiver sent you a request
  final incomingRequest = await supabase
      .from('friend_requests')
      .select('id')
      .eq('sender_id', receiverId)
      .eq('receiver_id', senderId)
      .maybeSingle();

  if (incomingRequest != null) {
    print("They sent you a request. Accepting...");
    await supabase.from('friend_requests').delete().eq('id', incomingRequest['id']);

    // Add to friends table
    await supabase.from('friends').insert({
      'user_a_id': senderId,
      'user_b_id': receiverId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    print("Friend added");
    return;
  }

  // Step 3: Check if you already sent a request
  final outgoingRequest = await supabase
      .from('friend_requests')
      .select('id')
      .eq('sender_id', senderId)
      .eq('receiver_id', receiverId)
      .maybeSingle();

  if (outgoingRequest != null) {
    print("📨 Friend request already sent");
    throw Exception("Already sent a friend request to this user");
  }

  // Step 4: Create new friend request
  print("📨 Sending friend request...");
  await supabase.from('friend_requests').insert({
    'sender_id': senderId,
    'receiver_id': receiverId,
    'status': false, // optional if using status field
    'created_at': DateTime.now().toUtc().toIso8601String(),
  });
  print("Friend request sent");
}


Future<List<Map<String, dynamic>>> getFriends() async {
  final user = supabase.auth.currentUser;
  if (user == null) throw Exception('No user logged in');

  final response = await supabase
      .from('friends')
      .select('user_a_id, user_b_id, created_at');

  // Filter locally (could also do with RPC or Postgres functions)
  final friends = response.where((row) =>
      row['user_a_id'] == user.id || row['user_b_id'] == user.id);

  List<Map<String, dynamic>> friendData = [];

  for (final row in friends) {
    final friendId = row['user_a_id'] == user.id
        ? row['user_b_id']
        : row['user_a_id'];

    // Fetch username for friend
    final friendProfile = await supabase
        .from('user_data')
        .select('username')
        .eq('user_id', friendId)
        .maybeSingle();

    if (friendProfile != null) {
      friendData.add({
        'user_id': friendId,
        'username': friendProfile['username'],
      });
    }
  }

  return friendData; // [{user_id, username}, ...]
}
