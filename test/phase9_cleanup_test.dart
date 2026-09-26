import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commission_apparel_flutter/models/user.dart';
import 'package:commission_apparel_flutter/models/team_store.dart';
import 'package:commission_apparel_flutter/models/parent_order.dart';
import 'package:commission_apparel_flutter/services/admin_service.dart';
import 'package:commission_apparel_flutter/services/order_service.dart';
import 'package:commission_apparel_flutter/data/dummy_users.dart';
import 'package:commission_apparel_flutter/data/dummy_stores.dart';
import 'package:commission_apparel_flutter/data/dummy_orders.dart';

void main() {
  group('Phase 9 Cleanup Tests', () {
    late User adminUser;
    
    setUp(() {
      adminUser = dummyUsers.firstWhere((u) => u.role == UserRole.admin);
    });

    group('Coach Cascade Tests', () {
      test('Admin deleting a Coach cascades to TeamStores and ParentOrders', () async {
        // 1. Create a dummy coach
        final coach = User(
          id: 'cascade-coach-123',
          firstName: 'Cascade',
          lastName: 'Coach',
          email: 'cascade@coach.com',
          password: 'password',
          role: UserRole.coach,
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        dummyUsers.add(coach);

        // 2. Create a dummy team store for the coach
        final store = TeamStore(
          id: 'cascade-store-123',
          userId: coach.id,
          name: 'Cascade Store',
          slug: 'cascade-store',
          status: 'approved',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        dummyTeamStores.add(store);

        // 3. Create a store-linked order for the store
        final storeOrder = ParentOrder(
          id: 'cascade-store-order-123',
          teamStoreId: store.id,
          userId: 'some-parent-id',
          athleteFirstName: 'Store',
          athleteLastName: 'Athlete',
          status: 'Pending Coach Approval',
          itemEntries: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        dummyParentOrders.add(storeOrder);

        // 4. Create a direct order for the coach
        final directOrder = ParentOrder(
          id: 'cascade-direct-order-123',
          teamStoreId: null,
          userId: coach.id,
          athleteFirstName: 'Direct',
          athleteLastName: 'Athlete',
          status: 'Draft',
          itemEntries: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        dummyParentOrders.add(directOrder);

        // Verify initial state
        expect(dummyUsers.any((u) => u.id == coach.id), isTrue);
        expect(dummyTeamStores.any((s) => s.id == store.id), isTrue);
        expect(dummyParentOrders.any((o) => o.id == storeOrder.id), isTrue);
        expect(dummyParentOrders.any((o) => o.id == directOrder.id), isTrue);

        // Capture unaffected records
        final unrelatedStoreCount = dummyTeamStores.length;
        final unrelatedOrderCount = dummyParentOrders.length;

        // Perform deletion
        final error = await AdminService.deleteCoach(FakeFirebaseFirestore(), adminUser, coach.id);
        expect(error, isNull);

        // Verify cascading deletes
        expect(dummyUsers.any((u) => u.id == coach.id), isFalse, reason: 'Coach should be removed');
        expect(dummyTeamStores.any((s) => s.id == store.id), isFalse, reason: 'Store should be cascaded');
        expect(dummyParentOrders.any((o) => o.id == storeOrder.id), isFalse, reason: 'Store order should be cascaded');
        expect(dummyParentOrders.any((o) => o.id == directOrder.id), isFalse, reason: 'Direct order should be cascaded');

        // Verify unrelated records remain
        expect(dummyTeamStores.length, unrelatedStoreCount - 1);
        expect(dummyParentOrders.length, unrelatedOrderCount - 2);
      });
    });

    group('Order RBAC Tests', () {
      late User unrelatedCoach;
      late TeamStore unrelatedStore;
      late ParentOrder unrelatedStoreOrder;
      late ParentOrder directOrder;

      setUp(() {
        unrelatedCoach = User(
          id: 'unrelated-coach-123',
          firstName: 'Unrelated',
          lastName: 'Coach',
          email: 'unrelated@coach.com',
          password: 'password',
          role: UserRole.coach,
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        dummyUsers.add(unrelatedCoach);

        unrelatedStore = TeamStore(
          id: 'unrelated-store-123',
          userId: unrelatedCoach.id,
          name: 'Unrelated Store',
          slug: 'unrelated-store',
          status: 'approved',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        dummyTeamStores.add(unrelatedStore);

        unrelatedStoreOrder = ParentOrder(
          id: 'unrelated-store-order-123',
          teamStoreId: unrelatedStore.id,
          userId: 'some-parent-id',
          athleteFirstName: 'Store',
          athleteLastName: 'Athlete',
          status: 'Pending Coach Approval',
          itemEntries: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        dummyParentOrders.add(unrelatedStoreOrder);

        directOrder = ParentOrder(
          id: 'unrelated-direct-order-123',
          teamStoreId: null,
          userId: unrelatedCoach.id,
          athleteFirstName: 'Direct',
          athleteLastName: 'Athlete',
          status: 'Draft',
          itemEntries: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        dummyParentOrders.add(directOrder);
      });

      tearDown(() {
        dummyUsers.removeWhere((u) => u.id == unrelatedCoach.id);
        dummyTeamStores.removeWhere((s) => s.id == unrelatedStore.id);
        dummyParentOrders.removeWhere((o) => o.id == unrelatedStoreOrder.id || o.id == directOrder.id);
      });

      test('Admin deletes a store-linked order succeeds', () async {
        final error = await OrderService.deleteOrder(FakeFirebaseFirestore(), adminUser, unrelatedStoreOrder.id);
        expect(error, isNull);
        expect(dummyParentOrders.any((o) => o.id == unrelatedStoreOrder.id), isFalse);
        
        // Let tearDown handle it missing by omitting it or recreating it... wait, tearDown removes matching IDs, so missing is fine.
      });

      test('Admin deletes a direct order (teamStoreId == null) succeeds', () async {
        final error = await OrderService.deleteOrder(FakeFirebaseFirestore(), adminUser, directOrder.id);
        expect(error, isNull);
        expect(dummyParentOrders.any((o) => o.id == directOrder.id), isFalse);
      });

      test('Coach deletes their own authorized order preserves valid behavior', () async {
        final error = await OrderService.deleteOrder(FakeFirebaseFirestore(), unrelatedCoach, unrelatedStoreOrder.id);
        expect(error, isNull);
        expect(dummyParentOrders.any((o) => o.id == unrelatedStoreOrder.id), isFalse);
      });

      test("Coach attempts to delete another Coach's store-linked order is denied", () async {
        // Create an invading coach
        final invadingCoach = User(
          id: 'invading-coach-123',
          firstName: 'Invading',
          lastName: 'Coach',
          email: 'invader@coach.com',
          password: 'password',
          role: UserRole.coach,
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        dummyUsers.add(invadingCoach);

        final error = await OrderService.deleteOrder(FakeFirebaseFirestore(), invadingCoach, unrelatedStoreOrder.id);
        expect(error, equals('Unauthorized'));
        expect(dummyParentOrders.any((o) => o.id == unrelatedStoreOrder.id), isTrue);

        dummyUsers.removeWhere((u) => u.id == invadingCoach.id);
      });

      test('Verify unrelated orders remain unchanged', () async {
        // Admin deletes unrelated direct order
        final originalCount = dummyParentOrders.length;
        await OrderService.deleteOrder(FakeFirebaseFirestore(), adminUser, directOrder.id);
        expect(dummyParentOrders.length, originalCount - 1);
        expect(dummyParentOrders.any((o) => o.id == unrelatedStoreOrder.id), isTrue); // unrelated store order remains
      });
    });
  });
}




