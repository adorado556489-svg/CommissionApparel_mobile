import 'dummy_fallbacks.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage}) : _storage = storage ?? FirebaseStorage.instance;

  /// Uploads a file to Firebase Storage at [storagePath] and returns the download URL.
  /// Returns null if the upload fails.
  Future<String?> uploadFile(String storagePath, File file) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('StorageService upload error: $e');
      return null; // Return null instead of silently converting to dummy data
    }
  }

  /// Deletes a file from Firebase Storage using its [downloadUrl].
  /// Ignores non-Firebase URLs (like local paths or mock image URLs).
  Future<void> deleteFileByUrl(String? downloadUrl) async {
    if (downloadUrl == null) return;
    
    // Safety check: Only attempt to delete actual Firebase Storage URLs
    if (!downloadUrl.startsWith('http') && !downloadUrl.startsWith('gs://')) {
      return;
    }
    if (!downloadUrl.contains('firebasestorage.googleapis.com')) {
      return;
    }

    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      print('StorageService delete error: $e');
    }
  }

  /// Convenience method to upload a new file and delete the old one only on success.
  Future<String?> replaceFile(String storagePath, File newFile, String? oldFileUrl) async {
    final newUrl = await uploadFile(storagePath, newFile);
    
    // Only delete the old file if the upload succeeded and it's a different file
    if (newUrl != null && oldFileUrl != null && oldFileUrl != newUrl) {
      await deleteFileByUrl(oldFileUrl);
    }
    
    return newUrl;
  }
}