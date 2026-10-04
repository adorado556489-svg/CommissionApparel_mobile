import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../constants/firestore_paths.dart';
import '../constants/statuses.dart';
import '../models/store_item.dart';
import '../models/team_store.dart';

class StoreService {
  StoreService._();

  static CollectionReference<Map<String, dynamic>> _stores(FirebaseFirestore f) =>
      f.collection(FirestorePaths.teamStores);
  static CollectionReference<Map<String, dynamic>> _items(FirebaseFirestore f) =>
      f.collection(FirestorePaths.storeItems);

  static void _handleError(Object e, String context) {
    if (e is FirebaseException && (e.code == 'not-found' || e.code == 'unimplemented')) return;
    debugPrint('FIRESTORE ERROR [$context]: $e');
    throw e;
  }

  /// Picks the most relevant store for an owner: newest non-archived,
  /// preferring an active (approved/locked) store over pending/declined.
  static TeamStore? _pickOwnerStore(Iterable<TeamStore> stores) {
    final list = stores.where((s) => !s.isArchived).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (list.isEmpty) return null;
    return list.firstWhere((s) => s.isApproved || s.isLocked, orElse: () => list.first);
  }

  // ---- Stores ---------------------------------------------------------------

  static Future<TeamStore?> getActiveStoreForCoach(FirebaseFirestore firestore, String coachId) async {
    try {
      final qs = await _stores(firestore).where('userId', isEqualTo: coachId).get();
      return _pickOwnerStore(qs.docs.map(TeamStore.fromFirestore));
    } catch (e) {
      _handleError(e, 'StoreService.getActiveStoreForCoach');
    }
    return null;
  }

  static Future<TeamStore?> getStoreForUser(FirebaseFirestore firestore, String userId) =>
      getActiveStoreForCoach(firestore, userId);

  /// Like [getActiveStoreForCoach] but also returns an archived (suspended)
  /// store, so the owner sees *why* they cannot manage it instead of being
  /// asked to create a new one.
  static Future<TeamStore?> getOwnerStoreIncludingArchived(FirebaseFirestore firestore, String ownerId) async {
    try {
      final qs = await _stores(firestore).where('userId', isEqualTo: ownerId).get();
      final all = qs.docs.map(TeamStore.fromFirestore).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (all.isEmpty) return null;
      final visible = _pickOwnerStore(all);
      return visible ?? all.first;
    } catch (e) {
      _handleError(e, 'StoreService.getOwnerStoreIncludingArchived');
    }
    return null;
  }

  /// Every store regardless of state (admin monitoring), newest first.
  static Future<List<TeamStore>> getAllStores(FirebaseFirestore firestore) async {
    try {
      final qs = await _stores(firestore).get();
      return qs.docs.map(TeamStore.fromFirestore).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _handleError(e, 'StoreService.getAllStores');
    }
    return [];
  }

  /// Changes only the lifecycle [status] (e.g. lock after a master order).
  /// Returns null on success or a user-facing error.
  static Future<String?> setStoreStatus(FirebaseFirestore firestore, String storeId, String status) async {
    try {
      await _stores(firestore).doc(storeId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      debugPrint('StoreService.setStoreStatus: $e');
      return 'Could not update the store status. Please try again.';
    }
  }

  /// Live view of the owner's current store (null if none).
  static Stream<TeamStore?> watchStoreForOwner(FirebaseFirestore firestore, String userId) {
    return _stores(firestore)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((qs) => _pickOwnerStore(qs.docs.map(TeamStore.fromFirestore)));
  }

  static Stream<TeamStore?> watchStore(FirebaseFirestore firestore, String storeId) {
    return _stores(firestore)
        .doc(storeId)
        .snapshots()
        .map((d) => d.exists ? TeamStore.fromFirestore(d) : null);
  }

  /// Stores currently accepting orders, optionally filtered by a free-text
  /// [query] matched against name and sport (case-insensitive, all terms).
  static Future<List<TeamStore>> getActiveStores(FirebaseFirestore firestore, {String query = ''}) async {
    try {
      final qs = await _stores(firestore)
          .where('status', isEqualTo: StoreStatus.approved)
          .where('isArchived', isEqualTo: false)
          .get();
      final terms = query.toLowerCase().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
      final stores = qs.docs.map(TeamStore.fromFirestore).where((s) => s.isLive).where((s) {
        if (terms.isEmpty) return true;
        final haystack = '${s.name} ${s.sport ?? ''} ${s.description ?? ''}'.toLowerCase();
        return terms.every(haystack.contains);
      }).toList();
      // Soonest deadline first so urgent stores surface; no-deadline last.
      stores.sort((a, b) {
        final da = a.deadlineCutoff, db = b.deadlineCutoff;
        if (da == null && db == null) return a.name.compareTo(b.name);
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });
      return stores;
    } catch (e) {
      _handleError(e, 'StoreService.getActiveStores');
    }
    return [];
  }

  static Future<TeamStore?> getStoreById(FirebaseFirestore firestore, String storeId) async {
    if (storeId.isEmpty) return null;
    try {
      final doc = await _stores(firestore).doc(storeId).get();
      if (doc.exists) return TeamStore.fromFirestore(doc);
    } catch (e) {
      _handleError(e, 'StoreService.getStoreById');
    }
    return null;
  }

  static Stream<List<TeamStore>> getPendingStoresStream(FirebaseFirestore firestore) {
    return _stores(firestore)
        .where('status', isEqualTo: StoreStatus.pending)
        .snapshots()
        .map((qs) => qs.docs.map(TeamStore.fromFirestore).toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt)));
  }

  static Future<List<TeamStore>> getPendingStores(FirebaseFirestore firestore) async {
    try {
      final qs = await _stores(firestore).where('status', isEqualTo: StoreStatus.pending).get();
      return qs.docs.map(TeamStore.fromFirestore).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (e) {
      _handleError(e, 'StoreService.getPendingStores');
    }
    return [];
  }

  /// All non-pending stores (admin overview), newest first.
  static Stream<List<TeamStore>> watchAllStores(FirebaseFirestore firestore) {
    return _stores(firestore).snapshots().map((qs) =>
        qs.docs.map(TeamStore.fromFirestore).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  /// Submits a new store request. Rejects if the user already has a pending
  /// or active store. Returns null on success or a user-facing error.
  static Future<String?> submitStoreRequest(FirebaseFirestore firestore, TeamStore store) async {
    try {
      final existing = await getActiveStoreForCoach(firestore, store.userId);
      if (existing != null && !existing.isDeclined) {
        return existing.isPending
            ? 'You already have a store request under review.'
            : 'You already have an active store.';
      }
      await _stores(firestore).doc(store.id).set(store.toFirestore());
      return null;
    } catch (e) {
      debugPrint('StoreService.submitStoreRequest: $e');
      return 'Could not submit your request. Please try again.';
    }
  }

  static Future<void> createStore(FirebaseFirestore firestore, TeamStore store) async {
    try {
      await _stores(firestore).doc(store.id).set(store.toFirestore());
    } catch (e) {
      _handleError(e, 'StoreService.createStore');
    }
  }

  static Future<void> updateStore(FirebaseFirestore firestore, TeamStore store) async {
    try {
      await _stores(firestore).doc(store.id).update(store.toFirestore());
    } catch (e) {
      _handleError(e, 'StoreService.updateStore');
    }
  }

  /// Owner-editable profile fields only (partial update, rules-friendly).
  static const Set<String> ownerEditableFields = {
    'name', 'nameLower', 'description', 'sport', 'logoPath', 'coverImagePath',
    'orderDeadline', 'paymentInstructions', 'updatedAt',
  };

  /// Partially updates a store. Keys outside [ownerEditableFields] are
  /// rejected client-side unless [asAdmin] is true.
  static Future<String?> updateStoreFields(
    FirebaseFirestore firestore,
    String storeId,
    Map<String, dynamic> fields, {
    bool asAdmin = false,
  }) async {
    final data = Map<String, dynamic>.from(fields);
    if (data['name'] is String) data['nameLower'] = (data['name'] as String).toLowerCase();
    if (data['orderDeadline'] is DateTime) {
      data['orderDeadline'] = Timestamp.fromDate(data['orderDeadline'] as DateTime);
    }
    data['updatedAt'] = FieldValue.serverTimestamp();
    if (!asAdmin) {
      final illegal = data.keys.where((k) => !ownerEditableFields.contains(k)).toList();
      if (illegal.isNotEmpty) return 'Not allowed to change: ${illegal.join(', ')}';
    }
    try {
      await _stores(firestore).doc(storeId).update(data);
      return null;
    } catch (e) {
      debugPrint('StoreService.updateStoreFields: $e');
      return 'Could not save changes. Please try again.';
    }
  }

  static Future<void> deleteStoreForCoach(FirebaseFirestore firestore, String coachId) async {
    try {
      final qs = await _stores(firestore).where('userId', isEqualTo: coachId).get();
      final batch = firestore.batch();
      for (final doc in qs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      _handleError(e, 'StoreService.deleteStoreForCoach');
    }
  }

  // ---- Items ----------------------------------------------------------------

  static int _itemOrder(StoreItem a, StoreItem b) {
    final c = a.sortOrder.compareTo(b.sortOrder);
    return c != 0 ? c : a.createdAt.compareTo(b.createdAt);
  }

  static Future<List<StoreItem>> getStoreItems(FirebaseFirestore firestore, String storeId) async {
    try {
      final qs = await _items(firestore).where('teamStoreId', isEqualTo: storeId).get();
      return qs.docs.map(StoreItem.fromFirestore).toList()..sort(_itemOrder);
    } catch (e) {
      _handleError(e, 'StoreService.getStoreItems');
    }
    return [];
  }

  static Stream<List<StoreItem>> watchStoreItems(FirebaseFirestore firestore, String storeId) {
    return _items(firestore)
        .where('teamStoreId', isEqualTo: storeId)
        .snapshots()
        .map((qs) => qs.docs.map(StoreItem.fromFirestore).toList()..sort(_itemOrder));
  }

  static Future<void> createStoreItem(FirebaseFirestore firestore, StoreItem item) async {
    if (!item.hasValidPricing) {
      throw ArgumentError('Retail price cannot be lower than the base cost.');
    }
    try {
      await _items(firestore).doc(item.id).set(item.toFirestore());
    } catch (e) {
      _handleError(e, 'StoreService.createStoreItem');
    }
  }

  /// Fields a coach may change on an existing item.
  static const Set<String> ownerEditableItemFields = {
    'name', 'description', 'retailPrice', 'imagePaths', 'collectionId', 'sortOrder', 'updatedAt',
  };

  /// Updates only the coach-editable fields of [item]; base cost and blank
  /// linkage are never overwritten from the client.
  static Future<void> updateStoreItem(FirebaseFirestore firestore, StoreItem item) async {
    if (!item.hasValidPricing) {
      throw ArgumentError('Retail price cannot be lower than the base cost.');
    }
    final full = item.toFirestore();
    final data = {
      for (final k in ownerEditableItemFields)
        if (k != 'updatedAt') k: full[k],
      'updatedAt': FieldValue.serverTimestamp(),
    };
    try {
      await _items(firestore).doc(item.id).update(data);
    } catch (e) {
      _handleError(e, 'StoreService.updateStoreItem');
    }
  }

  static Future<void> deleteStoreItem(FirebaseFirestore firestore, String itemId) async {
    try {
      await _items(firestore).doc(itemId).delete();
    } catch (e) {
      _handleError(e, 'StoreService.deleteStoreItem');
    }
  }
}
