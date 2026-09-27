import 'dart:io';

void replace(String path, String oldStr, String newStr) {
    var f = File(path);
    var content = f.readAsStringSync();
    content = content.replaceAll('\r\n', '\n');
    oldStr = oldStr.replaceAll('\r\n', '\n');
    newStr = newStr.replaceAll('\r\n', '\n');
    content = content.replaceAll(oldStr, newStr);
    content = content.replaceAll('\n', '\r\n');
    f.writeAsStringSync(content);
}

void main() {
    // auth_service
    replace('lib/services/auth_service.dart', r'''import '../data/dummy_users.dart';
''', "");
    replace('lib/services/auth_service.dart', r'''import '../data/dummy_logs.dart';
''', "");
    replace('lib/services/auth_service.dart', r'''      } catch (e) {
        _handleError(e, 'AuthService');
        final index = dummyUsers.indexWhere(
          (u) => u.email.toLowerCase() == firebaseUser.email?.toLowerCase(),
        );
        _currentUser = index != -1 ? dummyUsers[index] : null;
      }''', r'''      } catch (e) {
        _handleError(e, 'AuthService');
        _currentUser = null;
      }''');
    replace('lib/services/auth_service.dart', r'''      } else {
        // Fallback to dummy data (Phase 5 migration compatibility)
        final index = dummyUsers.indexWhere(
          (u) => u.email.toLowerCase() == firebaseUser.email?.toLowerCase(),
        );
        if (index != -1) {
          _currentUser = dummyUsers[index];
        } else {
          _currentUser = null;
        }
      }''', r'''      } else {
        _currentUser = null;
      }''');
    replace('lib/services/auth_service.dart', r'''    } catch (e) {
      // Fallback for tests
      final index = dummyUsers.indexWhere(
        (u) => u.email.toLowerCase() == firebaseUser.email?.toLowerCase(),
      );
      _currentUser = index != -1 ? dummyUsers[index] : null;
    }''', r'''    } catch (e) {
      _handleError(e, 'AuthService');
      _currentUser = null;
    }''');
    replace('lib/services/auth_service.dart', r'''      } else {
        // Fallback to dummy users
        final index = dummyUsers.indexWhere(
          (u) => u.email.toLowerCase() == normalizedEmail,
        );
        if (index == -1) {
          return 'Invalid email or password.';
        }
        if (dummyUsers[index].status == 'declined') {
          return 'Your account has been declined. Please contact support.';
        }
      }''', r'''      }''');
    replace('lib/services/auth_service.dart', r'''    } catch (e) {
      // Fallback
      final index = dummyUsers.indexWhere(
        (u) => u.email.toLowerCase() == normalizedEmail,
      );
      if (index == -1) return 'Invalid email or password.';
      if (dummyUsers[index].status == 'declined') {
        return 'Your account has been declined. Please contact support.';
      }
    }''', r'''    } catch (e) {
      _handleError(e, 'AuthService.login');
      return 'Invalid email or password.';
    }''');
    replace('lib/services/auth_service.dart', r'''    try {
      dummyUsers.add(newUser);
    } catch (_) {}''', "");
    replace('lib/services/auth_service.dart', r'''      // Fallback lookup
      final dummyIndex = dummyUsers.indexWhere((u) => u.email.toLowerCase() == normalizedEmail);
      if (dummyIndex != -1) {
        matchedUser = dummyUsers[dummyIndex];
      }''', "");
    replace('lib/services/auth_service.dart', r'''    try {
      dummyPasswordResetLogs.add(PasswordResetLog(
        id: 'pwd-reset-${DateTime.now().millisecondsSinceEpoch}',
        userId: matchedUser.id,
        email: matchedUser.email,
        requestedAt: DateTime.now(),
        status: 'pending',
      ));
    } catch (_) {}''', "");
    replace('lib/services/auth_service.dart', r'''    } catch (_) {}

    if (matchedUser == null) {
      // Fallback lookup
      final dummyIndex = dummyUsers.indexWhere((u) => u.email.toLowerCase() == normalizedEmail);
      if (dummyIndex != -1) {
        matchedUser = dummyUsers[dummyIndex];
      }
    }''', r'''    } catch (e) {
      _handleError(e, 'AuthService.resetPassword');
    }''');

    // Order Service
    replace('lib/services/order_service.dart', r'''import '../data/dummy_orders.dart';
''', "");
    replace('lib/services/order_service.dart', r'''import '../data/dummy_stores.dart';
''', "");
    replace('lib/services/order_service.dart', r'''    } catch (_) {
      return dummyParentOrders.toList();
    }''', r'''    } catch (e) {
      _handleError(e, 'OrderService.getAllOrders');
      return [];
    }''');
    replace('lib/services/order_service.dart', r'''    } catch (e) {
      _handleError(e, 'OrderService._isAuthorizedForStore');
    }
    final storeIndex = dummyTeamStores.indexWhere((s) => s.id == storeId);
    if (storeIndex != -1) {
      return dummyTeamStores[storeIndex].userId == currentUser.id;
    }
    return false;''', r'''    } catch (e) {
      _handleError(e, 'OrderService._isAuthorizedForStore');
    }
    return false;''');
    replace('lib/services/order_service.dart', r'''    dummyParentOrders.add(order); // fallback
''', "");
    replace('lib/services/order_service.dart', r'''    try {
      await firestore.collection(_collectionPath).doc(newId).set(newOrder.toFirestore());
    } catch (e) {
      _handleError(e, 'OrderService.submitDirectOrder');
    }
    dummyParentOrders.add(newOrder);
    return null;''', r'''    try {
      await firestore.collection(_collectionPath).doc(newId).set(newOrder.toFirestore());
    } catch (e) {
      _handleError(e, 'OrderService.submitDirectOrder');
    }
    return null;''');
    replace('lib/services/order_service.dart', r'''    } catch (_) {
      unbatched = dummyParentOrders.where((o) => o.teamStoreId == storeId && o.batchId == null).toList();
    }''', r'''    } catch (e) {
      _handleError(e, 'OrderService.submitStoreOrdersToAdmin');
    }''');
    replace('lib/services/order_service.dart', r'''    } catch (e) {
      _handleError(e, 'OrderService.submitStoreOrdersToAdmin');
    }

    for (var i = 0; i < dummyParentOrders.length; i++) {
      final o = dummyParentOrders[i];
      if (o.teamStoreId == storeId && o.batchId == null) {
        dummyParentOrders[i] = o.copyWith(status: 'Submitted to Admin', batchId: batchId, updatedAt: DateTime.now());
      }
    }''', r'''    } catch (e) {
      _handleError(e, 'OrderService.submitStoreOrdersToAdmin');
    }''');
    replace('lib/services/order_service.dart', r'''    } catch (_) {
      draftOrders = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == currentUser.id && o.status == 'Draft').toList();
    }''', r'''    } catch (e) {
      _handleError(e, 'OrderService.finalizeDirectOrders');
    }''');
    replace('lib/services/order_service.dart', r'''    } catch (e) {
      _handleError(e, 'OrderService.finalizeDirectOrders');
    }

    for (var i = 0; i < dummyParentOrders.length; i++) {
      final o = dummyParentOrders[i];
      if (o.teamStoreId == null && o.userId == currentUser.id && o.status == 'Draft') {
        dummyParentOrders[i] = o.copyWith(
          status: 'Submitted to Admin',
          batchId: batchId,
          updatedAt: DateTime.now(),
        );
      }
    }''', r'''    } catch (e) {
      _handleError(e, 'OrderService.finalizeDirectOrders');
    }''');
    replace('lib/services/order_service.dart', r'''    } catch (_) {
      batchOrders = dummyParentOrders.where((o) => o.userId == currentUser.id && o.batchId == batchId).toList();
    }''', r'''    } catch (e) {
      _handleError(e, 'OrderService.archiveDirectOrderBatch');
    }''');
    replace('lib/services/order_service.dart', r'''    } catch (e) {
      _handleError(e, 'OrderService.archiveDirectOrderBatch');
    }

    for (var i = 0; i < dummyParentOrders.length; i++) {
      final o = dummyParentOrders[i];
      if (o.userId == currentUser.id && o.batchId == batchId) {
        dummyParentOrders[i] = o.copyWith(
          isArchived: true,
          updatedAt: DateTime.now(),
        );
      }
    }''', r'''    } catch (e) {
      _handleError(e, 'OrderService.archiveDirectOrderBatch');
    }''');
    replace('lib/services/order_service.dart', r'''    } catch (e) {
      _handleError(e, 'OrderService.deleteOrder');
    }

    final dummyIndex = dummyParentOrders.indexWhere((o) => o.id == orderId);
    if (dummyIndex != -1) dummyParentOrders.removeAt(dummyIndex);''', r'''    } catch (e) {
      _handleError(e, 'OrderService.deleteOrder');
    }''');
    replace('lib/services/order_service.dart', r'''    } catch (e) {
      _handleError(e, 'OrderService.updateOrder');
    }

    final dummyIndex = dummyParentOrders.indexWhere((o) => o.id == updatedOrder.id);
    if (dummyIndex != -1) {
      dummyParentOrders[dummyIndex] = newOrder;
    }''', r'''    } catch (e) {
      _handleError(e, 'OrderService.updateOrder');
    }''');
    replace('lib/services/order_service.dart', r'''    try {
      return dummyParentOrders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }''', r'''    return null;''');

    // Catalog Service
    replace('lib/services/catalog_service.dart', r'''import '../data/dummy_catalog.dart';
''', "");
    replace('lib/services/catalog_service.dart', r'''    try { return dummyDesignCatalog; } catch (_) { return []; }''', r'''    return [];''');
    replace('lib/services/catalog_service.dart', r'''    try {
      dummyDesignCatalog.add(item);
    } catch (_) {}''', "");
    replace('lib/services/catalog_service.dart', r'''    try {
      final idx = dummyDesignCatalog.indexWhere((d) => d.id == item.id);
      if (idx != -1) dummyDesignCatalog[idx] = item;
    } catch (_) {}''', "");
    replace('lib/services/catalog_service.dart', r'''    try {
      dummyDesignCatalog.removeWhere((d) => d.id == id);
    } catch (_) {}''', "");
    replace('lib/services/catalog_service.dart', r'''    try { return dummyDesignCollections; } catch (_) { return []; }''', r'''    return [];''');
    replace('lib/services/catalog_service.dart', r'''    try {
      dummyDesignCollections.add(collection);
    } catch (_) {}''', "");
    replace('lib/services/catalog_service.dart', r'''    try {
      final idx = dummyDesignCollections.indexWhere((c) => c.id == collection.id);
      if (idx != -1) dummyDesignCollections[idx] = collection;
    } catch (_) {}''', "");
    replace('lib/services/catalog_service.dart', r'''    try {
      dummyDesignCollections.removeWhere((c) => c.id == id);
    } catch (_) {}''', "");
    replace('lib/services/catalog_service.dart', r'''    } catch (_) {
      return dummyLandingCollections;
    }''', r'''    } catch (e) {
      _handleError(e, 'CatalogService'); return [];
    }''');
    replace('lib/services/catalog_service.dart', r'''    try {
      dummyLandingCollections.add(collection);
    } catch (_) {}''', "");
    replace('lib/services/catalog_service.dart', r'''    try {
      final idx = dummyLandingCollections.indexWhere((c) => c.id == collection.id);
      if (idx != -1) dummyLandingCollections[idx] = collection;
    } catch (_) {}''', "");
    replace('lib/services/catalog_service.dart', r'''    try {
      dummyLandingCollections.removeWhere((c) => c.id == id);
    } catch (_) {}''', "");

    // Store Service
    replace('lib/services/store_service.dart', r'''import '../data/dummy_stores.dart';
''', "");
    replace('lib/services/store_service.dart', r'''import '../data/dummy_users.dart';
''', "");
    replace('lib/services/store_service.dart', r'''      } catch (e) { _handleError(e, "StoreService");  }
      try { return dummyTeamStores.firstWhere((s) => s.userId == coachId && !s.isArchived); } catch (_) { return null; }''', r'''      } catch (e) { _handleError(e, "StoreService"); return null; }''');
    replace('lib/services/store_service.dart', r'''      if (snapshot.docs.isEmpty) {
        return dummyTeamStores.where((s) => s.isLive).toList();
      }''', r'''      if (snapshot.docs.isEmpty) return [];''');
    replace('lib/services/store_service.dart', r'''    } catch (e) { _handleError(e, "StoreService");  }
    try { return dummyTeamStores.firstWhere((s) => s.id == storeId); } catch (_) { return null; }''', r'''    } catch (e) { _handleError(e, "StoreService"); return null; }''');
    replace('lib/services/store_service.dart', r'''      if (snapshot.docs.isEmpty) {
        return dummyTeamStores.where((s) => s.status == 'pending').toList();
      }''', r'''      if (snapshot.docs.isEmpty) return [];''');
    replace('lib/services/store_service.dart', r'''    } catch (_) {
      return dummyTeamStores.where((s) => s.status == 'pending').toList();
    }''', r'''    } catch (e) { _handleError(e, "StoreService"); return []; }''');
    replace('lib/services/store_service.dart', r'''            if (stores.isEmpty) {
              stores = dummyTeamStores;
            }''', "");
    replace('lib/services/store_service.dart', r'''          if (stores.isEmpty) {
            stores = dummyTeamStores;
          }''', "");
    replace('lib/services/store_service.dart', r'''        final adminUsers = dummyUsers.where((u) => u.isAdmin).map((u) => u.id).toSet();''', r'''        final adminUsers = <String>{};''');
    replace('lib/services/store_service.dart', r'''    try {
      dummyTeamStores.add(store);
    } catch (_) {}''', "");
    replace('lib/services/store_service.dart', r'''    try {
      final idx = dummyTeamStores.indexWhere((s) => s.id == store.id);
      if (idx != -1) dummyTeamStores[idx] = store;
    } catch (_) {}''', "");
    replace('lib/services/store_service.dart', r'''    try {
      dummyTeamStores.removeWhere((s) => s.userId == coachId);
    } catch (_) {}''', "");
    replace('lib/services/store_service.dart', r'''      } catch (e) { _handleError(e, "StoreService");  }
      return dummyStoreItems.where((i) => i.teamStoreId == storeId).toList();''', r'''      } catch (e) { _handleError(e, "StoreService"); return []; }''');
    replace('lib/services/store_service.dart', r'''    try {
      dummyStoreItems.add(item);
    } catch (_) {}''', "");
    replace('lib/services/store_service.dart', r'''    try {
      final idx = dummyStoreItems.indexWhere((i) => i.id == item.id);
      if (idx != -1) dummyStoreItems[idx] = item;
    } catch (_) {}''', "");
    replace('lib/services/store_service.dart', r'''    try {
      dummyStoreItems.removeWhere((i) => i.id == itemId);
    } catch (_) {}''', "");

    // Team Store Service
    replace('lib/services/team_store_service.dart', r'''import '../data/dummy_stores.dart';
''', "");
    replace('lib/services/team_store_service.dart', r'''import '../data/dummy_users.dart';
''', "");
    replace('lib/services/team_store_service.dart', r'''    } catch (e) {
      _handleError(e, 'TeamStoreService.getActiveStoreForCoach');
      try {
        return dummyTeamStores.firstWhere(
          (s) => s.userId == coachId && s.status == 'approved' && !s.isArchived,
        );
      } catch (_) {
        return null;
      }
    }''', r'''    } catch (e) {
      _handleError(e, 'TeamStoreService.getActiveStoreForCoach');
      return null;
    }''');
    replace('lib/services/team_store_service.dart', r'''      if (snapshot.docs.isEmpty) {
        return dummyTeamStores.where((s) => s.isLive).toList();
      }''', r'''      if (snapshot.docs.isEmpty) return [];''');
    replace('lib/services/team_store_service.dart', r'''    } catch (e) {
      _handleError(e, 'TeamStoreService.getStoreById');
      try {
        return dummyTeamStores.firstWhere((s) => s.id == storeId);
      } catch (_) {
        return null;
      }
    }''', r'''    } catch (e) {
      _handleError(e, 'TeamStoreService.getStoreById');
      return null;
    }''');
    replace('lib/services/team_store_service.dart', r'''      if (snapshot.docs.isEmpty) {
        return dummyTeamStores.where((s) => s.status == 'pending').toList();
      }''', r'''      if (snapshot.docs.isEmpty) return [];''');
    replace('lib/services/team_store_service.dart', r'''    } catch (_) {
      return dummyTeamStores.where((s) => s.status == 'pending').toList();
    }''', r'''    } catch (e) { _handleError(e, "TeamStoreService"); return []; }''');
    replace('lib/services/team_store_service.dart', r'''            if (stores.isEmpty) {
              stores = dummyTeamStores;
            }''', "");
    replace('lib/services/team_store_service.dart', r'''          if (stores.isEmpty) {
            stores = dummyTeamStores;
          }''', "");
    replace('lib/services/team_store_service.dart', r'''        final adminUsers = dummyUsers.where((u) => u.isAdmin).map((u) => u.id).toSet();''', r'''        final adminUsers = <String>{};''');
    replace('lib/services/team_store_service.dart', r'''    try {
      dummyTeamStores.add(store);
    } catch (_) {}''', "");
    replace('lib/services/team_store_service.dart', r'''    try {
      final idx = dummyTeamStores.indexWhere((s) => s.id == store.id);
      if (idx != -1) dummyTeamStores[idx] = store;
    } catch (_) {}''', "");
}
