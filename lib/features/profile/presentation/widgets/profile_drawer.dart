import 'package:flutter/material.dart';

class ProfileDrawer extends StatelessWidget {
  final List<Map<String, dynamic>> chatHistory;
  final VoidCallback onHomeTap;
  final void Function(Map<String, dynamic>) onChatTap;

  const ProfileDrawer({
    super.key,
    required this.chatHistory,
    required this.onHomeTap,
    required this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Row(
              children: [
                Icon(Icons.menu, color: Colors.white),
                SizedBox(width: 8),
                Text('OK Team Project', style: TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: onHomeTap,
          ),
          const Divider(),
          ...chatHistory.map((chat) => ListTile(
                leading: chat['inPrivate'] == true
                    ? const CircleAvatar(child: Icon(Icons.lock))
                    : null,
                title: Text(chat['title'] ?? 'Untitled'),
                onTap: () => onChatTap(chat),
              )),
        ],
      ),
    );
  }
}
