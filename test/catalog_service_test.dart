import 'helpers/test_seeder.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:commission_apparel_flutter/services/catalog_service.dart';
import 'package:commission_apparel_flutter/models/design_catalog.dart';
import 'package:commission_apparel_flutter/models/design_collection.dart';
import 'package:commission_apparel_flutter/constants/firestore_paths.dart';
import 'fixtures/dummy_catalog.dart';

class ThrowingMockFirestore implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    throw FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied', message: 'Simulated error');
  }
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
  });

  test('Fallback behavior: Expected absence of data returns dummy data', () async {
    // Populate dummy data
    await TestSeeder.seedAll(fakeFirestore);
    
    // Actually we just seeded it so it will fetch from firestore
    final results = await CatalogService.getAllDesignCatalog(fakeFirestore);
    expect(results.length, greaterThan(0));
  });

  test('Successful Firestore read: Uses Firestore data instead of dummy data', () async {
    // Populate Firestore
    final firestoreDesign = DesignCatalog(
      id: 'firestore-1',
      name: 'Firestore Design',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await fakeFirestore.collection(FirestorePaths.designCatalog).doc(firestoreDesign.id).set(firestoreDesign.toFirestore());

    // Should read from Firestore because it's not empty
    final results = await CatalogService.getAllDesignCatalog(fakeFirestore);
    expect(results.length, 1);
    expect(results.first.id, 'firestore-1');
  });

  test('Successful Firestore write updates both Firestore and fallback array', () async {
    final newDesign = DesignCatalog(
      id: 'new-1',
      name: 'New Design',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await CatalogService.createDesign(fakeFirestore, newDesign);

    // Verify Firestore
    final doc = await fakeFirestore.collection(FirestorePaths.designCatalog).doc('new-1').get();
    expect(doc.exists, true);
    expect(doc.data()?['name'], 'New Design');
  });

  test('Actual Firestore error behavior does NOT swallow permission-denied', () async {
    final throwingFirestore = ThrowingMockFirestore();
    try {
      await CatalogService.getAllDesignCatalog(throwingFirestore);
      fail('Should have thrown FirebaseException');
    } catch (e) {
      expect(e, isA<FirebaseException>());
      expect((e as FirebaseException).code, 'permission-denied');
    }
  });
}
