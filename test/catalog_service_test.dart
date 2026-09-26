import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:commission_apparel_flutter/services/catalog_service.dart';
import 'package:commission_apparel_flutter/models/design_catalog.dart';
import 'package:commission_apparel_flutter/models/design_collection.dart';
import 'package:commission_apparel_flutter/constants/firestore_paths.dart';
import 'package:commission_apparel_flutter/data/dummy_catalog.dart';

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

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dummyDesignCatalog.clear();
    dummyDesignCollections.clear();
  });

  test('Fallback behavior: Expected absence of data returns dummy data', () async {
    // Populate dummy data
    dummyDesignCatalog.add(DesignCatalog(
      id: 'dummy-1',
      name: 'Dummy Design',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    // Do NOT populate Firestore (it's empty).
    final results = await CatalogService.getAllDesignCatalog(fakeFirestore);
    expect(results.length, 1);
    expect(results.first.id, 'dummy-1');
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

    // Populate dummy data
    dummyDesignCatalog.add(DesignCatalog(
      id: 'dummy-1',
      name: 'Dummy Design',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

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

    await CatalogService.createDesignCatalogItem(fakeFirestore, newDesign);

    // Verify Firestore
    final doc = await fakeFirestore.collection(FirestorePaths.designCatalog).doc('new-1').get();
    expect(doc.exists, true);
    expect(doc.data()?['name'], 'New Design');

    // Verify dummy array fallback is populated
    expect(dummyDesignCatalog.length, 1);
    expect(dummyDesignCatalog.first.name, 'New Design');
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

