import 'helpers/test_seeder.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:commission_apparel_flutter/services/auth_service.dart';
import 'package:commission_apparel_flutter/services/order_service.dart';
import 'fixtures/dummy_orders.dart';

import 'package:commission_apparel_flutter/models/parent_order.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  AuthService createAuthFor(String email, String uid) {
    final mockUser = MockUser(uid: uid, email: email);
    final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    return AuthService(firestore: fakeFirestore, firebaseAuth: mockAuth);
  }

  group('Phase 8 - Coach Direct Orders', () {
    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      await TestSeeder.seedAll(fakeFirestore);
    });

    testWidgets('Draft direct order is saved correctly', (tester) async {
      final authService = createAuthFor('coach@example.com', 'user-coach-1');
      await authService.login('coach@example.com', 'password123');
      await tester.pumpAndSettle();
      while (authService.currentUser == null) await tester.pump(const Duration(milliseconds: 10));
      final coach = authService.currentUser!;

      final error = await OrderService.submitDirectOrder(fakeFirestore, 
        coach,
        orderType: 'person',
        athleteFirstName: 'Test',
        athleteLastName: 'Athlete',
        gender: 'Mens',
        items: [
          const OrderItemEntry(
            storeItemId: 'test-1',
            name: 'Test Item',
            types: ['Jersey'],
            sizes: {'Jersey': 'L'},
            quantity: 2,
          ),
        ],
      );

      expect(error, isNull);
      
      final querySnapshot = await fakeFirestore.collection('parentOrders').where('userId', isEqualTo: coach.id).where('athleteFirstName', isEqualTo: 'Test').get();
      expect(querySnapshot.docs.length, 1);
      final newOrderDoc = querySnapshot.docs.first;
      final newOrder = ParentOrder.fromFirestore(newOrderDoc);
      
      expect(newOrder.teamStoreId, isNull);
      expect(newOrder.userId, coach.id);
      expect(newOrder.athleteFirstName, 'Test');
      expect(newOrder.athleteLastName, 'Athlete');
      expect(newOrder.totalRetailPrice, 0.0);
      expect(newOrder.status, 'Draft');
      expect(newOrder.isDirectOrder, isTrue);
    });

    testWidgets('Finalizing direct orders batches them and updates status', (tester) async {
      final authService = createAuthFor('coach@example.com', 'user-coach-1');
      await authService.login('coach@example.com', 'password123');
      await tester.pumpAndSettle();
      while (authService.currentUser == null) await tester.pump(const Duration(milliseconds: 10));
      final coach = authService.currentUser!;

      var draftOrdersSnapshot = await fakeFirestore.collection('parentOrders')
          .where('userId', isEqualTo: coach.id)
          .where('status', isEqualTo: 'Draft')
          .get();
      var draftOrders = draftOrdersSnapshot.docs.map((d) => ParentOrder.fromFirestore(d)).where((o) => o.teamStoreId == null).toList();
      expect(draftOrders.length, greaterThanOrEqualTo(1));

      final error = await OrderService.finalizeDirectOrders(fakeFirestore, coach);
      expect(error, isNull);

      draftOrdersSnapshot = await fakeFirestore.collection('parentOrders')
          .where('userId', isEqualTo: coach.id)
          .where('status', isEqualTo: 'Draft')
          .get();
      draftOrders = draftOrdersSnapshot.docs.map((d) => ParentOrder.fromFirestore(d)).where((o) => o.teamStoreId == null).toList();
      expect(draftOrders.isEmpty, isTrue);

      final batchedOrderDoc = await fakeFirestore.collection('parentOrders').doc('order-6').get();
      final batchedOrder = ParentOrder.fromFirestore(batchedOrderDoc);
      expect(batchedOrder.status, 'Submitted to Admin');
      expect(batchedOrder.batchId, isNotNull);
    });

    testWidgets('Archiving a batch marks it as archived', (tester) async {
      final authService = createAuthFor('coach@example.com', 'user-coach-1');
      await authService.login('coach@example.com', 'password123');
      await tester.pumpAndSettle();
      while (authService.currentUser == null) await tester.pump(const Duration(milliseconds: 10));
      final coach = authService.currentUser!;

      final error = await OrderService.archiveDirectOrderBatch(fakeFirestore, coach, 'batch-direct-1');
      expect(error, isNull);

      final batchedOrderDoc = await fakeFirestore.collection('parentOrders').doc('order-7').get();
      final batchedOrder = ParentOrder.fromFirestore(batchedOrderDoc);
      expect(batchedOrder.isArchived, isTrue);
    });
  });
}
