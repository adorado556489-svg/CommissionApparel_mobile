import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/design_catalog.dart';
import '../models/design_collection.dart';
import '../models/landing_collection.dart';
import '../constants/firestore_paths.dart';

import 'package:flutter/foundation.dart';

class CatalogService {
  static Future<void> createDesignCollection(
    FirebaseFirestore firestore,
    DesignCollection col,
  ) async {
    try {
      await firestore
          .collection(FirestorePaths.designCollections)
          .doc(col.id)
          .set(col.toFirestore());
    } catch (e) {
      _handleError(e, 'createDesignCollection');
    }
  }

  static Future<void> updateDesignCollection(
    FirebaseFirestore firestore,
    DesignCollection col,
  ) async {
    try {
      await firestore
          .collection(FirestorePaths.designCollections)
          .doc(col.id)
          .update({
            ...col.toFirestore(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      _handleError(e, 'updateDesignCollection');
    }
  }

  static Future<void> deleteDesignCollection(
    FirebaseFirestore firestore,
    String id,
  ) async {
    try {
      await firestore
          .collection(FirestorePaths.designCollections)
          .doc(id)
          .delete();
    } catch (e) {
      _handleError(e, 'deleteDesignCollection');
    }
  }

  static Future<void> createDesignCatalogItem(
    FirebaseFirestore firestore,
    DesignCatalog item,
  ) async => createDesign(firestore, item);
  static Future<void> updateDesignCatalogItem(
    FirebaseFirestore firestore,
    DesignCatalog item,
  ) async => updateDesign(firestore, item);
  static Future<void> deleteDesignCatalogItem(
    FirebaseFirestore firestore,
    String id,
  ) async => deleteDesign(firestore, id);

  static void _handleError(Object e, String context) {
    debugPrint('CRITICAL FIRESTORE ERROR [$context]: $e');
    throw e;
  }

  static Future<List<DesignCatalog>> getCoachDesignCatalog(
    FirebaseFirestore firestore,
    String coachId,
  ) async {
    try {
      final qs = await firestore
          .collection(FirestorePaths.designCatalog)
          .where('coachId', isEqualTo: coachId)
          .get();
      return qs.docs.map((d) => DesignCatalog.fromFirestore(d)).toList();
    } catch (e) {
      _handleError(e, "CatalogService");
    }
    return [];
  }

  static Future<List<DesignCatalog>> getMasterBlankCatalog(
    FirebaseFirestore firestore,
  ) async {
    try {
      final qs = await firestore.collection(FirestorePaths.designCatalog).get();
      return qs.docs
          .map((d) => DesignCatalog.fromFirestore(d))
          .where((d) => d.isMasterBlank)
          .toList();
    } catch (e) {
      _handleError(e, "CatalogService");
    }
    return [];
  }

  static Future<List<DesignCollection>> getCoachDesignCollections(
    FirebaseFirestore firestore,
    String coachId,
  ) async {
    try {
      final qs = await firestore
          .collection(FirestorePaths.designCollections)
          .where('coachId', isEqualTo: coachId)
          .get();
      return qs.docs.map((d) => DesignCollection.fromFirestore(d)).toList();
    } catch (e) {
      _handleError(e, "CatalogService");
    }
    return [];
  }

  static Future<List<DesignCatalog>> getAllDesignCatalog(
    FirebaseFirestore firestore,
  ) async {
    try {
      final qs = await firestore.collection(FirestorePaths.designCatalog).get();
      return qs.docs.map((d) => DesignCatalog.fromFirestore(d)).toList();
    } catch (e) {
      _handleError(e, "CatalogService");
    }
    return [];
  }

  static Future<List<DesignCollection>> getAllDesignCollections(
    FirebaseFirestore firestore,
  ) async {
    try {
      final qs = await firestore
          .collection(FirestorePaths.designCollections)
          .get();
      return qs.docs.map((d) => DesignCollection.fromFirestore(d)).toList();
    } catch (e) {
      _handleError(e, "CatalogService");
    }
    return [];
  }

  static Future<List<LandingCollection>> getAllLandingCollections(
    FirebaseFirestore firestore,
  ) async {
    try {
      final qs = await firestore
          .collection(FirestorePaths.landingCollections)
          .get();
      return qs.docs.map((d) => LandingCollection.fromFirestore(d)).toList();
    } catch (e) {
      _handleError(e, "CatalogService");
    }
    return [];
  }

  static Future<DesignCatalog?> getDesignById(
    FirebaseFirestore firestore,
    String designId,
  ) async {
    try {
      final doc = await firestore
          .collection(FirestorePaths.designCatalog)
          .doc(designId)
          .get();
      if (doc.exists) {
        return DesignCatalog.fromFirestore(doc);
      }
    } catch (e) {
      _handleError(e, "CatalogService");
    }
    return null;
  }

  static Future<void> createDesign(
    FirebaseFirestore firestore,
    DesignCatalog design,
  ) async {
    try {
      await firestore
          .collection(FirestorePaths.designCatalog)
          .doc(design.id)
          .set(design.toFirestore());
    } catch (e) {
      _handleError(e, "CatalogService");
    }
  }

  static Future<void> updateDesign(
    FirebaseFirestore firestore,
    DesignCatalog design,
  ) async {
    try {
      await firestore
          .collection(FirestorePaths.designCatalog)
          .doc(design.id)
          .update(design.toFirestore());
    } catch (e) {
      _handleError(e, "CatalogService");
    }
  }

  static Future<void> deleteDesign(
    FirebaseFirestore firestore,
    String designId,
  ) async {
    try {
      await firestore
          .collection(FirestorePaths.designCatalog)
          .doc(designId)
          .delete();
    } catch (e) {
      _handleError(e, "CatalogService");
    }
  }
}
