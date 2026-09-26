
import 'package:flutter_test/flutter_test.dart';
import 'helpers/auto_seeding_mock_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:commission_apparel_flutter/services/auth_service.dart';
import 'package:commission_apparel_flutter/services/order_service.dart';
import 'package:commission_apparel_flutter/data/dummy_orders.dart';

import 'package:commission_apparel_flutter/models/parent_order.dart';

void main() {
  group('Phase 8 - Coach Direct Orders', () {
    late AuthService authService;
    late int originalOrderCount;

    setUp(() {
      authService = AuthService(firestore: FakeFirebaseFirestore(), firebaseAuth: AutoSeedingMockFirebaseAuth());
      originalOrderCount = dummyParentOrders.length;
    });

    tearDown(() {
      dummyParentOrders.removeWhere((o) => dummyParentOrders.indexOf(o) >= originalOrderCount);
      // Clean up direct modifications on existing orders
      for (var o in dummyParentOrders) {
        if (o.id == 'order-6') dummyParentOrders[dummyParentOrders.indexOf(o)] = o.copyWith(status: 'Draft');
      }
    });

    testWidgets('Draft direct order is saved correctly', (tester) async {
      await authService.login('coach@example.com', 'password123');
      final coach = authService.currentUser!;

      final error = await OrderService.submitDirectOrder(FakeFirebaseFirestore(), 
        currentUser: coach,
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
      expect(dummyParentOrders.length, originalOrderCount + 1);
      final newOrder = dummyParentOrders.last;
      
      expect(newOrder.teamStoreId, isNull);
      expect(newOrder.userId, coach.id);
      expect(newOrder.athleteFirstName, 'Test');
      expect(newOrder.athleteLastName, 'Athlete');
      expect(newOrder.totalRetailPrice, 0.0);
      expect(newOrder.status, 'Draft');
      expect(newOrder.isDirectOrder, isTrue);
    });

    testWidgets('Finalizing direct orders batches them and updates status', (tester) async {
      await authService.login('coach@example.com', 'password123');
      final coach = authService.currentUser!;

      // Initial state has order-6 as 'Draft'
      var draftOrders = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == coach.id && o.status == 'Draft').toList();
      expect(draftOrders.length, greaterThanOrEqualTo(1));

      final error = await OrderService.finalizeDirectOrders(FakeFirebaseFirestore(), coach);
      expect(error, isNull);

      draftOrders = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == coach.id && o.status == 'Draft').toList();
      expect(draftOrders.isEmpty, isTrue);

      final batchedOrder = dummyParentOrders.firstWhere((o) => o.id == 'order-6');
      expect(batchedOrder.status, 'Submitted to Admin');
      expect(batchedOrder.batchId, isNotNull);
    });

    testWidgets('Archiving a batch marks it as archived', (tester) async {
      await authService.login('coach@example.com', 'password123');
      final coach = authService.currentUser!;

      final error = await OrderService.archiveDirectOrderBatch(FakeFirebaseFirestore(), coach, 'batch-direct-1');
      expect(error, isNull);

      final batchedOrder = dummyParentOrders.firstWhere((o) => o.id == 'order-7');
      expect(batchedOrder.isArchived, isTrue);

      // Revert in teardown explicitly
      dummyParentOrders[dummyParentOrders.indexWhere((o) => o.id == 'order-7')] = batchedOrder.copyWith(isArchived: false);
    });
  });
}


