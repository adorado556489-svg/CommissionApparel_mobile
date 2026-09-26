import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/design_catalog.dart';
import '../models/design_collection.dart';
import '../models/landing_collection.dart';
import '../constants/firestore_paths.dart';
import '../data/dummy_catalog.dart';
import '../data/dummy_content.dart';

class CatalogService {
  static void _handleError(Object e, String context) {
    if (e is FirebaseException) {
      if (e.code == 'not-found' || e.code == 'unimplemented') return;
      debugPrint('CRITICAL FIRESTORE ERROR [$context]: $e');
      throw e;
    }
    debugPrint('UNKNOWN ERROR [$context]: $e');
  }

  // --- DESIGN CATALOG ---

  static Future<List<DesignCatalog>> getAllDesignCatalog(FirebaseFirestore firestore) async {
    try {
      final qs = await firestore.collection(FirestorePaths.designCatalog).get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => DesignCatalog.fromFirestore(d)).toList();
      }
    } catch (e) {
      _handleError(e, 'CatalogService.getAllDesignCatalog');
    }
    return dummyDesignCatalog;
  }

  static Future<void> createDesignCatalogItem(FirebaseFirestore firestore, DesignCatalog item) async {
    try {
      await firestore.collection(FirestorePaths.designCatalog).doc(item.id).set(item.toFirestore());
    } catch (e) {
      _handleError(e, 'CatalogService.createDesignCatalogItem');
    }
    dummyDesignCatalog.add(item);
  }

  static Future<void> updateDesignCatalogItem(FirebaseFirestore firestore, DesignCatalog item) async {
    try {
      await firestore.collection(FirestorePaths.designCatalog).doc(item.id).update(item.toFirestore());
    } catch (e) {
      _handleError(e, 'CatalogService.updateDesignCatalogItem');
    }
    final idx = dummyDesignCatalog.indexWhere((d) => d.id == item.id);
    if (idx != -1) dummyDesignCatalog[idx] = item;
  }

  static Future<void> deleteDesignCatalogItem(FirebaseFirestore firestore, String id) async {
    try {
      await firestore.collection(FirestorePaths.designCatalog).doc(id).delete();
    } catch (e) {
      _handleError(e, 'CatalogService.deleteDesignCatalogItem');
    }
    dummyDesignCatalog.removeWhere((d) => d.id == id);
  }

  // --- DESIGN COLLECTIONS ---

  static Future<List<DesignCollection>> getAllDesignCollections(FirebaseFirestore firestore) async {
    try {
      final qs = await firestore.collection(FirestorePaths.designCollections).get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => DesignCollection.fromFirestore(d)).toList();
      }
    } catch (e) {
      _handleError(e, 'CatalogService.getAllDesignCollections');
    }
    return dummyDesignCollections;
  }

  static Future<void> createDesignCollection(FirebaseFirestore firestore, DesignCollection collection) async {
    try {
      await firestore.collection(FirestorePaths.designCollections).doc(collection.id).set(collection.toFirestore());
    } catch (e) {
      _handleError(e, 'CatalogService.createDesignCollection');
    }
    dummyDesignCollections.add(collection);
  }

  static Future<void> updateDesignCollection(FirebaseFirestore firestore, DesignCollection collection) async {
    try {
      await firestore.collection(FirestorePaths.designCollections).doc(collection.id).update(collection.toFirestore());
    } catch (e) {
      _handleError(e, 'CatalogService.updateDesignCollection');
    }
    final idx = dummyDesignCollections.indexWhere((c) => c.id == collection.id);
    if (idx != -1) dummyDesignCollections[idx] = collection;
  }

  static Future<void> deleteDesignCollection(FirebaseFirestore firestore, String id) async {
    try {
      await firestore.collection(FirestorePaths.designCollections).doc(id).delete();
    } catch (e) {
      _handleError(e, 'CatalogService.deleteDesignCollection');
    }
    dummyDesignCollections.removeWhere((c) => c.id == id);
  }

  // --- LANDING COLLECTIONS ---

  static Future<List<LandingCollection>> getAllLandingCollections(FirebaseFirestore firestore) async {
    try {
      final qs = await firestore.collection(FirestorePaths.landingCollections).get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => LandingCollection.fromFirestore(d)).toList();
      }
    } catch (e) {
      _handleError(e, 'CatalogService.getAllLandingCollections');
    }
    return dummyLandingCollections;
  }

  static Future<void> createLandingCollection(FirebaseFirestore firestore, LandingCollection collection) async {
    try {
      await firestore.collection(FirestorePaths.landingCollections).doc(collection.id).set(collection.toFirestore());
    } catch (e) {
      _handleError(e, 'CatalogService.createLandingCollection');
    }
    dummyLandingCollections.add(collection);
  }

  static Future<void> updateLandingCollection(FirebaseFirestore firestore, LandingCollection collection) async {
    try {
      await firestore.collection(FirestorePaths.landingCollections).doc(collection.id).update(collection.toFirestore());
    } catch (e) {
      _handleError(e, 'CatalogService.updateLandingCollection');
    }
    final idx = dummyLandingCollections.indexWhere((c) => c.id == collection.id);
    if (idx != -1) dummyLandingCollections[idx] = collection;
  }

  static Future<void> deleteLandingCollection(FirebaseFirestore firestore, String id) async {
    try {
      await firestore.collection(FirestorePaths.landingCollections).doc(id).delete();
    } catch (e) {
      _handleError(e, 'CatalogService.deleteLandingCollection');
    }
    dummyLandingCollections.removeWhere((c) => c.id == id);
  }
}
