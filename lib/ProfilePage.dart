import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class StorageService {
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'dfn63u46n', // Replace with your Cloudinary Cloud Name
    'PavanReddy', // Replace with your Cloudinary Upload Preset
    cache: false,
  );

  Future<String?> uploadFile(File file) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: file.path.endsWith('.mp4')
              ? CloudinaryResourceType.Video
              : CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // Upload image to Cloudinary
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final imageUrl = await _storageService.uploadFile(_image!);
          if (imageUrl != null) {
            // Update Firestore with image URL
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({
              'profileImageUrl': imageUrl,
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Failed to upload image to Cloudinary'),
                backgroundColor: Colors.grey[900],
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to upload image'),
            backgroundColor: Colors.grey[900],
          ),
        );
      }
    }
  }

  Future<void> _editProfile(Map<String, dynamic> currentData) async {
    await showDialog(
      context: context,
      builder: (context) {
        return EditProfileDialog(
          name: currentData['name'] ?? '',
          location: currentData['location'] ?? '',
          username: currentData['username'] ?? '',
          work: currentData['work'] ?? '',
          relationshipStatus: currentData['relationshipStatus'] ?? '',
          onSave: (updatedDetails) async {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .update(updatedDetails);
            }
          },
        );
      },
    );
  }

  void _editDetail(String title, String currentValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(hintText: 'Enter new $title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a value';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({
                      title.toLowerCase(): controller.text,
                    });
                  }
                  onSave(controller.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<int> _getPostCount(String userId) async {
    final postsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('createdBy', isEqualTo: userId)
        .get();
    final eventsSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('createdBy', isEqualTo: userId)
        .get();
    final reelsSnapshot = await FirebaseFirestore.instance
        .collection('reels')
        .where('createdBy', isEqualTo: userId)
        .get();

    return postsSnapshot.docs.length +
        eventsSnapshot.docs.length +
        reelsSnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in')),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Profile data not found')),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final interests = List<String>.from(data['interests'] ?? []);

        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Image
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _image != null
                        ? FileImage(_image!) as ImageProvider
                        : (data['profileImageUrl'] != null &&
                                data['profileImageUrl'].isNotEmpty
                            ? NetworkImage(data['profileImageUrl'])
                            : const NetworkImage(
                                'https://plus.unsplash.com/premium_photo-1689568126014-06fea9d5d341?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D',
                              )) as ImageProvider,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 30, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _editDetail('Name', data['name'] ?? '',
                      (value) => setState(() {})),
                  child: Text(
                    data['name'] ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _editDetail('Location', data['location'] ?? '',
                      (value) => setState(() {})),
                  child: Text(
                    data['location'] ?? 'No Location',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                FutureBuilder<int>(
                  future: _getPostCount(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text(
                        'Posts: 0',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Text(
                        'Posts: Error',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      );
                    }
                    return Text(
                      'Posts: ${snapshot.data ?? 0}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _editProfile(data),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Edit Profile'),
                ),
                const SizedBox(height: 30),
                // Details Section
                _buildEditableDetailTile(Icons.person, 'Username',
                    data['username'] ?? '', (value) => setState(() {})),
                _buildEditableDetailTile(
                    Icons.work, 'Work', data['work'] ?? '', (value) => setState(() {})),
                _buildEditableDetailTile(
                    Icons.favorite,
                    'Relationship Status',
                    data['relationshipStatus'] ?? '',
                    (value) => setState(() {})),
                const SizedBox(height: 30),
                // Interests Section
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Interests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: interests
                      .map((interest) => _buildInterestChip(interest))
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditableDetailTile(
      IconData icon, String title, String value, Function(String) onSave) {
    return GestureDetector(
      onTap: () => _editDetail(title, value, onSave),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.black,
        ),
        title: Text(
          value.isEmpty ? 'Not Set' : value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
      ),
    );
  }

  Widget _buildInterestChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.grey[300],
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }
}

class EditProfileDialog extends StatefulWidget {
  final String name;
  final String location;
  final String username;
  final String work;
  final String relationshipStatus;
  final Function(Map<String, String>) onSave;

  const EditProfileDialog({
    Key? key,
    required this.name,
    required this.location,
    required this.username,
    required this.work,
    required this.relationshipStatus,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _usernameController;
  late TextEditingController _workController;
  late TextEditingController _relationshipStatusController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _locationController = TextEditingController(text: widget.location);
    _usernameController = TextEditingController(text: widget.username);
    _workController = TextEditingController(text: widget.work);
    _relationshipStatusController =
        TextEditingController(text: widget.relationshipStatus);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _usernameController.dispose();
    _workController.dispose();
    _relationshipStatusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('Name', _nameController),
              _buildTextField('Location', _locationController),
              _buildTextField('Username', _usernameController),
              _buildTextField('Work', _workController),
              _buildTextField('Relationship Status', _relationshipStatusController),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave({
                'name': _nameController.text,
                'location': _locationController.text,
                'username': _usernameController.text,
                'work': _workController.text,
                'relationshipStatus': _relationshipStatusController.text,
              });
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}