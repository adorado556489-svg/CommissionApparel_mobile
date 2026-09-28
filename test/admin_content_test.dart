import 'package:flutter_test/flutter_test.dart';
import 'package:commission_apparel_flutter/models/user.dart';
import 'package:commission_apparel_flutter/models/landing_collection.dart';
import 'package:commission_apparel_flutter/models/testimonial.dart';
import 'package:commission_apparel_flutter/services/admin_service.dart';
import 'fixtures/dummy_users.dart';
import 'fixtures/dummy_content.dart';
import 'fixtures/dummy_quotes.dart';

void main() {
  group('Admin Content Management Tests', () {
    late User adminUser;

    setUp(() {
      adminUser = dummyUsers.firstWhere((u) => u.role == UserRole.admin);
    });

    test('Admin can update hero settings', () {
      final originalSub = dummySiteSettings.firstWhere((s) => s.key == 'hero_subtitle').value;

      final error = AdminService.updateHeroSettings(adminUser, subtitle: 'New Subtitle', mediaPath: 'path/to/img.png');
      expect(error, isNull);

      expect(dummySiteSettings.firstWhere((s) => s.key == 'hero_subtitle').value, 'New Subtitle');
      expect(dummySiteSettings.firstWhere((s) => s.key == 'hero_media_path').value, 'path/to/img.png');

      // Revert
      AdminService.updateHeroSettings(adminUser, subtitle: originalSub!);
      AdminService.removeHeroMedia(adminUser);
    });

    test('Admin can manage landing collections', () {
      final collection = LandingCollection(
        id: 'coll-test',
        tabName: 'Test Tab',
        title: 'Test Title',
        description: 'Test Desc',
        sortOrder: 99,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create
      var error = AdminService.createLandingCollection(adminUser, collection);
      expect(error, isNull);
      expect(dummyLandingCollections.any((c) => c.id == 'coll-test'), isTrue);

      // Update
      final updatedCollection = collection.copyWith(title: 'Updated Title');
      error = AdminService.updateLandingCollection(adminUser, updatedCollection);
      expect(error, isNull);
      expect(dummyLandingCollections.firstWhere((c) => c.id == 'coll-test').title, 'Updated Title');

      // Delete
      error = AdminService.deleteLandingCollection(adminUser, 'coll-test');
      expect(error, isNull);
      expect(dummyLandingCollections.any((c) => c.id == 'coll-test'), isFalse);
    });

    test('Admin can manage testimonials', () {
      final testimonial = Testimonial(
        id: 'testi-test',
        clientName: 'Test Client',
        content: 'Test Content',
        sortOrder: 99,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create
      var error = AdminService.createTestimonial(adminUser, testimonial);
      expect(error, isNull);
      expect(dummyTestimonials.any((t) => t.id == 'testi-test'), isTrue);

      // Update
      final updatedTestimonial = testimonial.copyWith(clientName: 'Updated Client');
      error = AdminService.updateTestimonial(adminUser, updatedTestimonial);
      expect(error, isNull);
      expect(dummyTestimonials.firstWhere((t) => t.id == 'testi-test').clientName, 'Updated Client');

      // Delete
      error = AdminService.deleteTestimonial(adminUser, 'testi-test');
      expect(error, isNull);
      expect(dummyTestimonials.any((t) => t.id == 'testi-test'), isFalse);
    });

    test('Admin can mark quote request as addressed', () {
      final originalStatus = dummyQuoteRequests.first.status;
      final quoteId = dummyQuoteRequests.first.id;

      final error = AdminService.markQuoteAddressed(adminUser, quoteId);
      expect(error, isNull);

      expect(dummyQuoteRequests.firstWhere((q) => q.id == quoteId).status, 'addressed');

      // Revert (though status might have already been addressed, it's fine for dummy data)
      final index = dummyQuoteRequests.indexWhere((q) => q.id == quoteId);
      dummyQuoteRequests[index] = dummyQuoteRequests[index].copyWith(status: originalStatus);
    });
  });
}
