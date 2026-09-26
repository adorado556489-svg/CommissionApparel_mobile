import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commission_apparel_flutter/models/parent_order.dart';
import 'package:commission_apparel_flutter/models/user.dart';
import 'package:commission_apparel_flutter/services/order_service.dart';

// Throwing fake wrapper
class ThrowingMockFirestore extends FakeFirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    if (collectionPath == 'parentOrders') {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'Simulated permission denied error',
      );
    }
    return super.collection(collectionPath);
  }
}

void main() {
  group('OrderService Tests', () {
    late FakeFirebaseFirestore firestore;
    final adminUser = User(id: 'admin1', email: 'admin@example.com', password: 'password', firstName: 'A', lastName: 'A', role: UserRole.admin, status: 'active', createdAt: DateTime.now(), updatedAt: DateTime.now(), assignedDesignIds: []);
    final coachUser = User(id: 'coach1', email: 'coach@example.com', password: 'password', firstName: 'C', lastName: 'C', role: UserRole.coach, status: 'active', createdAt: DateTime.now(), updatedAt: DateTime.now(), assignedDesignIds: []);
    final coachUser2 = User(id: 'coach2', email: 'coach2@example.com', password: 'password', firstName: 'C', lastName: 'C', role: UserRole.coach, status: 'active', createdAt: DateTime.now(), updatedAt: DateTime.now(), assignedDesignIds: []);

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    test('expected empty collection falls back gracefully', () async {
      final orders = await OrderService.getAllOrders(firestore);
      expect(orders.isNotEmpty, isTrue);
    });

    test('actual Firestore error propagates and throws', () async {
      final throwingFirestore = ThrowingMockFirestore();
      
      expect(
        () async => await OrderService.getAllOrders(throwingFirestore),
        throwsA(isA<FirebaseException>()),
      );
    });

    test('successful read overrides dummy data when firestore populated', () async {
      final testOrder = ParentOrder(
        id: 'fs-order-1',
        athleteFirstName: 'Test',
        athleteLastName: 'Firestore',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await firestore.collection('parentOrders').doc('fs-order-1').set(testOrder.toFirestore());

      final orders = await OrderService.getAllOrders(firestore);
      expect(orders.any((o) => o.id == 'fs-order-1'), isTrue);
      expect(orders.any((o) => o.id == 'order-1'), isFalse);
    });

    test('successful create order', () async {
      final order = ParentOrder(
        id: 'new-order',
        athleteFirstName: 'New',
        athleteLastName: 'Order',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await OrderService.createOrder(firestore, order);
      final doc = await firestore.collection('parentOrders').doc('new-order').get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['athleteFirstName'], 'New');
    });

    test('successful update order', () async {
      final order = ParentOrder(
        id: 'upd-order',
        userId: coachUser.id,
        athleteFirstName: 'Old',
        athleteLastName: 'Order',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await firestore.collection('parentOrders').doc('upd-order').set(order.toFirestore());

      final newOrder = order.copyWith(athleteFirstName: 'Updated');
      await OrderService.updateOrder(firestore, coachUser, newOrder);
      
      final doc = await firestore.collection('parentOrders').doc('upd-order').get();
      expect(doc.data()?['athleteFirstName'], 'Updated');
    });

    test('successful delete order', () async {
      final order = ParentOrder(
        id: 'del-order',
        userId: coachUser.id,
        athleteFirstName: 'Old',
        athleteLastName: 'Order',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await firestore.collection('parentOrders').doc('del-order').set(order.toFirestore());

      await OrderService.deleteOrder(firestore, coachUser, 'del-order');
      
      final doc = await firestore.collection('parentOrders').doc('del-order').get();
      expect(doc.exists, isFalse);
    });

    test('store-linked Coach ownership allows edit', () async {
      await firestore.collection('teamStores').doc('store-coach1').set({'userId': coachUser.id});
      final order = ParentOrder(
        id: 'store-order',
        teamStoreId: 'store-coach1',
        athleteFirstName: 'Athlete',
        athleteLastName: 'Athlete',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await firestore.collection('parentOrders').doc('store-order').set(order.toFirestore());

      final err1 = await OrderService.updateOrder(firestore, coachUser, order.copyWith(athleteFirstName: 'Changed'));
      expect(err1, isNull);
    });

    test('Coach cannot modify another coachs order', () async {
      final order = ParentOrder(
        id: 'direct-coach2',
        userId: coachUser2.id,
        athleteFirstName: 'Athlete',
        athleteLastName: 'Athlete',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await firestore.collection('parentOrders').doc('direct-coach2').set(order.toFirestore());

      final err = await OrderService.deleteOrder(firestore, coachUser, 'direct-coach2');
      expect(err, 'Unauthorized');
    });
    
    test('Admin access to direct orders allows edit/delete', () async {
      final order = ParentOrder(
        id: 'direct-coach2',
        userId: coachUser2.id,
        athleteFirstName: 'Athlete',
        athleteLastName: 'Athlete',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await firestore.collection('parentOrders').doc('direct-coach2').set(order.toFirestore());

      final err = await OrderService.deleteOrder(firestore, adminUser, 'direct-coach2');
      expect(err, isNull);
    });
  });
}


