import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'adspay.dart'; // Import the adpay.dart file

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  int _selectedIndex = 0;
  bool _isPremium = false;
  bool _isLoading = false;
  final String _stripePaymentUrl = 'https://buy.stripe.com/4gw16c4tcaX363ucN0';

  final _imageDescriptionController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _eventAddressController = TextEditingController();
  DateTime? _eventDate;
  TimeOfDay? _eventTime;
  String? _imagePath;
  String? _eventImagePath;
  String? _reelPath;

  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'dfn63u46n',
    'PavanReddy',
    cache: false,
  );

  @override
  void dispose() {
    _imageDescriptionController.dispose();
    _eventDescriptionController.dispose();
    _eventAddressController.dispose();
    super.dispose();
  }

  Future<String?> _uploadFile(File file, bool isVideo) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: isVideo
              ? CloudinaryResourceType.Video
              : CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Upload failed: $e');
      return null;
    }
  }

  Future<void> _pickImage({required bool forEvent}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (forEvent) {
          _eventImagePath = image.path;
        } else {
          _imagePath = image.path;
        }
      });
      Fluttertoast.showToast(msg: 'Image selected from gallery!');
    } else {
      Fluttertoast.showToast(msg: 'No image selected.');
    }
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _reelPath = result.files.single.path;
      });
      Fluttertoast.showToast(msg: 'Video selected!');
    } else {
      Fluttertoast.showToast(msg: 'No video selected.');
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _eventDate = picked;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _eventTime = picked;
      });
    }
  }

  Future<void> _submitUpload() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Fluttertoast.showToast(msg: 'Please log in to upload.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Fetch user profile data from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final userName =
        userDoc.exists ? userDoc['username'] ?? 'Anonymous' : 'Anonymous';
    final userProfile = userDoc.exists &&
            userDoc['profileImageUrl'] != null &&
            userDoc['profileImageUrl'].isNotEmpty
        ? userDoc['profileImageUrl']
        : 'https://i.pravatar.cc/150?img=0';

    switch (_selectedIndex) {
      case 0: // Image Upload
        if (_imagePath == null || _imageDescriptionController.text.isEmpty) {
          Fluttertoast.showToast(
              msg: 'Please select an image and add a description.');
          setState(() {
            _isLoading = false;
          });
          return;
        }
        final imageUrl = await _uploadFile(File(_imagePath!), false);
        if (imageUrl != null) {
          await FirebaseFirestore.instance.collection('posts').add({
            'user': userName,
            'profile': userProfile,
            'time': DateTime.now().toIso8601String(),
            'content': _imageDescriptionController.text,
            'image': imageUrl,
            'userId': user.uid,
            'likes': 0,
            'commentsCount': 0,
            'isLiked': false,
            'comments': [],
            'createdBy': user.uid,
          });
          Fluttertoast.showToast(
            msg: 'Image uploaded: ${_imageDescriptionController.text}',
          );
          setState(() {
            _imagePath = null;
            _imageDescriptionController.clear();
          });
        }
        break;
      case 1: // Event Upload
        if (_eventImagePath == null ||
            _eventDescriptionController.text.isEmpty ||
            _eventAddressController.text.isEmpty ||
            _eventDate == null ||
            _eventTime == null) {
          Fluttertoast.showToast(msg: 'Please fill all event details.');
          setState(() {
            _isLoading = false;
          });
          return;
        }
        final imageUrl = await _uploadFile(File(_eventImagePath!), false);
        if (imageUrl != null) {
          final eventDateTime = DateTime(
            _eventDate!.year,
            _eventDate!.month,
            _eventDate!.day,
            _eventTime!.hour,
            _eventTime!.minute,
          );
          await FirebaseFirestore.instance.collection('events').add({
            'name': _eventDescriptionController.text,
            'image': imageUrl,
            'date': DateFormat('yyyy-MM-dd').format(_eventDate!),
            'time': _eventTime!.format(context),
            'location': _eventAddressController.text,
            'description': _eventDescriptionController.text,
            'link': 'https://maps.app.goo.gl/CRDQgptPBHMxcqJZ9',
            'createdBy': user.uid,
            'user': userName,
            'profile': userProfile,
          });
          Fluttertoast.showToast(
            msg: 'Event uploaded: ${_eventDescriptionController.text}',
          );
          setState(() {
            _eventImagePath = null;
            _eventDescriptionController.clear();
            _eventAddressController.clear();
            _eventDate = null;
            _eventTime = null;
          });
        }
        break;
      case 2: // Reel Upload
        if (_reelPath == null) {
          Fluttertoast.showToast(msg: 'Please select a video.');
          setState(() {
            _isLoading = false;
          });
          return;
        }
        final videoUrl = await _uploadFile(File(_reelPath!), true);
        if (videoUrl != null) {
          await FirebaseFirestore.instance.collection('reels').add({
            'videoUrl': videoUrl,
            'thumbnail': 'https://picsum.photos/seed/reel/600/400',
            'user': userName,
            'profile': userProfile,
            'isFollowing': false,
            'createdBy': user.uid,
            'createdAt': DateTime.now().toIso8601String(),
          });
          Fluttertoast.showToast(
            msg: 'Reel uploaded',
          );
          setState(() {
            _reelPath = null;
          });
        }
        break;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildUploadForm(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final padding = screenWidth * 0.04;
    final fontScale = screenWidth / 400;

    switch (_selectedIndex) {
      case 0: // Image Upload
        return FadeInUp(
          child: Container(
            margin: EdgeInsets.all(padding),
            width: screenWidth * 0.92,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[200]!, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20 * fontScale),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10 * fontScale,
                  offset: Offset(0, 5 * fontScale),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(padding * 1.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload Image',
                    style: TextStyle(
                      fontSize: 24 * fontScale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(forEvent: false),
                    icon: Icon(Icons.image, size: 28 * fontScale),
                    label: Text(
                      _imagePath == null ? 'Select Image' : 'Image Selected',
                      style: TextStyle(
                        fontSize: 16 * fontScale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: padding * 1.5,
                        vertical: padding,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16 * fontScale),
                      ),
                      elevation: 8 * fontScale,
                      minimumSize: Size(screenWidth * 0.4, screenHeight * 0.06),
                    ),
                  ),
                  if (_imagePath != null) ...[
                    SizedBox(height: screenHeight * 0.015),
                    Text(
                      'Selected: ${_imagePath!.split('/').last}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14 * fontScale,
                      ),
                    ),
                  ],
                  SizedBox(height: screenHeight * 0.02),
                  TextField(
                    controller: _imageDescriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe your image...',
                      labelStyle: TextStyle(fontSize: 16 * fontScale),
                    ),
                    maxLines: 3,
                    style: TextStyle(fontSize: 16 * fontScale),
                  ),
                ],
              ),
            ),
          ),
        );
      case 1: // Event Upload
        return FadeInUp(
          child: Container(
            margin: EdgeInsets.all(padding),
            width: screenWidth * 0.92,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[200]!, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20 * fontScale),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10 * fontScale,
                  offset: Offset(0, 5 * fontScale),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(padding * 1.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload Event',
                    style: TextStyle(
                      fontSize: 24 * fontScale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(forEvent: true),
                    icon: Icon(Icons.image, size: 28 * fontScale),
                    label: Text(
                      _eventImagePath == null ? 'Select Image' : 'Image Selected',
                      style: TextStyle(
                        fontSize: 16 * fontScale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: padding * 1.5,
                        vertical: padding,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16 * fontScale),
                      ),
                      elevation: 8 * fontScale,
                      minimumSize: Size(screenWidth * 0.4, screenHeight * 0.06),
                    ),
                  ),
                  if (_eventImagePath != null) ...[
                    SizedBox(height: screenHeight * 0.015),
                    Text(
                      'Selected: ${_eventImagePath!.split('/').last}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14 * fontScale,
                      ),
                    ),
                  ],
                  SizedBox(height: screenHeight * 0.02),
                  TextField(
                    controller: _eventDescriptionController,
                    decoration: InputDecoration(
                      labelText: 'Event Description',
                      hintText: 'Describe your event...',
                      labelStyle: TextStyle(fontSize: 16 * fontScale),
                    ),
                    maxLines: 3,
                    style: TextStyle(fontSize: 16 * fontScale),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextField(
                    controller: _eventAddressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      hintText: 'Enter event location...',
                      labelStyle: TextStyle(fontSize: 16 * fontScale),
                    ),
                    style: TextStyle(fontSize: 16 * fontScale),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _pickDate(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: padding),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12 * fontScale),
                            ),
                          ),
                          child: Text(
                            _eventDate == null
                                ? 'Select Date'
                                : DateFormat.yMMMd().format(_eventDate!),
                            style: TextStyle(fontSize: 14 * fontScale),
                          ),
                        ),
                      ),
                      SizedBox(width: padding),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _pickTime(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: padding),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12 * fontScale),
                            ),
                          ),
                          child: Text(
                            _eventTime == null
                                ? 'Select Time'
                                : _eventTime!.format(context),
                            style: TextStyle(fontSize: 14 * fontScale),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      case 2: // Reel Upload
        return FadeInUp(
          child: Container(
            margin: EdgeInsets.all(padding),
            width: screenWidth * 0.92,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[200]!, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20 * fontScale),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10 * fontScale,
                  offset: Offset(0, 5 * fontScale),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(padding * 1.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload Reel',
                    style: TextStyle(
                      fontSize: 24 * fontScale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  ElevatedButton.icon(
                    onPressed: _pickVideo,
                    icon: Icon(Icons.video_library, size: 28 * fontScale),
                    label: Text(
                      _reelPath == null ? 'Select Video' : 'Video Selected',
                      style: TextStyle(
                        fontSize: 16 * fontScale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: padding * 1.5,
                        vertical: padding,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16 * fontScale),
                      ),
                      elevation: 8 * fontScale,
                      minimumSize: Size(screenWidth * 0.4, screenHeight * 0.06),
                    ),
                  ),
                  if (_reelPath != null) ...[
                    SizedBox(height: screenHeight * 0.015),
                    Text(
                      'Selected: ${_reelPath!.split('/').last}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14 * fontScale,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final padding = screenWidth * 0.04;
    final fontScale = screenWidth / 400;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Hub',
          style: TextStyle(
            fontSize: 24 * fontScale,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.grey],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                FadeInDown(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.025,
                      horizontal: padding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTabButton('Image', 0, fontScale, padding),
                        _buildTabButton('Event', 1, fontScale, padding),
                        _buildTabButton('Reel', 2, fontScale, padding),
                      ],
                    ),
                  ),
                ),
                // First Upload Ads container
                FadeInUp(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdPay()),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: padding,
                        vertical: padding * 0.5,
                      ),
                      padding: EdgeInsets.all(padding),
                      width: screenWidth * 0.92,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12 * fontScale),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 6 * fontScale,
                            offset: Offset(0, 3 * fontScale),
                          ),
                        ],
                      ),
                      child: Text(
                        'Advertise',
                        style: TextStyle(
                          fontSize: 16 * fontScale,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                _buildUploadForm(context),
                // Second Upload Ads container
                FadeInUp(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdPay()),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: padding,
                        vertical: padding * 0.5,
                      ),
                      padding: EdgeInsets.all(padding),
                      width: screenWidth * 0.92,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12 * fontScale),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 6 * fontScale,
                            offset: Offset(0, 3 * fontScale),
                          ),
                        ],
                      ),
                      child: Text(
                        'Advertise',
                        style: TextStyle(
                          fontSize: 16 * fontScale,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                // Ads Tutorial Button
                FadeInUp(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VideoPlayerPage(
                            videoUrl:
                                'https://firebasestorage.googleapis.com/v0/b/teacher-4e3b3.appspot.com/o/fabiok.mp4?alt=media&token=91eeca4d-7662-4c28-8b86-8a46a3eb97b6',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: padding,
                        vertical: padding * 0.5,
                      ),
                      padding: EdgeInsets.all(padding),
                      width: screenWidth * 0.92,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFD700)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12 * fontScale),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 8 * fontScale,
                            offset: Offset(0, 4 * fontScale),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 24 * fontScale,
                          ),
                          SizedBox(width: padding * 0.5),
                          Text(
                            'Ads Tutorial',
                            style: TextStyle(
                              fontSize: 16 * fontScale,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                FadeInUp(
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitUpload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: padding * 1.2,
                          horizontal: padding * 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16 * fontScale),
                        ),
                        elevation: 8 * fontScale,
                        minimumSize: Size(screenWidth * 0.5, screenHeight * 0.07),
                      ),
                      child: Text(
                        'Upload Now',
                        style: TextStyle(fontSize: 18 * fontScale),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
      String label, int index, double fontScale, double padding) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: padding * 1.5,
          vertical: padding * 0.8,
        ),
        decoration: BoxDecoration(
          color: _selectedIndex == index ? Colors.black : Colors.grey[200],
          borderRadius: BorderRadius.circular(30 * fontScale),
          boxShadow: [
            if (_selectedIndex == index)
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8 * fontScale,
                offset: Offset(0, 4 * fontScale),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _selectedIndex == index ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16 * fontScale,
          ),
        ),
      ),
    );
  }
}

// New Video Player Page
class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerPage({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: _isInitialized
              ? Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Center(
                      child: IconButton(
                        icon: Icon(
                          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 60,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                )
              : const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
        ),
      ),
    );
  }
}