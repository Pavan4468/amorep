import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please log in to see notifications',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('recipientUserId', isEqualTo: _currentUser!.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Notifications error: ${snapshot.error}');
            return const Center(
              child: Text(
                'Error loading notifications',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            );
          }

          final notifications = snapshot.data!.docs;
          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index].data() as Map<String, dynamic>;
              final String type = notif['type'] ?? 'unknown';
              final String actorName = notif['actorUsername'] ?? 'Someone';
              final String? commentText = notif['commentText'];
              final Timestamp? timestamp = notif['timestamp'] as Timestamp?;
              String timeAgo = '';
              if (timestamp != null) {
                final DateTime date = timestamp.toDate();
                final now = DateTime.now();
                final difference = now.difference(date);
                if (difference.inDays > 0) {
                  timeAgo = DateFormat('dd MMM').format(date);
                } else if (difference.inHours > 0) {
                  timeAgo = '${difference.inHours}h ago';
                } else if (difference.inMinutes > 0) {
                  timeAgo = '${difference.inMinutes}m ago';
                } else {
                  timeAgo = 'Just now';
                }
              }

              String content;
              if (type == 'like') {
                content = '$actorName liked your reel';
              } else if (type == 'comment') {
                content = '$actorName commented: "$commentText"';
              } else {
                content = '$actorName interacted with your reel';
              }

              return Dismissible(
                key: Key(notifications[index].id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  // Delete the notification
                  await notifications[index].reference.delete();
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      notif['actorProfilePic'] ?? 'https://i.pravatar.cc/150?img=0',
                    ),
                    backgroundColor: Colors.grey[800],
                  ),
                  title: Text(
                    content,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    timeAgo,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    // Optional: Navigate to the reel
                    // You can pass the reelId and maybe open the reels page at that specific reel
                    // For now, just mark as read
                    if (!(notif['read'] ?? false)) {
                      notifications[index].reference.update({'read': true});
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}