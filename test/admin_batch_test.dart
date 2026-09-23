import 'package:flutter_test/flutter_test.dart';
import 'package:commission_apparel_flutter/models/user.dart';
import 'package:commission_apparel_flutter/services/admin_service.dart';
import 'package:commission_apparel_flutter/data/dummy_users.dart';
import 'package:commission_apparel_flutter/data/dummy_orders.dart';
import 'package:commission_apparel_flutter/models/parent_order.dart';

void main() {
  group('Admin Batch Management Tests', () {
    late User adminUser;

    setUp(() {
      adminUser = dummyUsers.firstWhere((u) => u.role == UserRole.admin);
    });

    test('Admin can mark direct batch as addressed', () {
      final batchId = 'direct-batch-test';
      final order = ParentOrder(
        id: 'do-123',
        batchId: batchId,
        userId: adminUser.id, // using admin just as owner
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

      final error = AdminService.markDirectBatchAddressed(adminUser, batchId);
      expect(error, isNull);

      final updatedOrder = dummyParentOrders.firstWhere((o) => o.id == 'do-123');
      expect(updatedOrder.status, 'Processing');
      expect(updatedOrder.isArchived, isTrue);

      dummyParentOrders.removeWhere((o) => o.id == 'do-123');
    });

    test('Admin can mark store batch as addressed', () {
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

      final error = AdminService.markStoreBatchAddressed(adminUser, batchId);
      expect(error, isNull);

      final updatedOrder = dummyParentOrders.firstWhere((o) => o.id == 'so-123');
      expect(updatedOrder.status, 'Processing');
      expect(updatedOrder.isArchived, isTrue);

      dummyParentOrders.removeWhere((o) => o.id == 'so-123');
    });

    test('Admin can delete archived batch', () {
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

      final error = AdminService.deleteArchivedOrderBatch(adminUser, batchId);
      expect(error, isNull);

      final exists = dummyParentOrders.any((o) => o.id == 'del-123');
      expect(exists, isFalse);
    });
  });
}
