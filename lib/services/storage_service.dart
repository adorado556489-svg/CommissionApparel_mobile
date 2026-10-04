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
  final CloudinaryPublic _cloudinary;

  StorageService({ImagePicker? picker, CloudinaryPublic? cloudinary})
      : _picker = picker ?? ImagePicker(),
        _cloudinary = cloudinary ??
            CloudinaryPublic(
              AppConfig.cloudinaryCloudName,
              AppConfig.cloudinaryUploadPreset,
              cache: false,
            );

  /// Lets the user pick an image and uploads it.
  ///
  /// Returns `null` if the user cancels. Throws [ImageUploadException] on
  /// validation or network failure.
  Future<String?> pickAndUpload({required String folder}) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: AppConfig.imageMaxDimension.toDouble(),
      maxHeight: AppConfig.imageMaxDimension.toDouble(),
      imageQuality: AppConfig.imageQuality,
    );
    if (picked == null) return null;
    return uploadFile(folder, File(picked.path));
  }

  /// Uploads an already-selected [file] into [folder].
  Future<String> uploadFile(String folder, File file) async {
    final size = await file.length();
    if (size > AppConfig.maxImageBytes) {
      throw const ImageUploadException('Image is too large (max 10 MB).');
    }
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      debugPrint('StorageService upload error: $e');
      throw const ImageUploadException(
          'Upload failed. Check your connection and try again.');
    }
  }
}
