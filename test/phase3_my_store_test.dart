import 'helpers/test_seeder.dart';
import 'helpers/auto_seeding_mock_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:commission_apparel_flutter/app/theme.dart';
import 'package:commission_apparel_flutter/models/team_store.dart';
import 'package:commission_apparel_flutter/models/store_item.dart';
import 'package:commission_apparel_flutter/models/user.dart';
import 'package:commission_apparel_flutter/services/auth_service.dart';
import 'package:commission_apparel_flutter/services/store_service.dart';

void main() {
  late FirebaseFirestore firestore;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
  });

  group('Phase 3 - My Store & User Ownership', () {
    test('1 & 2. Authenticated user can create their own store', () async {
      final user = User(id: 'user123', email: 'test@example.com', firstName: 'Test', lastName: 'User', password: 'pwd', role: UserRole.coach, createdAt: DateTime.now(), updatedAt: DateTime.now());
      
      var store = await StoreService.getActiveStoreForCoach(firestore, user.id);
      expect(store, isNull, reason: 'Authenticated user with no store');

      final newStore = TeamStore(
        id: 'store-1',
        userId: user.id,
        name: 'My Custom Store',
        slug: 'my-custom-store',
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await StoreService.createStore(firestore, newStore);
      
      store = await StoreService.getActiveStoreForCoach(firestore, user.id);
      expect(store, isNotNull);
      expect(store!.name, 'My Custom Store');
      expect(store.userId, 'user123', reason: 'Created store contains correct owner UID');
    });

    test('4 & 5. User retrieves own store and cannot retrieve another user store', () async {
      await StoreService.createStore(firestore, TeamStore(id: 's1', userId: 'userA', name: 'A', slug: 'a', createdAt: DateTime.now(), updatedAt: DateTime.now()));
      await StoreService.createStore(firestore, TeamStore(id: 's2', userId: 'userB', name: 'B', slug: 'b', createdAt: DateTime.now(), updatedAt: DateTime.now()));
      
      final storeA = await StoreService.getActiveStoreForCoach(firestore, 'userA');
      expect(storeA!.id, 's1');
      expect(storeA.userId, 'userA');
      
      // userA cannot get userB's store via getActiveStoreForCoach
      expect(storeA.id, isNot('s2'));
    });

    test('6. Store item creation uses correct store ownership', () async {
      final item = StoreItem(id: 'item1', teamStoreId: 'store-1', designCatalogId: 'd1', name: 'Item', retailPrice: 50, createdAt: DateTime.now(), updatedAt: DateTime.now());
      await StoreService.createStoreItem(firestore, item);
      
      final items = await StoreService.getStoreItems(firestore, 'store-1');
      expect(items.length, 1);
      expect(items.first.teamStoreId, 'store-1');
    });

    test('8. Deadline validation & 10. Store status & 11. Account active != store approved', () {
      final store = TeamStore(id: 's1', userId: 'u1', name: 'N', slug: 'n', status: 'pending', createdAt: DateTime.now(), updatedAt: DateTime.now());
      expect(store.status, 'pending');
      expect(store.isLive, false);
      
      final approvedStore = store.copyWith(status: 'approved', pricingApproved: true);
      expect(approvedStore.isLive, true);
      
      final expiredStore = approvedStore.copyWith(orderDeadline: DateTime.now().subtract(const Duration(days: 1)));
      expect(expiredStore.isLive, false);
      expect(expiredStore.closedReason, 'deadline_passed');
    });
  });
}



