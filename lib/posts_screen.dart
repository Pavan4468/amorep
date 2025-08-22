import 'package:flutter/material.dart';

class PostsScreen extends StatelessWidget {
  final List<Map<String, String>> posts;

  const PostsScreen({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: posts.isEmpty
          ? const Center(child: Text('No posts yet'))
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  leading: post['type'] == 'image'
                      ? Image.network(
                          post['url']!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.videocam, size: 50),
                  title: Text(post['type'] ?? 'media'),
                  subtitle: Text(post['url'] ?? ''),
                );
              },
            ),
    );
  }
}
