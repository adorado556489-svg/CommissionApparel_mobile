import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team_store.dart';
import '../models/store_item.dart';
import '../constants/firestore_paths.dart';
import 'package:flutter/foundation.dart';

class StoreService {
  static void _handleError(Object e, String context) {
    if (e is FirebaseException) {
      if (e.code == 'not-found' || e.code == 'unimplemented') return;
      debugPrint('CRITICAL FIRESTORE ERROR [$context]: $e');
      throw e;
    }
    debugPrint('UNKNOWN ERROR [$context]: $e');
    throw e;
  }

  static Future<TeamStore?> getActiveStoreForCoach(FirebaseFirestore firestore, String coachId) async {
    debugPrint('GETTING STORE FOR COACH: $coachId');
    try {
      final qs = await firestore
          .collection(FirestorePaths.teamStores)
          .where('userId', isEqualTo: coachId)
          .where('isArchived', isEqualTo: false)
          .limit(1)
          .get();
      if (qs.docs.isNotEmpty) {
        return TeamStore.fromFirestore(qs.docs.first);
      }
    } catch (e) { _handleError(e, "StoreService"); }
    return null;
  }

  static Future<TeamStore?> getStoreForUser(FirebaseFirestore firestore, String userId) async {
    try {
      final qs = await firestore
          .collection(FirestorePaths.teamStores)
          .where('userId', isEqualTo: userId)
          .where('isArchived', isEqualTo: false)
          .limit(1)
          .get();
      if (qs.docs.isNotEmpty) {
        return TeamStore.fromFirestore(qs.docs.first);
      }
    } catch (e) { _handleError(e, "StoreService.getStoreForUser"); }
    return null;
  }

  static Future<List<TeamStore>> getActiveStores(FirebaseFirestore firestore) async {
    try {
      final qs = await firestore
          .collection(FirestorePaths.teamStores)
          .where('isArchived', isEqualTo: false)
          .get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => TeamStore.fromFirestore(d)).where((s) => s.isLive).toList();
      }
    } catch (e) { _handleError(e, "StoreService"); }
    return [];
  }

  static Future<TeamStore?> getStoreById(FirebaseFirestore firestore, String storeId) async {
    try {
      final doc = await firestore.collection(FirestorePaths.teamStores).doc(storeId).get();
      if (doc.exists) return TeamStore.fromFirestore(doc);
    } catch (e) { _handleError(e, "StoreService"); }
    return null;
  }

  static Stream<List<TeamStore>> getPendingStoresStream(FirebaseFirestore firestore) {
    return firestore
        .collection(FirestorePaths.teamStores)
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .map((qs) => qs.docs.map((d) => TeamStore.fromFirestore(d)).toList());
  }

  static Future<List<TeamStore>> getPendingStores(FirebaseFirestore firestore) async {
    try {
      final qs = await firestore
          .collection(FirestorePaths.teamStores)
          .where('status', isEqualTo: 'pending')
          .get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => TeamStore.fromFirestore(d)).toList();
      }
    } catch (e) { _handleError(e, "StoreService"); }
    return [];
  }

  static Future<List<TeamStore>> getCampaignStores(FirebaseFirestore firestore) async {
    List<TeamStore> stores = [];
    try {
      final userQs = await firestore.collection('users').where('role', isEqualTo: 'admin').get();
      final adminIds = userQs.docs.map((d) => d.id).toList();
      if (adminIds.isNotEmpty) {
        for (var i = 0; i < adminIds.length; i += 10) {
          final chunk = adminIds.sublist(i, i + 10 > adminIds.length ? adminIds.length : i + 10);
          final qs = await firestore.collection(FirestorePaths.teamStores).where('userId', whereIn: chunk).get();
          stores.addAll(qs.docs.map((d) => TeamStore.fromFirestore(d)));
        }
      }
    } catch (e) { 
      _handleError(e, "StoreService.getCampaignStores");
    }
    return stores;
  }

  static Future<void> createStore(FirebaseFirestore firestore, TeamStore store) async {
    try {
      await firestore.collection(FirestorePaths.teamStores).doc(store.id).set(store.toFirestore());
    } catch (e) { _handleError(e, "StoreService"); }
  }

  static Future<void> updateStore(FirebaseFirestore firestore, TeamStore store) async {
    try {
      await firestore.collection(FirestorePaths.teamStores).doc(store.id).update(store.toFirestore());
    } catch (e) { _handleError(e, "StoreService"); }
  }
  
  static Future<void> deleteStoreForCoach(FirebaseFirestore firestore, String coachId) async {
    try {
      final qs = await firestore.collection(FirestorePaths.teamStores).where('userId', isEqualTo: coachId).get();
      for (var doc in qs.docs) {
        await firestore.collection(FirestorePaths.teamStores).doc(doc.id).delete();
      }
    } catch (e) { _handleError(e, "StoreService"); }
  }

  static Future<List<StoreItem>> getStoreItems(FirebaseFirestore firestore, String storeId) async {
    try {
      final qs = await firestore
          .collection(FirestorePaths.storeItems)
          .where('teamStoreId', isEqualTo: storeId)
          .get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => StoreItem.fromFirestore(d)).toList();
      }
    } catch (e) { _handleError(e, "StoreService"); }
    return [];
  }

  static Future<void> createStoreItem(FirebaseFirestore firestore, StoreItem item) async {
    try {
      await firestore.collection(FirestorePaths.storeItems).doc(item.id).set(item.toFirestore());
    } catch (e) { _handleError(e, "StoreService"); }
  }

  static Future<void> updateStoreItem(FirebaseFirestore firestore, StoreItem item) async {
    try {
      await firestore.collection(FirestorePaths.storeItems).doc(item.id).update(item.toFirestore());
    } catch (e) { _handleError(e, "StoreService"); }
  }

  static Future<void> deleteStoreItem(FirebaseFirestore firestore, String itemId) async {
    try {
      await firestore.collection(FirestorePaths.storeItems).doc(itemId).delete();
    } catch (e) { _handleError(e, "StoreService"); }
  }
}
