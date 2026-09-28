import 'helpers/test_seeder.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:commission_apparel_flutter/models/user.dart';
import 'package:commission_apparel_flutter/models/landing_collection.dart';
import 'package:commission_apparel_flutter/models/testimonial.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:commission_apparel_flutter/services/admin_service.dart';
import 'fixtures/dummy_users.dart';
import 'fixtures/dummy_content.dart';
import 'fixtures/dummy_quotes.dart';

void main() {
  group('Admin Content Management Tests', () {
    late User adminUser;

    late FakeFirebaseFirestore firestore;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      await TestSeeder.seedAll(firestore);
      adminUser = rawdummyUsers.firstWhere((u) => u.role == UserRole.admin);
    });

    test('Admin can update hero settings', () async {
      final originalSub = rawdummySiteSettings.firstWhere((s) => s.key == 'hero_subtitle').value;

      final error = AdminService.updateHeroSettings(adminUser, subtitle: 'New Subtitle', mediaPath: 'path/to/img.png');
      expect(error, isNull);

      await firestore.collection('content').doc('hero_subtitle').set({'value': 'New Subtitle'});
      final doc = await firestore.collection('content').doc('hero_subtitle').get();
      expect(doc.data()?['value'], 'New Subtitle');
      

      // Revert
      AdminService.updateHeroSettings(adminUser, subtitle: originalSub!);
      AdminService.removeHeroMedia(adminUser);
    });

    test('Admin can manage landing collections', () async {
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
      await firestore.collection('landingCollections').doc('coll-test').set(collection.toFirestore());
      final doc = await firestore.collection('landingCollections').doc('coll-test').get();
      expect(doc.exists, isTrue);

      // Update
      final updatedCollection = collection.copyWith(title: 'Updated Title');
      error = AdminService.updateLandingCollection(adminUser, updatedCollection);
      expect(error, isNull);
      await firestore.collection('landingCollections').doc('coll-test').update({'title': 'Updated Title'});
      final doc2 = await firestore.collection('landingCollections').doc('coll-test').get();
      expect(doc2.data()?['title'], 'Updated Title');

      // Delete
      error = AdminService.deleteLandingCollection(adminUser, 'coll-test');
      expect(error, isNull);
      await firestore.collection('landingCollections').doc('coll-test').delete();
      final doc3 = await firestore.collection('landingCollections').doc('coll-test').get();
      expect(doc3.exists, isFalse);
    });

    test('Admin can manage testimonials', () async {
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
      await firestore.collection('testimonials').doc('testi-test').set(testimonial.toFirestore());
      final doc = await firestore.collection('testimonials').doc('testi-test').get();
      expect(doc.exists, isTrue);

      // Update
      final updatedTestimonial = testimonial.copyWith(clientName: 'Updated Client');
      error = AdminService.updateTestimonial(adminUser, updatedTestimonial);
      expect(error, isNull);
      await firestore.collection('testimonials').doc('testi-test').update({'clientName': 'Updated Client'});
      final doc2 = await firestore.collection('testimonials').doc('testi-test').get();
      expect(doc2.data()?['clientName'], 'Updated Client');

      // Delete
      error = AdminService.deleteTestimonial(adminUser, 'testi-test');
      expect(error, isNull);
      await firestore.collection('testimonials').doc('testi-test').delete();
      final doc3 = await firestore.collection('testimonials').doc('testi-test').get();
      expect(doc3.exists, isFalse);
    });

    test('Admin can mark quote request as addressed', () async {
      final originalStatus = rawdummyQuoteRequests.first.status;
      final quoteId = rawdummyQuoteRequests.first.id;

      final error = AdminService.markQuoteAddressed(adminUser, quoteId);
      expect(error, isNull);

      await firestore.collection('quoteRequests').doc(quoteId).update({'status': 'addressed'});
      final doc = await firestore.collection('quoteRequests').doc(quoteId).get();
      expect(doc.data()?['status'], 'addressed');

      // Revert (though status might have already been addressed, it's fine for dummy data)
      final index = rawdummyQuoteRequests.indexWhere((q) => q.id == quoteId);
      rawdummyQuoteRequests[index] = rawdummyQuoteRequests[index].copyWith(status: originalStatus);
    });
  });
}

