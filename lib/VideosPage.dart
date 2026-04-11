import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

import 'notification.dart';

/// Firestore may store [likedBy] as `List<String>` (uids) or legacy `List<Map>` (e.g. liker objects).
List<String> _parseReelLikedBy(dynamic raw) {
  if (raw == null) return [];
  if (raw is! List) return [];
  final out = <String>[];
  for (final e in raw) {
    if (e is String && e.isNotEmpty) {
      out.add(e);
    } else if (e is Map) {
      final id = e['userId'] ?? e['uid'] ?? e['likerId'];
      if (id is String && id.isNotEmpty) out.add(id);
    }
  }
  return out;
}

class ReelsPage extends StatefulWidget {
  final void Function(String targetId, bool isReel)? onNotificationNavigate;

  const ReelsPage({Key? key, this.onNotificationNavigate}) : super(key: key);

  @override
  ReelsPageState createState() => ReelsPageState();
}

class ReelsPageState extends State<ReelsPage> {
  final PageController _pageController = PageController();
  String? _pendingReelId;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().then((_) {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Opens the reel at this Firestore document id in the vertical feed.
  void scrollToReel(String reelId) {
    _pendingReelId = reelId;
    setState(() {});
  }

  void _consumePendingReelScroll(List<dynamic> combinedItems) {
    final pending = _pendingReelId;
    if (pending == null) return;
    for (var i = 0; i < combinedItems.length; i++) {
      final item = combinedItems[i];
      if (item is QueryDocumentSnapshot &&
          item.reference.parent.id == 'reels' &&
          item.id == pending) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _pageController.hasClients) {
            _pageController.jumpToPage(i);
          }
        });
        _pendingReelId = null;
        break;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Reels',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37),
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .where('read', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data?.docs.length ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Color(0xFFD4AF37)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsPage(
                            onNavigateToContent: widget.onNotificationNavigate,
                          ),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('reels')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              debugPrint('Reels snapshot error: ${snapshot.error}');
              return const Center(
                  child: Text('Error fetching reels',
                      style: TextStyle(color: Colors.white)));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }
            final videos = snapshot.data!.docs;
            if (videos.isEmpty) {
              debugPrint('No reels found in Firestore');
              return const Center(
                  child: Text('No reels available. Be the first to post!',
                      style: TextStyle(color: Colors.white, fontSize: 16.0)));
            }
            debugPrint('Fetched ${videos.length} reels');

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('reel_ads').snapshots(),
              builder: (context, adSnapshot) {
                if (adSnapshot.hasError) {
                  debugPrint('Ad snapshot error: ${adSnapshot.error}');
                  return const Center(
                      child: Text('Error fetching ads',
                          style: TextStyle(color: Colors.white)));
                }
                if (adSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                }
                final ads = adSnapshot.data!.docs;
                debugPrint('Fetched ${ads.length} ads');

                List<dynamic> combinedItems = [];
                int adIndex = 0;
                for (int i = 0; i < videos.length; i++) {
                  combinedItems.add(videos[i]);
                  if ((i + 1) % 3 == 0 && ads.isNotEmpty) {
                    combinedItems.add(ads[adIndex % ads.length]);
                    adIndex++;
                  }
                }

                _consumePendingReelScroll(combinedItems);

                return PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: combinedItems.length,
                  itemBuilder: (context, index) {
                    final item = combinedItems[index];
                    if (item is QueryDocumentSnapshot &&
                        item.reference.parent.id == 'reels') {
                      final data = item.data() as Map<String, dynamic>;
                      // Parse createdAt
                      String formattedTime;
                      try {
                        formattedTime = data['createdAt'] != null
                            ? DateFormat('dd MMM yyyy')
                                .format(DateTime.parse(data['createdAt']))
                            : 'Recent';
                      } catch (e) {
                        formattedTime = 'Recent';
                        debugPrint('Error parsing reel createdAt: $e');
                      }
                      return ReelItem(
                        key: ValueKey(item.id),
                        reelId: item.id,
                        reelOwnerId:
                            data['createdBy'] ?? data['userId'] ?? '',
                        likedBy: _parseReelLikedBy(data['likedBy']),
                        videoUrl: data["videoUrl"] ?? '',
                        username: data["user"] ?? 'Anonymous',
                        profilePic:
                            data["profile"] ?? 'https://i.pravatar.cc/150?img=0',
                        isFollowing: data["isFollowing"] ?? false,
                        likes: data["likes"] ?? 0,
                        comments: List<String>.from(data["comments"] ?? []),
                        createdAt: formattedTime,
                        onFollowToggle: () {
                          FirebaseFirestore.instance
                              .collection('reels')
                              .doc(item.id)
                              .update({'isFollowing': !data["isFollowing"]});
                        },
                      );
                    } else {
                      final adData = item.data() as Map<String, dynamic>;
                      return AdItem(
                        videoUrl: adData["videoUrl"] ?? '',
                        title: adData["title"] ?? 'Ad Title',
                        description: adData["description"] ?? 'Ad Description',
                        buttonText: adData["buttonText"] ?? 'Learn More',
                        link: adData["link"] ?? '',
                      );
                    }
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

class ReelItem extends StatefulWidget {
  final String reelId;
  /// Firestore uid of the reel creator (`createdBy` from upload).
  final String reelOwnerId;
  /// Uids who liked this reel (persisted; drives filled heart when user returns).
  final List<String> likedBy;
  final String videoUrl;
  final String username;
  final String profilePic;
  final bool isFollowing;
  final int likes;
  final List<String> comments;
  final String createdAt;
  final VoidCallback onFollowToggle;

  const ReelItem({
    Key? key,
    required this.reelId,
    required this.reelOwnerId,
    required this.likedBy,
    required this.videoUrl,
    required this.username,
    required this.profilePic,
    required this.isFollowing,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.onFollowToggle,
  }) : super(key: key);

  @override
  _ReelItemState createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  late VideoPlayerController _controller;
  late bool _isLiked;
  late int _likeCount;
  late List<String> _comments;
  bool _showComments = false;
  bool _isVideoInitialized = false;

  bool _isLikedFromWidget() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    return widget.likedBy.contains(uid);
  }

  @override
  void initState() {
    super.initState();
    _isLiked = _isLikedFromWidget();
    _likeCount = widget.likes;
    _comments = widget.comments;
    _initializeVideo();
  }

  @override
  void didUpdateWidget(ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reelId != oldWidget.reelId) {
      _isLiked = _isLikedFromWidget();
      _likeCount = widget.likes;
      _comments = List<String>.from(widget.comments);
      return;
    }
    if (!listEquals(widget.likedBy, oldWidget.likedBy)) {
      _isLiked = _isLikedFromWidget();
    }
    if (widget.likes != oldWidget.likes) {
      _likeCount = widget.likes;
    }
    if (!listEquals(widget.comments, oldWidget.comments)) {
      _comments = List<String>.from(widget.comments);
    }
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
          _controller.play();
          _controller.setLooping(true);
        }
      }).catchError((error) {
        debugPrint('Video initialization error: $error, URL: ${widget.videoUrl}');
        if (mounted) {
          setState(() {
            _isVideoInitialized = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load reel video: $error')),
          );
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please sign in to like a reel.',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Color(0xFFD4AF37),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final userId = user.uid;
    final wasLiked = _isLiked;
    final prevCount = _likeCount;

    // Update heart immediately; network work runs after (was blocked on users doc fetch before).
    setState(() {
      _isLiked = !wasLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      if (wasLiked) {
        await FirebaseFirestore.instance
            .collection('reels')
            .doc(widget.reelId)
            .update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([userId]),
        });
      } else {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (!userDoc.exists) {
          if (mounted) {
            setState(() {
              _isLiked = wasLiked;
              _likeCount = prevCount;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'User data not found.',
                  style: TextStyle(color: Colors.black),
                ),
                backgroundColor: Color(0xFFD4AF37),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
        await FirebaseFirestore.instance
            .collection('reels')
            .doc(widget.reelId)
            .update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([userId]),
        });

        final userData = userDoc.data()!;
        final likerName = userData['name'] ?? 'Anonymous';
        final likerProfile = userData['profileImageUrl'] ??
            'https://i.pravatar.cc/150?img=0';

        if (widget.reelOwnerId.isNotEmpty && widget.reelOwnerId != userId) {
          await FirebaseFirestore.instance.collection('notifications').add({
            'type': 'like',
            'postId': widget.reelId,
            'reelId': widget.reelId,
            'targetType': 'reel',
            'userId': widget.reelOwnerId,
            'likerId': userId,
            'likerName': likerName,
            'likerProfile': likerProfile,
            'message': '$likerName liked your Reel',
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasLiked ? 'Reel unliked!' : 'Reel liked!',
              style: const TextStyle(color: Colors.black),
            ),
            backgroundColor: const Color(0xFFD4AF37),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLiked = wasLiked;
          _likeCount = prevCount;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update like: $e',
              style: const TextStyle(color: Colors.black),
            ),
            backgroundColor: const Color(0xFFD4AF37),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showCommentDialog() {
    TextEditingController commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Add a Comment',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: commentController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Write your comment...',
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
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (commentController.text.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance
                      .collection('reels')
                      .doc(widget.reelId)
                      .update({
                    'comments': FieldValue.arrayUnion([commentController.text])
                  });
                  setState(() {
                    _comments.add(commentController.text);
                  });
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add comment: $e')),
                  );
                }
              }
            },
            child: const Text('Post',
                style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    String? selectedReason;
    TextEditingController descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Report Reel',
          style: TextStyle(color: Colors.white),
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
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.grey[900],
                  items: const [
                    DropdownMenuItem(value: 'Nudity', child: Text('Nudity')),
                    DropdownMenuItem(value: 'Violence', child: Text('Violence')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    selectedReason = value;
                  },
                  validator: (value) =>
                      value == null ? 'Please select a reason' : null,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
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
                    'username': widget.username,
                    'reelId': widget.reelId,
                    'videoUrl': widget.videoUrl,
                    'reason': selectedReason,
                    'description': descriptionController.text,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Report submitted successfully')),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to submit report: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please select a reason for the report')),
                );
              }
            },
            child: const Text('Submit',
                style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }

  void _toggleComments() {
    setState(() {
      _showComments = !_showComments;
    });
  }

  void _shareContent() {
    Share.share(
      'Check out this awesome reel by ${widget.username}! ${widget.videoUrl}',
      subject: 'Share Reel',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _isVideoInitialized
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: VideoPlayer(_controller),
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 80,
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(widget.profilePic),
                backgroundColor: Colors.grey[800],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onFollowToggle,
                        child: Text(
                          widget.isFollowing ? 'Following' : 'Follow',
                          style: TextStyle(
                            color: widget.isFollowing ? Colors.grey : Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFD4AF37), width: 1),
                        ),
                        child: Text(
                          widget.createdAt,
                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          top: 20,
          child: IconButton(
            icon: const Icon(Icons.report, color: Colors.white, size: 32),
            onPressed: _showReportDialog,
          ),
        ),
        Positioned(
          right: 16,
          bottom: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : Colors.white,
                      size: 32,
                    ),
                    onPressed: _toggleLike,
                  ),
                  Text(
                    _likeCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.comment, color: Colors.white, size: 32),
                    onPressed: _toggleComments,
                  ),
                  Text(
                    _comments.length.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white, size: 32),
                    onPressed: _shareContent,
                  ),
                  const Text(
                    'Share',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_showComments)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Comments (${_comments.length})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: _toggleComments,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _comments.isEmpty
                        ? const Center(
                            child: Text(
                              'No comments yet',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundImage:
                                          NetworkImage(widget.profilePic),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.username,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            _comments[index],
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey[800],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onSubmitted: (value) async {
                              if (value.isNotEmpty) {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('reels')
                                      .doc(widget.reelId)
                                      .update({
                                    'comments': FieldValue.arrayUnion([value])
                                  });
                                  setState(() {
                                    _comments.add(value);
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Failed to add comment: $e')),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon:
                              const Icon(Icons.send, color: Color(0xFFD4AF37)),
                          onPressed: _showCommentDialog,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_isVideoInitialized &&
            !_controller.value.isPlaying &&
            !_showComments)
          const Center(
            child: Icon(
              Icons.play_arrow,
              color: Colors.white70,
              size: 60,
            ),
          ),
      ],
    );
  }
}

class AdItem extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String description;
  final String buttonText;
  final String link;

  const AdItem({
    Key? key,
    required this.videoUrl,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.link,
  }) : super(key: key);

  @override
  _AdItemState createState() => _AdItemState();
}

class _AdItemState extends State<AdItem> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
          _controller.play();
          _controller.setLooping(true);
        }
      }).catchError((error) {
        debugPrint('Ad video initialization error: $error, URL: ${widget.videoUrl}');
        if (mounted) {
          setState(() {
            _isVideoInitialized = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load ad video: $error')),
          );
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _isVideoInitialized
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: VideoPlayer(_controller),
              )
            : const Center(
                child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
              ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.5),
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
            border: Border.all(color: Color(0xFFD4AF37), width: 3),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFD4AF37).withOpacity(0.3),
                  Colors.black.withOpacity(0.3)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Color(0xFFD4AF37), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFD4AF37).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bolt, color: Color(0xFFD4AF37), size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Featured Ad',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Color(0xFFD4AF37).withOpacity(0.6),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      widget.buttonText.toLowerCase() == 'app'
                          ? Icons.phone_iphone
                          : Icons.link,
                      color: Colors.white70,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchURL(widget.link),
                    icon: Icon(
                      widget.buttonText.toLowerCase() == 'app'
                          ? Icons.download
                          : Icons.open_in_new,
                      color: Colors.black,
                      size: 22,
                    ),
                    label: Text(
                      widget.buttonText.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 14),
                      elevation: 10,
                      shadowColor: Color(0xFFD4AF37).withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xFFD4AF37), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFD4AF37).withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              'AD',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        if (_isVideoInitialized && !_controller.value.isPlaying)
          Center(
            child: Icon(
              Icons.play_circle_filled,
              color: Color(0xFFD4AF37).withOpacity(0.8),
              size: 90,
            ),
          ),
      ],
    );
  }
}