import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/design_catalog.dart';
import '../models/design_collection.dart';
import '../models/landing_collection.dart';
import '../constants/firestore_paths.dart';
import 'package:flutter/foundation.dart';

class CatalogService {
  static Future<void> createDesignCollection(dynamic firestore, dynamic col) async {}
  static Future<void> updateDesignCollection(dynamic firestore, dynamic col) async {}
  static Future<void> deleteDesignCollection(dynamic firestore, String id) async {}
  static Future<void> createDesignCatalogItem(dynamic firestore, dynamic item) async {}
  static Future<void> updateDesignCatalogItem(dynamic firestore, dynamic item) async {}
  static Future<void> deleteDesignCatalogItem(dynamic firestore, String id) async {}

  static void _handleError(Object e, String context) {
    if (e is FirebaseException && (e.code == 'not-found' || e.code == 'unimplemented')) return;
    debugPrint('CRITICAL FIRESTORE ERROR [$context]: $e');
    throw e;
  }

  static Future<List<DesignCatalog>> getAllDesignCatalog(FirebaseFirestore firestore) async {
    try {
      final qs = await firestore.collection(FirestorePaths.designCatalog).get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => DesignCatalog.fromFirestore(d)).toList();
      }
    } catch (e) { _handleError(e, "CatalogService"); }
    return [];
  }

  static Future<List<DesignCollection>> getAllDesignCollections(FirebaseFirestore firestore) async {
    try {
      final qs = await firestore.collection(FirestorePaths.designCollections).get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => DesignCollection.fromFirestore(d)).toList();
      }
    } catch (e) { _handleError(e, "CatalogService"); }
    return [];
  }

  static Future<List<LandingCollection>> getAllLandingCollections(FirebaseFirestore firestore) async {
    try {
      final qs = await firestore.collection(FirestorePaths.landingCollections).get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => LandingCollection.fromFirestore(d)).toList();
      }
    } catch (e) { _handleError(e, "CatalogService"); }
    return [];
  }

  static Future<DesignCatalog?> getDesignById(FirebaseFirestore firestore, String designId) async {
    try {
      final doc = await firestore.collection(FirestorePaths.designCatalog).doc(designId).get();
      if (doc.exists) {
        return DesignCatalog.fromFirestore(doc);
      }
    } catch (e) { _handleError(e, "CatalogService"); }
    return null;
  }

  static Future<void> createDesign(FirebaseFirestore firestore, DesignCatalog design) async {
    try {
      await firestore.collection(FirestorePaths.designCatalog).doc(design.id).set(design.toFirestore());
    } catch (e) { _handleError(e, "CatalogService"); }
  }

  static Future<void> updateDesign(FirebaseFirestore firestore, DesignCatalog design) async {
    try {
      await firestore.collection(FirestorePaths.designCatalog).doc(design.id).update(design.toFirestore());
    } catch (e) { _handleError(e, "CatalogService"); }
  }

  static Future<void> deleteDesign(FirebaseFirestore firestore, String designId) async {
    try {
      await firestore.collection(FirestorePaths.designCatalog).doc(designId).delete();
    } catch (e) { _handleError(e, "CatalogService"); }
  }
}
