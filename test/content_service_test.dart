import 'helpers/test_seeder.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:commission_apparel_flutter/services/content_service.dart';
import 'package:commission_apparel_flutter/models/site_setting.dart';
import 'package:commission_apparel_flutter/models/testimonial.dart';
import 'package:commission_apparel_flutter/models/quote_request.dart';
import 'package:commission_apparel_flutter/constants/firestore_paths.dart';

import 'fixtures/dummy_users.dart';
import 'fixtures/dummy_stores.dart';
import 'fixtures/dummy_orders.dart';
import 'fixtures/dummy_catalog.dart';
import 'fixtures/dummy_content.dart';
import 'fixtures/dummy_quotes.dart';

void main() {
  TestSeeder.populateDummyFallbacks();

  group('Phase 6 - Content Service Tests', () {
    late FakeFirebaseFirestore firestore;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      
    });

    test('getSiteSettings returns empty fallback if none exist', () async {
      final settings = await ContentService.getAllSiteSettings(firestore);
      expect(settings.isEmpty, true); // Returns dummy data fallback
    });

    test('updateSiteSetting saves to Firestore and getSiteSettings reads it', () async {
      final setting = SiteSetting(
        id: 'test-1',
        key: 'hero_title',
        value: 'Test Title',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ContentService.createSiteSetting(firestore, setting);

      final settings = await ContentService.getAllSiteSettings(firestore);
      final readSetting = settings.firstWhere((s) => s.key == 'hero_title');
      expect(readSetting.value, 'Test Title');
    });

    test('createTestimonial saves to Firestore', () async {
      final t = Testimonial(
        id: 't-1',
        clientName: 'John Doe',
        organization: 'Acme',
        content: 'Great stuff',
        sortOrder: 1,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ContentService.createTestimonial(firestore, t);

      final tests = await ContentService.getAllTestimonials(firestore);
      expect(tests.length, 1);
      expect(tests.first.clientName, 'John Doe');
    });

    test('createQuoteRequest saves to Firestore', () async {
      final q = QuoteRequest(
        id: 'q-1',
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane@example.com',
        organizationName: 'Org',
        apparelCategory: 'Soccer',
        estimatedQuantity: '10-50',
        packageType: 'bundle',
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ContentService.createQuoteRequest(firestore, q);

      final quotes = await firestore.collection('quote_requests').get();
      expect(quotes.docs.length, 1);
      expect(quotes.docs.first.data()['status'], 'pending');

      await ContentService.updateQuoteRequestStatus(firestore, 'q-1', 'addressed');
      
      final updatedQuotes = await firestore.collection('quote_requests').get();
      expect(updatedQuotes.docs.first.data()['status'], 'addressed');
    });
  });
}






