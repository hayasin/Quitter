import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quitter/assets/colors.dart';
import 'package:quitter/services/auth_service.dart';

class SearchResultTile extends StatefulWidget {
  final String username;
  final String receiverId;
  final String senderId;

  const SearchResultTile({
    super.key,
    required this.username,
    required this.receiverId,
    required this.senderId,
  });

  @override
  State<SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<SearchResultTile> {
  String? statusMessage;

  Future<void> _sendFriendRequest() async {
    try {
      await sendFriendRequest(widget.senderId, widget.receiverId);
      setState(() {
        statusMessage = "Sent friend request";
      });
    } catch (e) {
      final errorText = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        if (errorText.contains("Already sent a friend request to this user")) {
          statusMessage = "You already sent a request"; 
        }
        else if (errorText.contains("You're already friends")) {
          statusMessage = "You’re already friends"; 
        }

        else {
          statusMessage = "Error";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          title: Text(
            widget.username,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          trailing: IconButton(
            onPressed: _sendFriendRequest,
            icon: const Icon(Icons.person_add_alt, color: AppColors.main_accent),
          ),
        ),
        if (statusMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              statusMessage!,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
      ],
    );
  }
}
