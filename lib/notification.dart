import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  final Function(String)? onNavigateToPost;

  const NotificationsPage({
    Key? key,
    this.onNavigateToPost,
  }) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _selectedFilter = 'likes'; // Default to 'likes'

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Please sign in to view notifications',
            style: TextStyle(color: Color(0xFFF5E6CC), fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37),
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('Likes', 'likes'),
                const SizedBox(width: 8),
                _buildFilterChip('Comments', 'comments'),
              ],
            ),
          ),
        ),
      ),
      body: _buildNotificationsList(user),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : const Color(0xFFF5E6CC),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.grey[900],
      selectedColor: const Color(0xFFD4AF37),
      checkmarkColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFFD4AF37) : Colors.grey[700]!,
        ),
      ),
    );
  }

  Widget _buildNotificationsList(User user) {
    Query query = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true);

    // Apply filter based on selection
    if (_selectedFilter == 'likes') {
      query = query.where('type', isEqualTo: 'like');
    } else if (_selectedFilter == 'comments') {
      query = query.where('type', isEqualTo: 'comment');
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('Notification error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFD4AF37),
                  size: 60,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error loading notifications',
                  style: TextStyle(color: Color(0xFFF5E6CC), fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please try again later',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          String message = 'No notifications yet';
          IconData icon = Icons.notifications_none;
          
          if (_selectedFilter == 'likes') {
            message = 'No likes yet';
            icon = Icons.favorite_border;
          } else if (_selectedFilter == 'comments') {
            message = 'No comments yet';
            icon = Icons.comment_outlined;
          }
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: const Color(0xFFD4AF37),
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(color: Color(0xFFF5E6CC), fontSize: 17),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final type = data['type'] as String? ?? 'like';

            final timestamp = data['timestamp'] as Timestamp?;
            final read = data['read'] as bool? ?? false;
            final postId = data['postId'] as String?;

            String actorName;
            String? profileUrl;
            String actionText;
            IconData trailingIcon;
            Color iconColor;
            String? previewText;

            if (type == 'comment') {
              actorName = data['commenterName'] as String? ?? 'Someone';
              profileUrl = data['commenterProfile'] as String?;
              previewText = data['commentText'] as String?;
              actionText = 'commented on your post';
              trailingIcon = Icons.comment;
              iconColor = const Color(0xFFD4AF37);
            } else {
              // like notification
              actorName = data['likerName'] as String? ?? 'Someone';
              profileUrl = data['likerProfile'] as String?;
              actionText = 'liked your post';
              trailingIcon = Icons.favorite;
              iconColor = Colors.red;
            }

            final timeStr = _formatTimestamp(timestamp);

            return FadeInUp(
              duration: Duration(milliseconds: 280 + (index * 60).clamp(0, 1000)),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: read ? Colors.transparent : Colors.grey[900]!.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      // Mark as read
                      if (!read) {
                        try {
                          await doc.reference.update({'read': true});
                        } catch (e) {
                          debugPrint('Error marking notification as read: $e');
                        }
                      }

                      if (postId != null && widget.onNavigateToPost != null) {
                        try {
                          Navigator.pop(context);
                          widget.onNavigateToPost!(postId);
                        } catch (e) {
                          debugPrint('Navigation error: $e');
                        }
                      }
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: profileUrl != null && profileUrl.isNotEmpty
                            ? CachedNetworkImageProvider(profileUrl)
                            : null,
                        child: profileUrl == null || profileUrl.isEmpty
                            ? Icon(
                                type == 'comment' ? Icons.comment : Icons.favorite,
                                color: const Color(0xFFD4AF37),
                                size: 30,
                              )
                            : null,
                      ),
                      title: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: const Color(0xFFF5E6CC),
                            fontSize: 15.5,
                            fontWeight: read ? FontWeight.normal : FontWeight.w600,
                          ),
                          children: [
                            TextSpan(text: actorName),
                            TextSpan(
                              text: ' $actionText',
                              style: const TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (type == 'comment' && previewText != null && previewText.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 2),
                              child: Text(
                                '"$previewText"',
                                style: TextStyle(
                                  color: const Color(0xFFD4AF37).withOpacity(0.7),
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          Text(
                            timeStr,
                            style: TextStyle(
                              color: const Color(0xFFD4AF37).withOpacity(0.85),
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        trailingIcon,
                        color: iconColor,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    
    try {
      final now = DateTime.now();
      final notificationTime = timestamp.toDate();
      final difference = now.difference(notificationTime);
      
      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inHours < 1) return '${difference.inMinutes}m ago';
      if (difference.inDays < 1) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      return DateFormat('MMM d, yyyy').format(notificationTime);
    } catch (e) {
      return 'Recently';
    }
  }
}