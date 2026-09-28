import 'helpers/test_seeder.dart';


import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:commission_apparel_flutter/models/user.dart';
import 'package:commission_apparel_flutter/models/team_store.dart';
import 'package:commission_apparel_flutter/models/parent_order.dart';
import 'package:commission_apparel_flutter/services/order_service.dart';
import 'package:commission_apparel_flutter/services/auth_service.dart';
import 'package:commission_apparel_flutter/services/store_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
  });

  group('Phase 5 Remediation - Order Queries', () {
    test('1. Targeted user order query returns only that user\'s orders', () async {
      await firestore.collection('parentOrders').add({'userId': 'u1', 'status': 'Draft'});
      await firestore.collection('parentOrders').add({'userId': 'u1', 'status': 'Draft'});
      await firestore.collection('parentOrders').add({'userId': 'u2', 'status': 'Draft'});
      
      final qs = await firestore.collection('parentOrders').where('userId', isEqualTo: 'u1').get();
      expect(qs.docs.length, 2);
    });

    test('2. Targeted store order query returns only the requested store\'s orders', () async {
      await firestore.collection('parentOrders').add({'teamStoreId': 's1', 'batchId': null});
      await firestore.collection('parentOrders').add({'teamStoreId': 's2', 'batchId': null});
      
      final qs = await firestore.collection('parentOrders')
        .where('teamStoreId', isEqualTo: 's1')
        .where('batchId', isNull: true)
        .get();
      expect(qs.docs.length, 1);
    });

    test('3. Targeted batch query returns only the requested batch\'s orders', () async {
      await firestore.collection('parentOrders').add({'userId': 'u1', 'batchId': 'b1'});
      await firestore.collection('parentOrders').add({'userId': 'u1', 'batchId': 'b2'});
      
      final qs = await firestore.collection('parentOrders')
        .where('userId', isEqualTo: 'u1')
        .get();
      final filtered = qs.docs.map((d) => ParentOrder.fromFirestore(d)).where((o) => o.batchId == 'b1').toList();
      expect(filtered.length, 1);
    });
  });

  group('Phase 5 Remediation - submitStoreOrdersToAdmin Ownership', () {
    final owner = User(id: 'owner', email: 'o@o.com', password: '', firstName: 'O', lastName: 'O', role: UserRole.coach, createdAt: DateTime.now(), updatedAt: DateTime.now());
    final notOwner = User(id: 'notOwner', email: 'n@n.com', password: '', firstName: 'N', lastName: 'N', role: UserRole.coach, createdAt: DateTime.now(), updatedAt: DateTime.now());
    final admin = User(id: 'admin', email: 'a@a.com', password: '', firstName: 'A', lastName: 'A', role: UserRole.admin, createdAt: DateTime.now(), updatedAt: DateTime.now());
    
    setUp(() async {
    await TestSeeder.seedAll(firestore);

      await firestore.collection('teamStores').doc('store1').set({
        'userId': 'owner',
        'status': 'pending',
      });
      await firestore.collection('parentOrders').doc('order1').set({
        'teamStoreId': 'store1',
        'batchId': null,
        'userId': 'customer',
        'status': 'Pending',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'athleteFirstName': 'A',
        'athleteLastName': 'B',
        'itemEntries': [],
        'totalRetailPrice': 0,
      });
    });

    test('4. Owner can submit store orders', () async {
      final error = await OrderService.submitStoreOrdersToAdmin(firestore, owner, 'store1', 'batch1');
      expect(error, isNull);
      
      final order = await firestore.collection('parentOrders').doc('order1').get();
      expect(order.data()!['status'], 'Submitted to Admin');
    });

    test('5. Non-owner cannot submit store orders', () async {
      final error = await OrderService.submitStoreOrdersToAdmin(firestore, notOwner, 'store1', 'batch1');
      expect(error, 'Unauthorized');
      
      final order = await firestore.collection('parentOrders').doc('order1').get();
      expect(order.data()!['status'], 'Pending'); // Unchanged
    });

    test('6. Admin can submit store orders', () async {
      final error = await OrderService.submitStoreOrdersToAdmin(firestore, admin, 'store1', 'batch1');
      expect(error, isNull);
    });
  });
}
