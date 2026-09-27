import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commission_apparel_flutter/services/content_service.dart';
import 'package:commission_apparel_flutter/services/store_service.dart';
import 'package:commission_apparel_flutter/services/order_service.dart';
import 'helpers/test_seeder.dart';
import 'fixtures/dummy_users.dart';
import 'fixtures/dummy_stores.dart';
import 'fixtures/dummy_orders.dart';
import 'fixtures/dummy_catalog.dart';
import 'fixtures/dummy_content.dart';
import 'fixtures/dummy_quotes.dart';

void main() {
  TestSeeder.populateDummyFallbacks();

  group('Phase L - Realtime Listeners', () {
    late FakeFirebaseFirestore firestore;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      await TestSeeder.seedAdminEnvironment(firestore);
    await TestSeeder.seedAll(firestore);
    });

    test('getUserNotificationsStream emits updates when new notification is added', () async {
      await firestore.collection('notifications').doc('notif_1').set({
        'id': 'notif_1',
        'userId': 'user1',
        'title': 'Test',
        'message': 'Test',
        'isRead': false,
        'createdAt': Timestamp.now(),
        'type': 'system'
      });

      final stream2 = ContentService.getUserNotificationsStream(firestore, 'user1');
      final secondEmission = await stream2.first;
      expect(secondEmission.length, 1);
      expect(secondEmission.first.id, 'notif_1');
    });

    test('getPendingStoresStream emits updates for pending stores', () async {
      await firestore.collection('teamStores').doc('store_1').set({
        'id': 'store_1',
        'name': 'Store 1',
        'status': 'pending',
        'userId': 'coach_1',
        'slug': 'store-1',
        'isArchived': false,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      
      await firestore.collection('teamStores').doc('store_2').set({
        'id': 'store_2',
        'name': 'Store 2',
        'status': 'approved',
        'userId': 'coach_1',
        'slug': 'store-2',
        'isArchived': false,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      final stream = StoreService.getPendingStoresStream(firestore);
      final emission = await stream.first;
      expect(emission.where((e) => e.id == 'store_1').length, 1);
      
    });

    test('getUnbatchedOrdersForStoreStream emits unbatched orders for specific store', () async {
      await firestore.collection('parentOrders').doc('order_1').set({
        'id': 'order_1',
        'teamStoreId': 'store1',
        'userId': 'parent1',
        'batchId': null,
        'status': 'Submitted',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'itemEntries': [],
        'athleteFirstName': 'Test',
        'athleteLastName': 'Test',
        'gender': 'Mens',
        'totalRetailPrice': 0.0,
      });
      
      await firestore.collection('parentOrders').doc('order_2').set({
        'id': 'order_2',
        'teamStoreId': 'store1',
        'userId': 'parent1',
        'batchId': 'batch1',
        'status': 'Submitted to Admin',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'itemEntries': [],
        'athleteFirstName': 'Test',
        'athleteLastName': 'Test',
        'gender': 'Mens',
        'totalRetailPrice': 0.0,
      });
      
      await firestore.collection('parentOrders').doc('order_3').set({
        'id': 'order_3',
        'teamStoreId': 'store2',
        'userId': 'parent1',
        'batchId': null,
        'status': 'Submitted',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'itemEntries': [],
        'athleteFirstName': 'Test',
        'athleteLastName': 'Test',
        'gender': 'Mens',
        'totalRetailPrice': 0.0,
      });

      final stream = OrderService.getUnbatchedOrdersForStoreStream(firestore, 'store1');
      final emission = await stream.first;
      
      expect(emission.where((e) => e.id == 'order_1').length, 1);
    });
  });
}
