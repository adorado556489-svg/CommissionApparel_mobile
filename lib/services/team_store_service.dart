import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team_store.dart';
import '../models/store_item.dart';
import '../models/user.dart';
import '../constants/firestore_paths.dart';
import '../data/dummy_stores.dart';
import '../data/dummy_users.dart';

class TeamStoreService {

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
    } catch (_) {}
    
    // Fallback
    try {
      return dummyTeamStores.firstWhere(
        (s) => s.userId == coachId && !s.isArchived,
      );
    } catch (_) {
      return null;
    }
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
    } catch (_) {}
    return dummyTeamStores.where((s) => s.isLive).toList();
  }

  static Future<TeamStore?> getStoreById(FirebaseFirestore firestore, String storeId) async {
    try {
      final doc = await firestore.collection(FirestorePaths.teamStores).doc(storeId).get();
      if (doc.exists) {
        return TeamStore.fromFirestore(doc);
      }
    } catch (_) {}
    try {
      return dummyTeamStores.firstWhere((s) => s.id == storeId);
    } catch (_) {
      return null;
    }
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
    } catch (_) {}
    return dummyTeamStores.where((s) => s.status == 'pending').toList();
  }

  static Future<List<TeamStore>> getCampaignStores(FirebaseFirestore firestore) async {
    // Campaign stores are stores where userId is an admin user.
    // In Firestore, we should probably add a boolean 'isCampaign' or fetch all stores and filter.
    // Let's filter in memory for now to match dummy logic.
    List<TeamStore> stores = [];
    try {
      final qs = await firestore.collection(FirestorePaths.teamStores).get();
      stores = qs.docs.map((d) => TeamStore.fromFirestore(d)).toList();
    } catch (_) {
      stores = dummyTeamStores;
    }

    final adminUsers = dummyUsers.where((u) => u.isAdmin).map((u) => u.id).toSet();
    return stores.where((s) => adminUsers.contains(s.userId)).toList();
  }

  static Future<void> createStore(FirebaseFirestore firestore, TeamStore store) async {
    await firestore.collection(FirestorePaths.teamStores).doc(store.id).set(store.toFirestore());
    dummyTeamStores.add(store);
  }

  static Future<void> updateStore(FirebaseFirestore firestore, TeamStore store) async {
    await firestore.collection(FirestorePaths.teamStores).doc(store.id).update(store.toFirestore());
    final idx = dummyTeamStores.indexWhere((s) => s.id == store.id);
    if (idx != -1) dummyTeamStores[idx] = store;
  }
}
