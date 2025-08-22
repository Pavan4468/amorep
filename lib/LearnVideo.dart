import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LearnVideoPage extends StatefulWidget {
  const LearnVideoPage({super.key});

  @override
  _LearnVideoPageState createState() => _LearnVideoPageState();
}

class _LearnVideoPageState extends State<LearnVideoPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> categories = ['Popular', 'Influencer', 'Courses', 'Cultural', 'Religion'];
  String? selectedCategory;
  bool _isRefreshing = false;

  Future<void> _refreshVideos() async {
    setState(() {
      _isRefreshing = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Black background
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: const Text(
            'For You',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Category Chips
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;
                final colors = [
                  const Color(0xFFB8860B),
                  const Color(0xFFB8860B),
                  const Color(0xFFB8860B),
                  const Color(0xFFFFA500),
                  const Color(0xFFB8860B),
                ];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.purple : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = selected ? category : null;
                        _refreshVideos(); // Refresh when category changes
                      });
                    },
                    selectedColor: colors[index % colors.length],
                    backgroundColor: colors[index % colors.length].withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: colors[index % colors.length].withOpacity(0.5)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              },
            ),
          ),
          // Video List with Pull-to-Refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshVideos,
              color: const Color(0xFFFFD700),
              backgroundColor: const Color(0xFF1C2526),
              child: StreamBuilder<QuerySnapshot>(
                stream: selectedCategory == null
                    ? _firestore.collection('videos').orderBy('time', descending: true).snapshots()
                    : _firestore
                        .collection('videos')
                        .where('category', isEqualTo: selectedCategory)
                        .orderBy('time', descending: true)
                        .snapshots(),
                builder: (context, videoSnapshot) {
                  if (videoSnapshot.connectionState == ConnectionState.waiting || _isRefreshing) {
                    return const Center(
                      child: SpinKitCircle(color: Color(0xFFFFD700), size: 50),
                    );
                  }
                  if (videoSnapshot.hasError) {
                    return const Center(child: Text('Error loading videos', style: TextStyle(color: Colors.white)));
                  }
                  if (!videoSnapshot.hasData || videoSnapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No videos available', style: TextStyle(color: Colors.white)));
                  }

                  final videos = videoSnapshot.data!.docs;
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('reel_ads').snapshots(),
                    builder: (context, adSnapshot) {
                      if (adSnapshot.hasError) {
                        return const Center(child: Text('Error fetching ads', style: TextStyle(color: Colors.white)));
                      }
                      if (adSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }
                      final ads = adSnapshot.data!.docs;
                      if (ads.isEmpty) {
                        return const Center(child: Text('No ads available in reel_ads collection', style: TextStyle(color: Colors.white)));
                      }
                      List<dynamic> combinedItems = [];
                      int adIndex = 0;
                      for (int i = 0; i < videos.length; i++) {
                        combinedItems.add(videos[i]);
                        if ((i + 1) % 3 == 0 && ads.isNotEmpty) {
                          combinedItems.add(ads[adIndex % ads.length]);
                          adIndex++;
                        }
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: combinedItems.length,
                        itemBuilder: (context, index) {
                          final item = combinedItems[index];
                          if (item is QueryDocumentSnapshot && item.reference.parent.id == 'reel_ads') {
                            return ReelAdWidget(ad: item.data() as Map<String, dynamic>);
                          }
                          return VideoCard(video: item.data() as Map<String, dynamic>);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReelAdWidget extends StatefulWidget {
  final Map<String, dynamic> ad;

  const ReelAdWidget({required this.ad, super.key});

  @override
  _ReelAdWidgetState createState() => _ReelAdWidgetState();
}

class _ReelAdWidgetState extends State<ReelAdWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.ad['videoUrl'] as String)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  Future<void> _launchAdLink(BuildContext context) async {
    final url = widget.ad['link'] as String;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)], // Vibrant purple gradient for ads
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _togglePlayPause,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.isInitialized
                        ? _controller.value.aspectRatio
                        : 16 / 9,
                    child: _controller.value.isInitialized
                        ? VideoPlayer(_controller)
                        : const Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),
                  if (!_isPlaying)
                    AnimatedOpacity(
                      opacity: _isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        FontAwesomeIcons.playCircle,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.ad['title'] as String? ?? 'Ad',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.ad['description'] as String? ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade300,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => _launchAdLink(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6A1B9A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: Text(
                        widget.ad['buttonText'] as String? ?? 'Learn More',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}

class VideoCard extends StatefulWidget {
  final Map<String, dynamic> video;

  const VideoCard({required this.video, super.key});

  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLiked = false;
  late int _likes;
  late int _views;
  late int _shares;
  final TextEditingController _commentController = TextEditingController();
  String? _username;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.video['videoUrl'] as String)
      ..initialize().then((_) {
        setState(() {});
      });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _likes = widget.video['likes'] as int? ?? 0;
    _views = widget.video['views'] as int? ?? 0;
    _shares = widget.video['shares'] as int? ?? 0;

    _loadUserData();
    _checkIfLiked();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _username = userDoc.data()?['username'] as String? ?? 'Anonymous';
        });
      }
    }
  }

  Future<void> _checkIfLiked() async {
    final user = _auth.currentUser;
    if (user != null) {
      final likeDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('likedVideos')
          .doc(widget.video['id'] as String?)
          .get();
      setState(() {
        _isLiked = likeDoc.exists;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
        _views += 1;
        _firestore
            .collection('videos')
            .doc(widget.video['id'] as String?)
            .update({'views': _views});
      }
    });
  }

  Future<void> _toggleLike() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to like this video')),
      );
      return;
    }

    setState(() {
      _isLiked = !_isLiked;
      _likes += _isLiked ? 1 : -1;
    });

    final videoRef = _firestore.collection('videos').doc(widget.video['id'] as String?);
    final userLikeRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('likedVideos')
        .doc(widget.video['id'] as String?);

    await _firestore.runTransaction((transaction) async {
      transaction.update(videoRef, {'likes': _likes});
      if (_isLiked) {
        transaction.set(userLikeRef, {'likedAt': FieldValue.serverTimestamp()});
      } else {
        transaction.delete(userLikeRef);
      }
    });
  }

  Future<void> _addComment() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to comment')),
      );
      return;
    }

    if (_commentController.text.trim().isNotEmpty) {
      final comment = {
        'userId': user.uid,
        'username': _username ?? 'Anonymous',
        'text': _commentController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('videos')
          .doc(widget.video['id'] as String?)
          .collection('comments')
          .add(comment);

      _commentController.clear();
    }
  }

  void _showCommentsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C2526),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.6,
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('videos')
              .doc(widget.video['id'] as String?)
              .collection('comments')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
            }
            if (snapshot.hasError) {
              return const Text('Error loading comments', style: TextStyle(color: Colors.white));
            }
            final comments = snapshot.data?.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList() ??
                [];
            return Column(
              children: [
                Text(
                  "Comments (${comments.length})",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return ListTile(
                        title: Text(
                          comment['username'] as String? ?? 'Anonymous',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                        subtitle: Text(
                          comment['text'] as String? ?? '',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(color: Colors.grey),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Add a comment...",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFFFD700)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addComment,
                      icon: const Icon(FontAwesomeIcons.paperPlane, color: Color(0xFFFFD700)),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _shareVideo() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to share this video')),
      );
      return;
    }

    setState(() {
      _shares += 1;
    });

    await _firestore
        .collection('videos')
        .doc(widget.video['id'] as String?)
        .update({'shares': _shares});

    final shareText = "${widget.video['title']} - Check out this amazing travel video! ${widget.video['videoUrl']}";
    await Share.share(
      shareText,
      subject: widget.video['title'] as String?,
    );
  }

  Future<void> _launchDonationLink() async {
    const url = 'https://buy.stripe.com/cN28yEcZIghn4Zq6op';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open donation link')),
      );
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return "${(number / 1000000).toStringAsFixed(1)}M";
    } else if (number >= 1000) {
      return "${(number / 1000).toStringAsFixed(1)}K";
    }
    return number.toString();
  }

  String _formatTimestamp(dynamic time) {
    if (time is Timestamp) {
      final dateTime = time.toDate();
      return DateFormat('MMM d, yyyy, h:mm a').format(dateTime);
    } else if (time is String) {
      return time;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      color: const Color(0xFF1C2526),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _togglePlayPause,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.isInitialized
                        ? _controller.value.aspectRatio
                        : 16 / 9,
                    child: _controller.value.isInitialized
                        ? VideoPlayer(_controller)
                        : Image.network(
                            widget.video['thumbnail'] as String? ?? '',
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                  child: CircularProgressIndicator(color: const Color(0xFFFFD700)));
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error, color: Colors.red),
                          ),
                  ),
                  if (!_isPlaying)
                    AnimatedOpacity(
                      opacity: _isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        FontAwesomeIcons.playCircle,
                        size: 80,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video['title'] as String? ?? 'Untitled',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.video['subtitle'] as String? ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${_formatNumber(_views)} views • ${_formatTimestamp(widget.video['time'])}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleLike,
                      child: AnimatedScale(
                        scale: _isLiked ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                          color: _isLiked ? const Color(0xFFFFD700) : Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatNumber(_likes),
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: _showCommentsDialog,
                      child: Icon(FontAwesomeIcons.comment, color: Colors.grey.shade400, size: 24),
                    ),
                    const SizedBox(width: 6),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('videos')
                          .doc(widget.video['id'] as String?)
                          .collection('comments')
                          .snapshots(),
                      builder: (context, snapshot) {
                        final commentCount = snapshot.data?.docs.length ?? 0;
                        return Text(
                          _formatNumber(commentCount),
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: _shareVideo,
                      child: Icon(FontAwesomeIcons.share, color: Colors.grey.shade400, size: 24),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatNumber(_shares),
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _launchDonationLink,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth < 360 ? 8.0 : 12.0,
                      vertical: screenWidth < 360 ? 6.0 : 8.0,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      FontAwesomeIcons.euroSign,
                      size: 20,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}