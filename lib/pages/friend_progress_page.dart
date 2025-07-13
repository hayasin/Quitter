import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quitter/Assets/colors.dart';
import 'package:quitter/components/friend_progress_page/search_result_tile.dart';
import 'package:quitter/components/friend_progress_page/friend_view.dart';
import 'package:quitter/services/auth_service.dart';

class FriendProgressPage extends StatefulWidget {
  const FriendProgressPage({super.key});

  @override
  State<FriendProgressPage> createState() => _FriendProgressPageState();
}

class _FriendProgressPageState extends State<FriendProgressPage> {


  List<Map<String, dynamic>> friends = []; 
  @override
  void initState() {
    super.initState(); 
    _loadFriends(); 
  }

  Future<void> _loadFriends() async {
    try {
      final data = await getFriends(); 
      setState(() {
        friends = data;
      }); 
    }
    catch(e) {
      print("Error loading friends: $e"); 
    }
  }





  void _showSearchResultsDrawer(String receiverId) {
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Not logged in")));
      return;
    }

    final senderId = currentUser?.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),

      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search Results',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Expanded(
                child:
                    receiverId == null
                        ? const Center(
                          child: Text(
                            "No user found with that username.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        )
                        : SearchResultTile(
                          username: _searchController.text,
                          receiverId: receiverId,
                          senderId: senderId!,
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SearchBar(
            controller: _searchController,
            elevation: WidgetStateProperty.all(2),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            hintText: 'Search users...',
            onChanged: (value) {
              print("Value");
            },
            onSubmitted: (value) async {
              print("searching");
              // TODO: IMPLEMENT SEARCH ALG.
              final userId = await getUserIdByUsername(_searchController.text);
              if (userId != null) {
                print(userId);
                _showSearchResultsDrawer(userId);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("No user found with that username."),
                  ),
                );
              }
            },
            trailing: [
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: () => _searchController.clear(),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),



        Expanded(
          child: friends.isEmpty
          ? const Center(child: Text("no friends yet", style: TextStyle(color: Colors.white)))
          : ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index]; 
              return FutureBuilder(
                future: Future.wait([
                  getTodaysHitCount(friend['user_id']),
                  getLastHitTime(friend['user_id'])
                ]), 
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator()); 
                  }

                  final hitsToday = snapshot.data![0] as int;
                  final lastHit = snapshot.data![1] as DateTime?; 

                  Duration sinceLastHit; 

                  if (lastHit != null) {
                    sinceLastHit = DateTime.now().difference(lastHit); 
                  }

                  else {
                    sinceLastHit = Duration.zero; 
                  }

                  return FriendView(
                    name: friend['username'], 
                    hitsToday: hitsToday, 
                    sinceLastHit: sinceLastHit
                  ); 
                }
              );
            }
        )
        )



        // const FriendView(
        //   name: "Test",
        //   sinceLastHit: Duration(hours: 3),
        //   hitsToday: 3,
        // ),
      ],
    );
  }
}
