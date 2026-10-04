import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../constants/firestore_paths.dart';
import '../models/user.dart';

/// Read/query helpers for user profiles (stateless, no listeners).
class UserService {
  UserService._();

  static CollectionReference<Map<String, dynamic>> _col(FirebaseFirestore f) =>
      f.collection(FirestorePaths.users);

  static Future<User?> getUserById(
    FirebaseFirestore firestore,
    String uid,
  ) async {
    if (uid.isEmpty) return null;
    try {
      final doc = await _col(firestore).doc(uid).get();
      return doc.exists ? User.fromFirestore(doc) : null;
    } catch (e) {
      debugPrint('UserService.getUserById: $e');
      return null;
    }
  }

  /// Fetches many users in parallel, chunked to Firestore's `whereIn` limit
  /// of 30, returning a map keyed by id.
  static Future<Map<String, User>> getUsersByIds(
    FirebaseFirestore firestore,
    Iterable<String> ids,
  ) async {
    final unique = ids.where((id) => id.isNotEmpty).toSet().toList();
    if (unique.isEmpty) return {};
    const chunkSize = 30;
    final futures = <Future<QuerySnapshot<Map<String, dynamic>>>>[];
    for (var i = 0; i < unique.length; i += chunkSize) {
      final chunk = unique.sublist(
        i,
        i + chunkSize > unique.length ? unique.length : i + chunkSize,
      );
      futures.add(
        _col(firestore).where(FieldPath.documentId, whereIn: chunk).get(),
      );
    }
    final results = await Future.wait(futures);
    return {
      for (final qs in results)
        for (final d in qs.docs) d.id: User.fromFirestore(d),
    };
  }

  /// Live list of all users (admin only), newest first.
  static Stream<List<User>> watchAllUsers(FirebaseFirestore firestore) {
    return _col(firestore).snapshots().map((qs) {
      final users = qs.docs.map(User.fromFirestore).toList();
      users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return users;
    });
  }

  static Future<String?> setStatus(
    FirebaseFirestore firestore,
    String uid,
    String status,
  ) async {
    try {
      await _col(firestore).doc(uid).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      debugPrint('UserService.setStatus: $e');
      return 'Could not update the account status.';
    }
  }

  static Future<void> setDesignAssignment(
    FirebaseFirestore firestore,
    String uid,
    String designId,
    bool assigned,
  ) async {
    await _col(firestore).doc(uid).update({
      'assignedDesignIds': assigned
          ? FieldValue.arrayUnion([designId])
          : FieldValue.arrayRemove([designId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
