import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team_store.dart';
import '../models/store_item.dart';
import '../models/user.dart';
import '../constants/firestore_paths.dart';
import '../data/dummy_stores.dart';
import '../data/dummy_users.dart';

import 'package:flutter/foundation.dart';

class StoreService {
  static void _handleError(Object e, String context) {
    if (e is FirebaseException) {
      if (e.code == 'not-found' || e.code == 'unimplemented') return;
      debugPrint('CRITICAL FIRESTORE ERROR [$context]: $e');
      throw e;
    }
    debugPrint('UNKNOWN ERROR [$context]: $e');
  }


  // --- TEAM STORE METHODS ---

  static Future<TeamStore?> getActiveStoreForCoach(FirebaseFirestore firestore, String coachId) async {
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
    } catch (e) { _handleError(e, "StoreService");  }
    try { return dummyTeamStores.firstWhere((s) => s.userId == coachId && !s.isArchived); } catch (_) { return null; }
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
    } catch (e) { _handleError(e, "StoreService");  }
    return dummyTeamStores.where((s) => s.isLive).toList();
  }

  static Future<TeamStore?> getStoreById(FirebaseFirestore firestore, String storeId) async {
    try {
      final doc = await firestore.collection(FirestorePaths.teamStores).doc(storeId).get();
      if (doc.exists) return TeamStore.fromFirestore(doc);
    } catch (e) { _handleError(e, "StoreService");  }
    try { return dummyTeamStores.firstWhere((s) => s.id == storeId); } catch (_) { return null; }
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
    } catch (e) { _handleError(e, "StoreService");  }
    return dummyTeamStores.where((s) => s.status == 'pending').toList();
  }

  static Future<List<TeamStore>> getCampaignStores(FirebaseFirestore firestore) async {
    List<TeamStore> stores = [];
    try {
      final qs = await firestore.collection(FirestorePaths.teamStores).get();
      if (qs.docs.isNotEmpty) {
        stores = qs.docs.map((d) => TeamStore.fromFirestore(d)).toList();
      } else {
        stores = dummyTeamStores;
      }
    } catch (e) { 
      _handleError(e, "StoreService"); 
      stores = dummyTeamStores; 
    }
    final adminUsers = dummyUsers.where((u) => u.isAdmin).map((u) => u.id).toSet();
    return stores.where((s) => adminUsers.contains(s.userId)).toList();
  }

  static Future<void> createStore(FirebaseFirestore firestore, TeamStore store) async {
    try {
      await firestore.collection(FirestorePaths.teamStores).doc(store.id).set(store.toFirestore());
    } catch (e) { _handleError(e, "StoreService");  }
    dummyTeamStores.add(store);
  }

  static Future<void> updateStore(FirebaseFirestore firestore, TeamStore store) async {
    try {
      await firestore.collection(FirestorePaths.teamStores).doc(store.id).update(store.toFirestore());
    } catch (e) { _handleError(e, "StoreService");  }
    final idx = dummyTeamStores.indexWhere((s) => s.id == store.id);
    if (idx != -1) dummyTeamStores[idx] = store;
  }
  
  static Future<void> deleteStoreForCoach(FirebaseFirestore firestore, String coachId) async {
    try {
      final qs = await firestore.collection(FirestorePaths.teamStores).where('userId', isEqualTo: coachId).get();
      for (var doc in qs.docs) {
        await firestore.collection(FirestorePaths.teamStores).doc(doc.id).delete();
      }
    } catch (e) { _handleError(e, "StoreService");  }
    dummyTeamStores.removeWhere((s) => s.userId == coachId);
  }

  // --- STORE ITEM METHODS ---

  static Future<List<StoreItem>> getStoreItems(FirebaseFirestore firestore, String storeId) async {
    try {
      final qs = await firestore
          .collection(FirestorePaths.storeItems)
          .where('teamStoreId', isEqualTo: storeId)
          .get();
      if (qs.docs.isNotEmpty) {
        return qs.docs.map((d) => StoreItem.fromFirestore(d)).toList();
      }
    } catch (e) { _handleError(e, "StoreService");  }
    return dummyStoreItems.where((i) => i.teamStoreId == storeId).toList();
  }

  static Future<void> createStoreItem(FirebaseFirestore firestore, StoreItem item) async {
    try {
      await firestore.collection(FirestorePaths.storeItems).doc(item.id).set(item.toFirestore());
    } catch (e) { _handleError(e, "StoreService");  }
    dummyStoreItems.add(item);
  }

  static Future<void> updateStoreItem(FirebaseFirestore firestore, StoreItem item) async {
    try {
      await firestore.collection(FirestorePaths.storeItems).doc(item.id).update(item.toFirestore());
    } catch (e) { _handleError(e, "StoreService");  }
    final idx = dummyStoreItems.indexWhere((i) => i.id == item.id);
    if (idx != -1) dummyStoreItems[idx] = item;
  }

  static Future<void> deleteStoreItem(FirebaseFirestore firestore, String itemId) async {
    try {
      await firestore.collection(FirestorePaths.storeItems).doc(itemId).delete();
    } catch (e) { _handleError(e, "StoreService");  }
    dummyStoreItems.removeWhere((i) => i.id == itemId);
  }
}
