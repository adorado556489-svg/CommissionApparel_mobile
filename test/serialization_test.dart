import 'helpers/test_seeder.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commission_apparel_flutter/models/user.dart';
import 'package:commission_apparel_flutter/models/team_store.dart';
import 'package:commission_apparel_flutter/models/parent_order.dart';
import 'package:commission_apparel_flutter/models/store_item.dart';

// Create a simple mock DocumentSnapshot for testing
class MockDocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  final String _id;
  final Map<String, dynamic> _data;

  MockDocumentSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  bool get exists => true;

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();
  @override
  DocumentReference<Map<String, dynamic>> get reference => throw UnimplementedError();
  @override
  dynamic get(Object field) => _data[field as String];
  @override
  operator [](Object field) => _data[field as String];
}

void main() {
  group('Phase 4 - Model Serialization Tests', () {
    test('User serialization preserves all fields', () {
      final now = DateTime.now();
      final original = User(
        id: 'user-1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        password: 'secure', // Password is not serialized intentionally
        role: UserRole.coach,
        status: 'approved',
        organization: 'Acme High',
        assignedDesignIds: ['d1', 'd2'],
        createdAt: now,
        updatedAt: now,
      );

      final firestoreData = original.toFirestore();
      
      // Password should not be in toFirestore()
      expect(firestoreData.containsKey('password'), false);

      final doc = MockDocumentSnapshot('user-1', firestoreData);
      final reconstructed = User.fromFirestore(doc);

      expect(reconstructed.id, 'user-1');
      expect(reconstructed.firstName, 'John');
      expect(reconstructed.role, UserRole.coach);
      expect(reconstructed.assignedDesignIds, ['d1', 'd2']);
      expect(reconstructed.createdAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('TeamStore serialization preserves nullables and Timestamps', () {
      final now = DateTime.now();
      final deadline = now.add(const Duration(days: 7));
      final original = TeamStore(
        id: 'store-1',
        userId: 'coach-1',
        name: 'Tigers Store',
        slug: 'tigers-store',
        orderDeadline: deadline,
        status: 'approved',
        pricingApproved: true,
        createdAt: now,
        updatedAt: now,
      );

      final data = original.toFirestore();
      final doc = MockDocumentSnapshot('store-1', data);
      final reconstructed = TeamStore.fromFirestore(doc);

      expect(reconstructed.id, 'store-1');
      expect(reconstructed.orderDeadline?.millisecondsSinceEpoch, deadline.millisecondsSinceEpoch);
      expect(reconstructed.pricingApproved, true);
      expect(reconstructed.isLive, true); // derived property
    });

    test('ParentOrder serialization handles nested itemEntries', () {
      final now = DateTime.now();
      final original = ParentOrder(
        id: 'order-1',
        athleteFirstName: 'Timmy',
        athleteLastName: 'Turner',
        itemEntries: [
          OrderItemEntry(
            storeItemId: 'item-1',
            name: 'Basketball Package',
            types: ['Jersey', 'Shorts'],
            sizes: {'Jersey': 'M', 'Shorts': 'L'},
            quantity: 2,
            components: [
              OrderItemComponent(storeItemId: 'comp-1', name: 'Jersey', sizes: {'Jersey': 'M'}),
              OrderItemComponent(storeItemId: 'comp-2', name: 'Shorts', sizes: {'Shorts': 'L'}),
            ],
          )
        ],
        createdAt: now,
        updatedAt: now,
      );

      final data = original.toFirestore();
      final doc = MockDocumentSnapshot('order-1', data);
      final reconstructed = ParentOrder.fromFirestore(doc);

      expect(reconstructed.itemEntries.length, 1);
      
      final entry = reconstructed.itemEntries.first;
      expect(entry.storeItemId, 'item-1');
      expect(entry.types, ['Jersey', 'Shorts']);
      expect(entry.sizes['Jersey'], 'M');
      expect(entry.quantity, 2);
      expect(entry.isPackage, true);
      
      expect(entry.components.length, 2);
      expect(entry.components.first.name, 'Jersey');
    });
  });
}
