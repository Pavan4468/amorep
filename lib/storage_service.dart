import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class StorageService {
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'dfn63u46n',     // Your Cloudinary Cloud Name
    'PavanReddy',    // Your Upload Preset
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
