import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class StorageService {
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'dfn63u46n', // Replace with your Cloudinary Cloud Name
    'PavanReddy', // Replace with your Upload Preset
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

class PromoteDetailsPage extends StatefulWidget {
  const PromoteDetailsPage({Key? key}) : super(key: key);

  @override
  _PromoteDetailsPageState createState() => _PromoteDetailsPageState();
}

class _PromoteDetailsPageState extends State<PromoteDetailsPage> {
  final TextEditingController adTitleController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController targetLocationController = TextEditingController();
  final TextEditingController adDescriptionController = TextEditingController();
  final StorageService _storageService = StorageService();
  File? _selectedFile;
  bool isLoading = false;
  bool isPaid = false;
  String? _fileName;

  // Validate inputs before proceeding
  bool _validateInputs() {
    return adTitleController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        contactNumberController.text.trim().isNotEmpty &&
        targetLocationController.text.trim().isNotEmpty &&
        adDescriptionController.text.trim().isNotEmpty &&
        _selectedFile != null;
  }

  // Pick image or video
  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.amber),
              title: const Text('Pick Image'),
              onTap: () async {
                final file = await picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(context, file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.amber),
              title: const Text('Pick Video'),
              onTap: () async {
                final file = await picker.pickVideo(source: ImageSource.gallery);
                Navigator.pop(context, file);
              },
            ),
          ],
        ),
      ),
    );

    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
        _fileName = pickedFile.name;
      });
    }
  }

  // Handle payment and save to Firestore
  Future<void> _handlePayment() async {
    if (!_validateInputs()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select an image or video.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Upload file to Cloudinary
      final fileUrl = await _storageService.uploadFile(_selectedFile!);
      if (fileUrl == null) {
        throw 'Failed to upload file';
      }

      // Save details to Firestore 'ads_payment' collection
      await FirebaseFirestore.instance.collection('ads_payment').add({
        'adTitle': adTitleController.text.trim(),
        'userEmail': emailController.text.trim(),
        'contactNumber': contactNumberController.text.trim(),
        'targetLocation': targetLocationController.text.trim(),
        'adDescription': adDescriptionController.text.trim(),
        'mediaUrl': fileUrl,
        'mediaType': _selectedFile!.path.endsWith('.mp4') ? 'video' : 'image',
        'paymentLink': 'https://buy.stripe.com/cN28yEcZIghn4Zq6op',
        'paymentStatus': true,
        'timestamp': FieldValue.serverTimestamp(),
        'createdBy': FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
        'isAdvertised': false,
        'likes': 0,
        'commentsCount': 0,
        'comments': [],
      });

      // Open Stripe payment link
      final Uri paymentUri = Uri.parse('https://buy.stripe.com/cN28yEcZIghn4Zq6op');
      if (await canLaunchUrl(paymentUri)) {
        await launchUrl(
          paymentUri,
          mode: LaunchMode.externalApplication,
        );
        setState(() {
          isPaid = true;
        });
      } else {
        throw 'Could not launch payment URL';
      }

      // Clear inputs
      adTitleController.clear();
      emailController.clear();
      contactNumberController.clear();
      targetLocationController.clear();
      adDescriptionController.clear();
      setState(() {
        _selectedFile = null;
        _fileName = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Submit details and navigate to home screen
  Future<void> _submitDetails() async {
    if (!_validateInputs()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select an image or video.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!isPaid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete payment before submitting.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Upload file to Cloudinary (in case user changed the file after payment)
      final fileUrl = await _storageService.uploadFile(_selectedFile!);
      if (fileUrl == null) {
        throw 'Failed to upload file';
      }

      // Save details to Firestore 'ads_payment' collection
      await FirebaseFirestore.instance.collection('ads_payment').add({
        'adTitle': adTitleController.text.trim(),
        'userEmail': emailController.text.trim(),
        'contactNumber': contactNumberController.text.trim(),
        'targetLocation': targetLocationController.text.trim(),
        'adDescription': adDescriptionController.text.trim(),
        'mediaUrl': fileUrl,
        'mediaType': _selectedFile!.path.endsWith('.mp4') ? 'video' : 'image',
        'paymentLink': 'https://buy.stripe.com/cN28yEcZIghn4Zq6op',
        'paymentStatus': true,
        'timestamp': FieldValue.serverTimestamp(),
        'createdBy': FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
        'isAdvertised': false,
        'likes': 0,
        'commentsCount': 0,
        'comments': [],
      });

      // Clear inputs and reset payment status
      adTitleController.clear();
      emailController.clear();
      contactNumberController.clear();
      targetLocationController.clear();
      adDescriptionController.clear();
      setState(() {
        _selectedFile = null;
        _fileName = null;
        isPaid = false;
      });

      // Navigate to home screen
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    adTitleController.dispose();
    emailController.dispose();
    contactNumberController.dispose();
    targetLocationController.dispose();
    adDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promote Your Post'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Promote Your Ad',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cost: €5',
              style: TextStyle(
                fontSize: 18,
                color: Colors.amber,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: adTitleController,
              decoration: InputDecoration(
                labelText: 'Ad Title',
                hintText: 'Enter a catchy title for your ad',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[800],
                labelStyle: const TextStyle(color: Colors.white70),
                hintStyle: const TextStyle(color: Colors.white54),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.amber),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[800],
                labelStyle: const TextStyle(color: Colors.white70),
                hintStyle: const TextStyle(color: Colors.white54),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.amber),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contactNumberController,
              decoration: InputDecoration(
                labelText: 'Contact Number',
                hintText: 'Enter your contact number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[800],
                labelStyle: const TextStyle(color: Colors.white70),
                hintStyle: const TextStyle(color: Colors.white54),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.amber),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: targetLocationController,
              decoration: InputDecoration(
                labelText: 'Target Location',
                hintText: 'Which location are users looking for?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[800],
                labelStyle: const TextStyle(color: Colors.white70),
                hintStyle: const TextStyle(color: Colors.white54),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.amber),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: adDescriptionController,
              decoration: InputDecoration(
                labelText: 'Ad Description',
                hintText: 'Describe your advertisement',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[800],
                labelStyle: const TextStyle(color: Colors.white70),
                hintStyle: const TextStyle(color: Colors.white54),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.amber),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.upload_file, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _fileName ?? 'Pick Image or Video',
                        style: TextStyle(
                          color: _fileName != null ? Colors.white : Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedFile != null && !_selectedFile!.path.endsWith('.mp4'))
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedFile!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (_selectedFile != null && _selectedFile!.path.endsWith('.mp4'))
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'Video selected (preview not available)',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: isLoading ? null : _handlePayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text(
                                'Payment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      if (isPaid)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 20),
                              SizedBox(width: 4),
                              Text(
                                'Paid Amount',
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}