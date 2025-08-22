import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';

class LikesPage extends StatelessWidget {
  final String postId;

  const LikesPage({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Likes',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37), // Gold
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)), // Gold
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').doc(postId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(color: Color(0xFFF5E6CC), fontSize: 16.0), // White-Gold
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))); // Gold
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Post not found',
                style: TextStyle(color: Color(0xFFF5E6CC), fontSize: 16.0), // White-Gold
              ),
            );
          }

          final post = snapshot.data!.data() as Map<String, dynamic>;
          final likers = List<Map<String, dynamic>>.from(post['likers'] ?? []);

          if (likers.isEmpty) {
            return const Center(
              child: Text(
                'No likes yet',
                style: TextStyle(color: Color(0xFFF5E6CC), fontSize: 16.0), // White-Gold
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: likers.length,
            itemBuilder: (context, index) {
              final liker = likers[index];
              return FadeInUp(
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: CachedNetworkImageProvider(
                          liker['profileImage'] ?? 'https://i.pravatar.cc/150?img=0',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${liker['userName'] ?? 'Anonymous'} liked this post',
                        style: const TextStyle(
                          color: Color(0xFFF5E6CC), // White-Gold
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}