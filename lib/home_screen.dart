import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'storage_service.dart';
import 'posts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();
  File? _selectedFile;
  String? _uploadedFileUrl;
  bool _isImage = true;

  final List<Map<String, String>> _uploadedPosts = [];

  Future<void> _pickMedia() async {
    final pickedFile = await (_isImage
        ? _picker.pickImage(source: ImageSource.gallery)
        : _picker.pickVideo(source: ImageSource.gallery));
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadMedia() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
      return;
    }

    final fileUrl = await _storageService.uploadFile(_selectedFile!);
    if (fileUrl != null) {
      setState(() {
        _uploadedFileUrl = fileUrl;
        _uploadedPosts.add({'url': fileUrl, 'type': _isImage ? 'image' : 'video'});
        _selectedFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Media uploaded successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload media')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Media')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _selectedFile != null
                  ? _isImage
                      ? Image.file(_selectedFile!, height: 200)
                      : const Text('Video selected (preview not supported)')
                  : const Text('No media selected'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => _isImage = true),
                    child: const Text('Pick Image'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => setState(() => _isImage = false),
                    child: const Text('Pick Video'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _pickMedia,
                child: const Text('Select Media'),
              ),
              if (_selectedFile != null)
                ElevatedButton(
                  onPressed: _uploadMedia,
                  child: const Text('Upload Media'),
                ),
              const SizedBox(height: 20),
              if (_uploadedFileUrl != null)
                Column(
                  children: [
                    const Text('Uploaded Media:'),
                    _isImage
                        ? Image.network(_uploadedFileUrl!, height: 200)
                        : Text('Video URL: $_uploadedFileUrl'),
                  ],
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PostsScreen(posts: _uploadedPosts),
                    ),
                  );
                },
                child: const Text('View Posts'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
