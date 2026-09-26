import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:commission_apparel_flutter/models/user.dart';
import 'package:commission_apparel_flutter/services/admin_service.dart';
import 'package:commission_apparel_flutter/data/dummy_users.dart';
import 'package:commission_apparel_flutter/data/dummy_orders.dart';
import 'package:commission_apparel_flutter/models/parent_order.dart';

void main() {
  group('Admin Batch Management Tests', () {
    late User adminUser;
    late FakeFirebaseFirestore firestore;

    setUp(() {
      adminUser = dummyUsers.firstWhere((u) => u.role == UserRole.admin);
      firestore = FakeFirebaseFirestore();
    });

    test('Admin can mark direct batch as addressed', () async {
      final batchId = 'direct-batch-test';
      final order = ParentOrder(
        id: 'do-123',
        batchId: batchId,
        userId: adminUser.id,
        athleteFirstName: 'Test',
        athleteLastName: 'Direct',
        status: 'Submitted to Admin',
        isArchived: false,
        totalRetailPrice: 100,
        itemEntries: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      dummyParentOrders.add(order);
      await firestore.collection('parentOrders').doc(order.id).set(order.toFirestore());

      final error = await AdminService.markDirectBatchAddressed(firestore, adminUser, batchId);
      expect(error, isNull);

      final updatedOrder = dummyParentOrders.firstWhere((o) => o.id == 'do-123');
      expect(updatedOrder.status, 'Processing');
      expect(updatedOrder.isArchived, isTrue);
      
      final doc = await firestore.collection('parentOrders').doc('do-123').get();
      expect(doc.data()?['status'], 'Processing');
      expect(doc.data()?['isArchived'], isTrue);

      dummyParentOrders.removeWhere((o) => o.id == 'do-123');
    });

    test('Admin can mark store batch as addressed', () async {
      final batchId = 'store-batch-test';
      final order = ParentOrder(
        id: 'so-123',
        teamStoreId: 'store-1',
        batchId: batchId,
        userId: adminUser.id,
        athleteFirstName: 'Test',
        athleteLastName: 'Store',
        status: 'Submitted to Admin',
        isArchived: false,
        totalRetailPrice: 100,
        itemEntries: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      dummyParentOrders.add(order);
      await firestore.collection('parentOrders').doc(order.id).set(order.toFirestore());

      final error = await AdminService.markStoreBatchAddressed(firestore, adminUser, batchId);
      expect(error, isNull);

      final updatedOrder = dummyParentOrders.firstWhere((o) => o.id == 'so-123');
      expect(updatedOrder.status, 'Processing');
      expect(updatedOrder.isArchived, isTrue);

      dummyParentOrders.removeWhere((o) => o.id == 'so-123');
    });

    test('Admin can delete archived batch', () async {
      final batchId = 'delete-batch-test';
      final order = ParentOrder(
        id: 'del-123',
        batchId: batchId,
        userId: adminUser.id,
        athleteFirstName: 'Test',
        athleteLastName: 'Del',
        status: 'Processing',
        isArchived: true,
        totalRetailPrice: 100,
        itemEntries: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      dummyParentOrders.add(order);
      await firestore.collection('parentOrders').doc(order.id).set(order.toFirestore());

      final error = await AdminService.deleteArchivedOrderBatch(firestore, adminUser, batchId);
      expect(error, isNull);

      final exists = dummyParentOrders.any((o) => o.id == 'del-123');
      expect(exists, isFalse);
      
      final doc = await firestore.collection('parentOrders').doc('del-123').get();
      expect(doc.exists, isFalse);
    });
  });
}
