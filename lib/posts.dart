import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'PromoteDetailsPage.dart';
import 'likes_page.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({Key? key}) : super(key: key);

  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  // Check if the URL is likely a video
  bool _isVideoUrl(String url) {
    return url.toLowerCase().endsWith('.mp4') ||
        url.toLowerCase().endsWith('.mov') ||
        url.toLowerCase().endsWith('.avi') ||
        url.toLowerCase().endsWith('.mkv');
  }

  Future<void> _toggleLike(String postId, Map<String, dynamic> post) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;
    final isCurrentlyLiked = post['isLiked'] ?? false;
    final likers = List<Map<String, dynamic>>.from(post['likers'] ?? []);

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User data not found.', style: TextStyle(color: Colors.black)),
            backgroundColor: Color(0xFFD4AF37),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final userData = userDoc.data()!;
      final userName = userData['name'] ?? 'Anonymous';
      final userProfile = userData['profileImageUrl'] ?? 'https://i.pravatar.cc/150?img=0';

      if (isCurrentlyLiked) {
        likers.removeWhere((liker) => liker['userId'] == userId);
      } else {
        likers.add({
          'userId': userId,
          'userName': userName,
          'profileImage': userProfile,
        });
      }

      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'isLiked': !isCurrentlyLiked,
        'likes': isCurrentlyLiked ? post['likes'] - 1 : post['likes'] + 1,
        'likers': likers,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update like: $e', style: const TextStyle(color: Colors.black)),
          backgroundColor: const Color(0xFFD4AF37),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _addComment(String postId, String commentText) {
    if (commentText.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Anonymous';
    final userProfile = user?.photoURL ?? 'https://i.pravatar.cc/150?img=0';

    FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'comments': FieldValue.arrayUnion([
        {
          'user': userName,
          'profile': userProfile,
          'text': commentText.trim(),
          'time': DateTime.now().toIso8601String(), // Store as ISO 8601
        }
      ]),
      'commentsCount': FieldValue.increment(1),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comment added!', style: TextStyle(color: Colors.black)),
        backgroundColor: Color(0xFFD4AF37),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sharePost(Map<String, dynamic> post) {
    Share.share(
      '${post['content']} Check out this post by ${post['user']} on AMO! ${post['image']}',
      subject: 'Check out this post!',
    );
  }

  void _openAdLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open ad link.', style: TextStyle(color: Colors.black)),
          backgroundColor: Color(0xFFD4AF37),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showReportDialog(String postId, Map<String, dynamic> post) {
    String? selectedReason;
    TextEditingController descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Report Post',
          style: TextStyle(color: Color(0xFFF5E6CC)),
        ),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Reason for Report',
                    labelStyle: TextStyle(color: Colors.grey[500]),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD4AF37)),
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFFF5E6CC)),
                  dropdownColor: Colors.grey[900],
                  items: const [
                    DropdownMenuItem(value: 'Nudity', child: Text('Nudity')),
                    DropdownMenuItem(value: 'Violence', child: Text('Violence')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    selectedReason = value;
                  },
                  validator: (value) => value == null ? 'Please select a reason' : null,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Color(0xFFF5E6CC)),
                  maxLines: 3,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: 'Describe the issue (optional)',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD4AF37)),
                    ),
                    counterStyle: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (selectedReason != null) {
                try {
                  await FirebaseFirestore.instance.collection('reports').add({
                    'username': post['user'] ?? 'Anonymous',
                    'postId': postId,
                    'imageUrl': post['image'] ?? '',
                    'reason': selectedReason,
                    'description': descriptionController.text,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Report submitted successfully', style: TextStyle(color: Colors.black)),
                      backgroundColor: Color(0xFFD4AF37),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to submit report: $e', style: const TextStyle(color: Colors.black)),
                      backgroundColor: Color(0xFFD4AF37),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a reason for the report', style: TextStyle(color: Colors.black)),
                    backgroundColor: Color(0xFFD4AF37),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Submit', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    _refreshController.refreshCompleted();
  }

  void _showComments(String postId, Map<String, dynamic> post) {
    final TextEditingController commentController = TextEditingController();
    final ScrollController scrollController = ScrollController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, _) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Comments (${post['commentsCount'] ?? 0})',
                          style: const TextStyle(
                            color: Color(0xFFF5E6CC),
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFFD4AF37)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFFD4AF37), height: 1),
                  Expanded(
                    child: post['comments']?.isEmpty ?? true
                        ? const Center(
                            child: Text(
                              'No comments yet. Be the first to comment!',
                              style: TextStyle(color: Color(0xFFF5E6CC), fontSize: 16.0),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16.0),
                            itemCount: post['comments'].length,
                            itemBuilder: (context, commentIndex) {
                              final comment = post['comments'][commentIndex];
                              // Handle invalid or 'Just now' comment times
                              String commentTime;
                              try {
                                commentTime = comment['time'] != null &&
                                        comment['time'] != 'Just now'
                                    ? DateFormat('dd MMM yyyy')
                                        .format(DateTime.parse(comment['time']))
                                    : 'Recent';
                              } catch (e) {
                                commentTime = 'Recent';
                              }
                              return FadeInUp(
                                duration: const Duration(milliseconds: 300),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundImage: CachedNetworkImageProvider(
                                          comment['profile'] ??
                                              'https://i.pravatar.cc/150?img=0',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  comment['user'] ?? 'Anonymous',
                                                  style: const TextStyle(
                                                    color: Color(0xFFF5E6CC),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[900],
                                                    borderRadius:
                                                        BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    commentTime,
                                                    style: const TextStyle(
                                                      color: Color(0xFFD4AF37),
                                                      fontSize: 10.0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              comment['text'] ?? '',
                                              style: const TextStyle(
                                                color: Color(0xFFF5E6CC),
                                                fontSize: 13.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      border: Border(top: BorderSide(color: Color(0xFFD4AF37))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            style: const TextStyle(color: Color(0xFFF5E6CC)),
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              hintStyle: const TextStyle(color: Color(0xFFD4AF37)),
                              filled: true,
                              fillColor: Colors.grey[900],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFFD4AF37)),
                          onPressed: () {
                            _addComment(postId, commentController.text);
                            commentController.clear();
                            Navigator.pop(context);
                            _showComments(postId, post);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      commentController.dispose();
      scrollController.dispose();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Posts',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37),
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD4AF37),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Create new post feature coming soon!',
                  style: TextStyle(color: Colors.black)),
              backgroundColor: Color(0xFFD4AF37),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        header: const WaterDropMaterialHeader(backgroundColor: Color(0xFFD4AF37)),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .orderBy('time', descending: true) // Use 'time' field
              .snapshots(),
          builder: (context, postSnapshot) {
            if (postSnapshot.hasError) {
              debugPrint('Post snapshot error: ${postSnapshot.error}');
              return const Center(
                child: Text(
                  'Error loading posts. Please try again.',
                  style: TextStyle(color: Color(0xFFF5E6CC)),
                ),
              );
            }
            if (postSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
            }
            final posts = postSnapshot.data!.docs;
            if (posts.isEmpty) {
              debugPrint('No posts found in Firestore');
              return const Center(
                child: Text(
                  'No posts available. Be the first to post!',
                  style: TextStyle(color: Color(0xFFF5E6CC), fontSize: 16.0),
                ),
              );
            }
            debugPrint('Fetched ${posts.length} posts');

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('ads').snapshots(),
              builder: (context, adSnapshot) {
                if (adSnapshot.hasError) {
                  debugPrint('Ad snapshot error: ${adSnapshot.error}');
                  return const Center(
                    child: Text(
                      'Error loading ads',
                      style: TextStyle(color: Color(0xFFF5E6CC)),
                    ),
                  );
                }
                if (adSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
                }
                final ads = adSnapshot.data!.docs;
                debugPrint('Fetched ${ads.length} ads');

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: posts.length + (posts.length ~/ 3),
                  itemBuilder: (context, index) {
                    if (index % 4 == 3) {
                      final adIndex = (index ~/ 4) % ads.length;
                      final ad = ads[adIndex].data() as Map<String, dynamic>;
                      final adImageUrl = ad['image'] ?? '';

                      return FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => _openAdLink(ad['url'] ?? ''),
                                child: Card(
                                  elevation: 4.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  color: Colors.black,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFD4AF37), Colors.black],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius
                                              .vertical(top: Radius.circular(20.0)),
                                          child: _isVideoUrl(adImageUrl)
                                              ? Container(
                                                  height: 200,
                                                  color: Colors.grey[800],
                                                  child: const Center(
                                                    child: Text(
                                                      'Video Ad',
                                                      style: TextStyle(
                                                        color: Color(0xFFD4AF37),
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : CachedNetworkImage(
                                                  imageUrl: adImageUrl,
                                                  width: double.infinity,
                                                  fit: BoxFit.contain,
                                                  placeholder: (context, url) =>
                                                      Shimmer.fromColors(
                                                    baseColor: Colors.grey[800]!,
                                                    highlightColor:
                                                        Colors.grey[700]!,
                                                    child: Container(
                                                      height: 200,
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) {
                                                    debugPrint(
                                                        'Ad image error: $error, URL: $url');
                                                    return Container(
                                                      height: 200,
                                                      color: Colors.grey[800],
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.broken_image,
                                                          color: Color(0xFFD4AF37),
                                                          size: 50,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ad['title'] ?? 'Ad Title',
                                                style: const TextStyle(
                                                  color: Color(0xFFF5E6CC),
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                ad['description'] ??
                                                    'Ad Description',
                                                style: const TextStyle(
                                                  color: Color(0xFFF5E6CC),
                                                  fontSize: 14.0,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 12),
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: ElevatedButton(
                                                  onPressed: () =>
                                                      _openAdLink(ad['url'] ?? ''),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFFD4AF37),
                                                    foregroundColor: Colors.black,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Learn More',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 220,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const PromoteDetailsPage()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4AF37),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14.0,
                                      horizontal:
                                          screenWidth < 360 ? 16.0 : 24.0,
                                    ),
                                    elevation: 4.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.black, size: 24),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Promote',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              screenWidth < 360 ? 14.0 : 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final postIndex = index - (index ~/ 4);
                    final post = posts[postIndex].data() as Map<String, dynamic>;
                    final postId = posts[postIndex].id;
                    final postImageUrl = post['image'] ?? '';
                    // Parse time string
                    String formattedTime;
                    try {
                      formattedTime = post['time'] != null
                          ? DateFormat('dd MMM yyyy')
                              .format(DateTime.parse(post['time']))
                          : DateFormat('dd MMM yyyy').format(DateTime.now());
                    } catch (e) {
                      formattedTime =
                          DateFormat('dd MMM yyyy').format(DateTime.now());
                      debugPrint('Error parsing post time: $e');
                    }

                    return FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          color: Colors.black,
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                            post['profile'] ??
                                                'https://i.pravatar.cc/150?img=0',
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                post['user'] ?? 'Anonymous',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.0,
                                                  color: Color(0xFFF5E6CC),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[900],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                      color:
                                                          const Color(0xFFD4AF37),
                                                      width: 1),
                                                ),
                                                child: Text(
                                                  formattedTime,
                                                  style: const TextStyle(
                                                    color: Color(0xFFD4AF37),
                                                    fontSize: 12.0,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12.0),
                                      child: _isVideoUrl(postImageUrl)
                                          ? Container(
                                              height: 200,
                                              color: Colors.grey[800],
                                              child: const Center(
                                                child: Text(
                                                  'Video Post',
                                                  style: TextStyle(
                                                    color: Color(0xFFD4AF37),
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: postImageUrl,
                                              width: double.infinity,
                                              height: 200,
                                              fit: BoxFit.contain,
                                              placeholder: (context, url) =>
                                                  Shimmer.fromColors(
                                                baseColor: Colors.grey[800]!,
                                                highlightColor:
                                                    Colors.grey[700]!,
                                                child: Container(
                                                  height: 200,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) {
                                                debugPrint(
                                                    'Post image error: $error, URL: $url');
                                                return Container(
                                                  height: 200,
                                                  color: Colors.grey[800],
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      color: Color(0xFFD4AF37),
                                                      size: 50,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      post['content'] ?? 'No content available',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        color: Color(0xFFF5E6CC),
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                child: Icon(
                                                  post['isLiked']
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: post['isLiked']
                                                      ? Colors.red
                                                      : const Color(0xFFD4AF37),
                                                ),
                                              ),
                                              onPressed: () =>
                                                  _toggleLike(postId, post),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        LikesPage(
                                                            postId: postId),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                '${post['likes'] ?? 0}',
                                                style: const TextStyle(
                                                    color: Color(0xFFD4AF37),
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.comment,
                                                  color: Color(0xFFD4AF37)),
                                              onPressed: () =>
                                                  _showComments(postId, post),
                                            ),
                                            Text(
                                              '${post['commentsCount'] ?? 0}',
                                              style: const TextStyle(
                                                  color: Color(0xFFD4AF37),
                                                  fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.share,
                                              color: Color(0xFFD4AF37)),
                                          onPressed: () => _sharePost(post),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.report,
                                      color: Color(0xFFD4AF37), size: 28),
                                  onPressed: () =>
                                      _showReportDialog(postId, post),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}