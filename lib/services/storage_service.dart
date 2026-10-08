import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../config/app_config.dart';

/// Thrown when an image cannot be picked or uploaded. [message] is safe to
/// show to end users.
class ImageUploadException implements Exception {
  final String message;
  const ImageUploadException(this.message);
  @override
  String toString() => message;
}

/// Single entry point for every image upload in the app.
///
/// * Picks from the gallery with platform-side downscaling/compression
///   (`maxWidth` / `imageQuality`) so large photos never hit the network.
/// * Validates size before upload.
/// * Uploads to Cloudinary into a logical [folder] and returns the HTTPS URL.
class StorageService {
  final ImagePicker _picker;

  StorageService({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  /// Lets the user pick an image from the gallery.
  /// Returns `null` if the user cancels.
  Future<File?> pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: AppConfig.imageMaxDimension.toDouble(),
      maxHeight: AppConfig.imageMaxDimension.toDouble(),
      imageQuality: AppConfig.imageQuality,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  /// Lets the user pick an image and uploads it.
  ///
  /// Returns `null` if the user cancels. Throws [ImageUploadException] on
  /// validation or network failure.
  Future<String?> pickAndUpload({required String folder}) async {
    final file = await pickImage();
    if (file == null) return null;
    return uploadFile(folder, file);
  }

  /// Uploads an already-selected [file] into [folder].
  Future<String> uploadFile(String folder, File file) async {
    final size = await file.length();
    if (size > AppConfig.maxImageBytes) {
      throw const ImageUploadException('Image is too large (max 10 MB).');
    }
    
    try {
      final cloudName = AppConfig.cloudinaryCloudName;
      final preset = AppConfig.cloudinaryUploadPreset;
      
      final cloudinary = CloudinaryPublic(
        cloudName,
        preset,
        cache: false,
      );
      
      // We add a strict 15-second timeout. If the emulator network is 
      // misconfigured or extremely slow, this prevents an infinite UI hang 
      // (where the spinner just spins forever).
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw const ImageUploadException('Upload timed out. Check your internet connection.'),
      );
      
      return response.secureUrl;
    } on ImageUploadException {
      rethrow;
    } catch (e) {
      debugPrint('StorageService upload error: $e');
      throw const ImageUploadException(
          'Upload failed. Check your connection and try again.');
    }
  }
}
