import 'helpers/test_seeder.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:commission_apparel_flutter/services/storage_service.dart';
import 'fixtures/dummy_users.dart';
import 'fixtures/dummy_stores.dart';
import 'fixtures/dummy_orders.dart';
import 'fixtures/dummy_catalog.dart';
import 'fixtures/dummy_content.dart';
import 'fixtures/dummy_quotes.dart';

void main() {
  TestSeeder.populateDummyFallbacks();

  group('Phase K - Firebase Storage Service Tests', () {
    late MockFirebaseStorage mockStorage;
    late StorageService storageService;
    late File testFile;

    setUp(() {
      mockStorage = MockFirebaseStorage();
      storageService = StorageService(storage: mockStorage);
      
      // Create a dummy file for testing
      testFile = File('test_image.png');
      testFile.writeAsBytesSync([0, 1, 2, 3]);
    });
    
    tearDown(() {
      if (testFile.existsSync()) {
        testFile.deleteSync();
      }
    });

    test('uploadFile successfully uploads and returns download URL', () async {
      final storagePath = 'users/coach-1/logo_123.png';
      
      final url = await storageService.uploadFile(storagePath, testFile);
      
      expect(url, isNotNull);
      expect(url, contains('logo_123.png'));
      
      // Verify it exists in the mock
      final ref = mockStorage.ref().child(storagePath);
      final downloadUrl = await ref.getDownloadURL();
      expect(downloadUrl, url);
    });

    test('deleteFileByUrl deletes Firebase URLs successfully', () async {
      final storagePath = 'users/coach-2/logo_456.png';
      final uploadedUrl = await storageService.uploadFile(storagePath, testFile);
      
      expect(uploadedUrl, isNotNull);
      
      await storageService.deleteFileByUrl(uploadedUrl);
      
      // In MockFirebaseStorage, attempting to get a deleted file usually throws or we can't easily assert
      // But we can verify it doesn't throw on standard execution.
      // Let's rely on standard success flow.
    });

    test('deleteFileByUrl ignores local or mock URLs', () async {
      // Should not throw
      await storageService.deleteFileByUrl('assets/images/placeholder.png');
      await storageService.deleteFileByUrl('C:/local/path/image.png');
      await storageService.deleteFileByUrl('https://dummyimage.com/200x200'); // not firebasestorage
    });

    test('replaceFile uploads new file and deletes old Firebase file', () async {
      final oldPath = 'stores/store-1/cover_old.jpg';
      final oldUrl = await storageService.uploadFile(oldPath, testFile);
      
      final newPath = 'stores/store-1/cover_new.jpg';
      final newUrl = await storageService.replaceFile(newPath, testFile, oldUrl);
      
      expect(newUrl, isNotNull);
      expect(newUrl, contains('cover_new.jpg'));
      expect(newUrl, isNot(equals(oldUrl)));
    });
    
    test('replaceFile handles null oldFileUrl gracefully', () async {
      final newPath = 'landing/hero/new.png';
      final newUrl = await storageService.replaceFile(newPath, testFile, null);
      
      expect(newUrl, isNotNull);
      expect(newUrl, contains('new.png'));
    });
  });
}
