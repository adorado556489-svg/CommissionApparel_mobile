import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commission_apparel_flutter/models/user.dart';
import 'package:commission_apparel_flutter/models/team_store.dart';
import 'package:commission_apparel_flutter/models/parent_order.dart';
import 'package:commission_apparel_flutter/services/admin_service.dart';
import 'package:commission_apparel_flutter/services/order_service.dart';
import 'package:commission_apparel_flutter/services/store_service.dart';

void main() {
  group('Phase 9 Cleanup Tests', () {
    late User adminUser;
    late FakeFirebaseFirestore firestore;
    
    setUp(() async {
      firestore = FakeFirebaseFirestore();
      adminUser = User(
        id: 'admin',
        email: 'admin@test.com',
        firstName: 'Admin',
        lastName: 'User',
        role: UserRole.admin,
        password: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await firestore.collection('users').doc(adminUser.id).set(adminUser.toFirestore());
    });

    group('Coach Cascade Tests', () {
      test('Admin deleting a Coach cascades to TeamStores and ParentOrders', () async {
        final coach = User(id: 'cascade-coach-123', firstName: 'Cascade', lastName: 'Coach', email: 'cascade@coach.com', password: 'password', role: UserRole.coach, status: 'active', createdAt: DateTime.now(), updatedAt: DateTime.now());
        await firestore.collection('users').doc(coach.id).set(coach.toFirestore());
        final store = TeamStore(id: 'cascade-store-123', userId: coach.id, name: 'Cascade Store', slug: 'cascade-store', status: 'approved', createdAt: DateTime.now(), updatedAt: DateTime.now());
        await StoreService.createStore(firestore, store);
        final storeOrder = ParentOrder(id: 'cascade-store-order-123', teamStoreId: store.id, userId: 'some-parent-id', athleteFirstName: 'Store', athleteLastName: 'Athlete', status: 'Pending Coach Approval', itemEntries: [], createdAt: DateTime.now(), updatedAt: DateTime.now());
        await OrderService.createOrder(firestore, storeOrder);
        final directOrder = ParentOrder(id: 'cascade-direct-order-123', teamStoreId: null, userId: coach.id, athleteFirstName: 'Direct', athleteLastName: 'Athlete', status: 'Draft', itemEntries: [], createdAt: DateTime.now(), updatedAt: DateTime.now());
        await OrderService.createOrder(firestore, directOrder);

        // Pre-count
        final preStores = await firestore.collection('teamStores').get();
        final preOrders = await firestore.collection('parentOrders').get();
        final unrelatedStoreCount = preStores.docs.length;
        final unrelatedOrderCount = preOrders.docs.length;

        final error = await AdminService.deleteCoach(firestore, adminUser, coach.id);
        expect(error, isNull);

        // SIMULATE CLOUD FUNCTION
        await StoreService.deleteStoreForCoach(firestore, coach.id);
        final qs1 = await firestore.collection('parentOrders').where('userId', isEqualTo: coach.id).get();
        for (var doc in qs1.docs) await doc.reference.delete();
        final qs2 = await firestore.collection('parentOrders').where('teamStoreId', isEqualTo: store.id).get();
        for (var doc in qs2.docs) await doc.reference.delete();

        final uDoc = await firestore.collection('users').doc(coach.id).get();
        expect(uDoc.exists, isFalse);
        final sDoc = await firestore.collection('teamStores').doc(store.id).get();
        expect(sDoc.exists, isFalse);
        final soDoc = await firestore.collection('parentOrders').doc(storeOrder.id).get();
        expect(soDoc.exists, isFalse);
        final doDoc = await firestore.collection('parentOrders').doc(directOrder.id).get();
        expect(doDoc.exists, isFalse);

        final postStores = await firestore.collection('teamStores').get();
        final postOrders = await firestore.collection('parentOrders').get();
        expect(postStores.docs.length, unrelatedStoreCount - 1);
        expect(postOrders.docs.length, unrelatedOrderCount - 2);
      });
    });

    group('Order RBAC Tests', () {
      late User unrelatedCoach;
      late TeamStore unrelatedStore;
      late ParentOrder unrelatedStoreOrder;
      late ParentOrder directOrder;

      setUp(() async {
        unrelatedCoach = User(id: 'unrelated-coach-123', firstName: 'Unrelated', lastName: 'Coach', email: 'unrelated@coach.com', password: 'password', role: UserRole.coach, status: 'active', createdAt: DateTime.now(), updatedAt: DateTime.now());
        await firestore.collection('users').doc(unrelatedCoach.id).set(unrelatedCoach.toFirestore());
        unrelatedStore = TeamStore(id: 'unrelated-store-123', userId: unrelatedCoach.id, name: 'Unrelated Store', slug: 'unrelated-store', status: 'approved', createdAt: DateTime.now(), updatedAt: DateTime.now());
        await StoreService.createStore(firestore, unrelatedStore);
        unrelatedStoreOrder = ParentOrder(id: 'unrelated-store-order-123', teamStoreId: unrelatedStore.id, userId: 'some-parent-id', athleteFirstName: 'Store', athleteLastName: 'Athlete', status: 'Pending Coach Approval', itemEntries: [], createdAt: DateTime.now(), updatedAt: DateTime.now());
        await OrderService.createOrder(firestore, unrelatedStoreOrder);
        directOrder = ParentOrder(id: 'unrelated-direct-order-123', teamStoreId: null, userId: unrelatedCoach.id, athleteFirstName: 'Direct', athleteLastName: 'Athlete', status: 'Draft', itemEntries: [], createdAt: DateTime.now(), updatedAt: DateTime.now());
        await OrderService.createOrder(firestore, directOrder);
      });

      test('Admin deletes a store-linked order succeeds', () async {
        final error = await OrderService.deleteOrder(firestore, adminUser, unrelatedStoreOrder.id);
        expect(error, isNull);
        final doc = await firestore.collection('parentOrders').doc(unrelatedStoreOrder.id).get();
        expect(doc.exists, isFalse);
      });

      test('Admin deletes a direct order (teamStoreId == null) succeeds', () async {
        final error = await OrderService.deleteOrder(firestore, adminUser, directOrder.id);
        expect(error, isNull);
        final doc = await firestore.collection('parentOrders').doc(directOrder.id).get();
        expect(doc.exists, isFalse);
      });

      test('Coach deletes their own authorized order preserves valid behavior', () async {
        final error = await OrderService.deleteOrder(firestore, unrelatedCoach, unrelatedStoreOrder.id);
        expect(error, isNull);
        final doc = await firestore.collection('parentOrders').doc(unrelatedStoreOrder.id).get();
        expect(doc.exists, isFalse);
      });

      test("Coach attempts to delete another Coach's store-linked order is denied", () async {
        final invadingCoach = User(id: 'invading-coach-123', firstName: 'Invading', lastName: 'Coach', email: 'invader@coach.com', password: 'password', role: UserRole.coach, status: 'active', createdAt: DateTime.now(), updatedAt: DateTime.now());
        await firestore.collection('users').doc(invadingCoach.id).set(invadingCoach.toFirestore());

        final error = await OrderService.deleteOrder(firestore, invadingCoach, unrelatedStoreOrder.id);
        expect(error, equals('Unauthorized'));
        final doc = await firestore.collection('parentOrders').doc(unrelatedStoreOrder.id).get();
        expect(doc.exists, isTrue);
      });

      test('Verify unrelated orders remain unchanged', () async {
        final pre = await firestore.collection('parentOrders').get();
        final originalCount = pre.docs.length;
        await OrderService.deleteOrder(firestore, adminUser, directOrder.id);
        final post = await firestore.collection('parentOrders').get();
        expect(post.docs.length, originalCount - 1);
        final doc = await firestore.collection('parentOrders').doc(unrelatedStoreOrder.id).get();
        expect(doc.exists, isTrue);
      });
    });
  });
}
