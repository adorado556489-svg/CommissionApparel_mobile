import os

def replace(path, old, new):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace(old, new)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

# Order Service
replace('lib/services/order_service.dart', "import '../data/dummy_orders.dart';\n", "")
replace('lib/services/order_service.dart', "import '../data/dummy_stores.dart';\n", "")
replace('lib/services/order_service.dart', """    } catch (_) {
      return dummyParentOrders.toList();
    }""", """    } catch (e) {
      _handleError(e, 'OrderService.getAllOrders');
      return [];
    }""")
replace('lib/services/order_service.dart', """    final storeIndex = dummyTeamStores.indexWhere((s) => s.id == storeId);
    if (storeIndex != -1) {
      return dummyTeamStores[storeIndex].userId == currentUser.id;
    }""", "")
replace('lib/services/order_service.dart', "    dummyParentOrders.add(order); // fallback\n", "")
replace('lib/services/order_service.dart', "    dummyParentOrders.add(newOrder);\n", "")
replace('lib/services/order_service.dart', """    } catch (_) {
      unbatched = dummyParentOrders.where((o) => o.teamStoreId == storeId && o.batchId == null).toList();
    }""", """    } catch (e) {
      _handleError(e, 'OrderService.submitStoreOrdersToAdmin');
    }""")
replace('lib/services/order_service.dart', """    for (var i = 0; i < dummyParentOrders.length; i++) {
      final o = dummyParentOrders[i];
      if (o.teamStoreId == storeId && o.batchId == null) {
        dummyParentOrders[i] = o.copyWith(status: 'Submitted to Admin', batchId: batchId, updatedAt: DateTime.now());
      }
    }""", "")
replace('lib/services/order_service.dart', """    } catch (_) {
      draftOrders = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == currentUser.id && o.status == 'Draft').toList();
    }""", """    } catch (e) {
      _handleError(e, 'OrderService.finalizeDirectOrders');
    }""")
replace('lib/services/order_service.dart', """    for (var i = 0; i < dummyParentOrders.length; i++) {
      final o = dummyParentOrders[i];
      if (o.teamStoreId == null && o.userId == currentUser.id && o.status == 'Draft') {
        dummyParentOrders[i] = o.copyWith(
          status: 'Submitted to Admin',
          batchId: batchId,
          updatedAt: DateTime.now(),
        );
      }
    }""", "")
replace('lib/services/order_service.dart', """    } catch (_) {
      batchOrders = dummyParentOrders.where((o) => o.userId == currentUser.id && o.batchId == batchId).toList();
    }""", """    } catch (e) {
      _handleError(e, 'OrderService.archiveDirectOrderBatch');
    }""")
replace('lib/services/order_service.dart', """    for (var i = 0; i < dummyParentOrders.length; i++) {
      final o = dummyParentOrders[i];
      if (o.userId == currentUser.id && o.batchId == batchId) {
        dummyParentOrders[i] = o.copyWith(
          isArchived: true,
          updatedAt: DateTime.now(),
        );
      }
    }""", "")
replace('lib/services/order_service.dart', """    final dummyIndex = dummyParentOrders.indexWhere((o) => o.id == orderId);
    if (dummyIndex != -1) dummyParentOrders.removeAt(dummyIndex);""", "")
replace('lib/services/order_service.dart', """    final dummyIndex = dummyParentOrders.indexWhere((o) => o.id == updatedOrder.id);
    if (dummyIndex != -1) {
      dummyParentOrders[dummyIndex] = newOrder;
    }""", "")

# Catalog Service
replace('lib/services/catalog_service.dart', "import '../data/dummy_catalog.dart';\n", "")
replace('lib/services/catalog_service.dart', """    try { return dummyDesignCatalog; } catch (_) { return []; }""", """    return [];""")
replace('lib/services/catalog_service.dart', """    try {
      dummyDesignCatalog.add(item);
    } catch (_) {}""", "")
replace('lib/services/catalog_service.dart', """    try {
      final idx = dummyDesignCatalog.indexWhere((d) => d.id == item.id);
      if (idx != -1) dummyDesignCatalog[idx] = item;
    } catch (_) {}""", "")
replace('lib/services/catalog_service.dart', """    try {
      dummyDesignCatalog.removeWhere((d) => d.id == id);
    } catch (_) {}""", "")
replace('lib/services/catalog_service.dart', """    try { return dummyDesignCollections; } catch (_) { return []; }""", """    return [];""")
replace('lib/services/catalog_service.dart', """    try {
      dummyDesignCollections.add(collection);
    } catch (_) {}""", "")
replace('lib/services/catalog_service.dart', """    try {
      final idx = dummyDesignCollections.indexWhere((c) => c.id == collection.id);
      if (idx != -1) dummyDesignCollections[idx] = collection;
    } catch (_) {}""", "")
replace('lib/services/catalog_service.dart', """    try {
      dummyDesignCollections.removeWhere((c) => c.id == id);
    } catch (_) {}""", "")
replace('lib/services/catalog_service.dart', """    } catch (_) {
      return dummyLandingCollections;
    }""", """    } catch (e) {
      _handleError(e, 'CatalogService'); return [];
    }""")
replace('lib/services/catalog_service.dart', """    try {
      dummyLandingCollections.add(collection);
    } catch (_) {}""", "")
replace('lib/services/catalog_service.dart', """    try {
      final idx = dummyLandingCollections.indexWhere((c) => c.id == collection.id);
      if (idx != -1) dummyLandingCollections[idx] = collection;
    } catch (_) {}""", "")
replace('lib/services/catalog_service.dart', """    try {
      dummyLandingCollections.removeWhere((c) => c.id == id);
    } catch (_) {}""", "")

# Store Service
replace('lib/services/store_service.dart', "import '../data/dummy_stores.dart';\n", "")
replace('lib/services/store_service.dart', "import '../data/dummy_users.dart';\n", "")
replace('lib/services/store_service.dart', """      } catch (e) { _handleError(e, "StoreService");  }
      try { return dummyTeamStores.firstWhere((s) => s.userId == coachId && !s.isArchived); } catch (_) { return null; }""", """      } catch (e) { _handleError(e, "StoreService"); return null; }""")
replace('lib/services/store_service.dart', """      if (snapshot.docs.isEmpty) {
        return dummyTeamStores.where((s) => s.isLive).toList();
      }""", """      if (snapshot.docs.isEmpty) return [];""")
replace('lib/services/store_service.dart', """    } catch (e) { _handleError(e, "StoreService");  }
    try { return dummyTeamStores.firstWhere((s) => s.id == storeId); } catch (_) { return null; }""", """    } catch (e) { _handleError(e, "StoreService"); return null; }""")
replace('lib/services/store_service.dart', """      if (snapshot.docs.isEmpty) {
        return dummyTeamStores.where((s) => s.status == 'pending').toList();
      }""", """      if (snapshot.docs.isEmpty) return [];""")
replace('lib/services/store_service.dart', """    } catch (_) {
      return dummyTeamStores.where((s) => s.status == 'pending').toList();
    }""", """    } catch (e) { _handleError(e, "StoreService"); return []; }""")
replace('lib/services/store_service.dart', """            if (stores.isEmpty) {
              stores = dummyTeamStores;
            }""", "")
replace('lib/services/store_service.dart', """          if (stores.isEmpty) {
            stores = dummyTeamStores;
          }""", "")
replace('lib/services/store_service.dart', """        final adminUsers = dummyUsers.where((u) => u.isAdmin).map((u) => u.id).toSet();""", """        final adminUsers = <String>{};""")
replace('lib/services/store_service.dart', """    try {
      dummyTeamStores.add(store);
    } catch (_) {}""", "")
replace('lib/services/store_service.dart', """    try {
      final idx = dummyTeamStores.indexWhere((s) => s.id == store.id);
      if (idx != -1) dummyTeamStores[idx] = store;
    } catch (_) {}""", "")
replace('lib/services/store_service.dart', """    try {
      dummyTeamStores.removeWhere((s) => s.userId == coachId);
    } catch (_) {}""", "")
replace('lib/services/store_service.dart', """      } catch (e) { _handleError(e, "StoreService");  }
      return dummyStoreItems.where((i) => i.teamStoreId == storeId).toList();""", """      } catch (e) { _handleError(e, "StoreService"); return []; }""")
replace('lib/services/store_service.dart', """    try {
      dummyStoreItems.add(item);
    } catch (_) {}""", "")
replace('lib/services/store_service.dart', """    try {
      final idx = dummyStoreItems.indexWhere((i) => i.id == item.id);
      if (idx != -1) dummyStoreItems[idx] = item;
    } catch (_) {}""", "")
replace('lib/services/store_service.dart', """    try {
      dummyStoreItems.removeWhere((i) => i.id == itemId);
    } catch (_) {}""", "")

# Team Store Service
replace('lib/services/team_store_service.dart', "import '../data/dummy_stores.dart';\n", "")
replace('lib/services/team_store_service.dart', "import '../data/dummy_users.dart';\n", "")
replace('lib/services/team_store_service.dart', """    } catch (e) {
      _handleError(e, 'TeamStoreService.getActiveStoreForCoach');
      try {
        return dummyTeamStores.firstWhere(
          (s) => s.userId == coachId && s.status == 'approved' && !s.isArchived,
        );
      } catch (_) {
        return null;
      }
    }""", """    } catch (e) {
      _handleError(e, 'TeamStoreService.getActiveStoreForCoach');
      return null;
    }""")
replace('lib/services/team_store_service.dart', """      if (snapshot.docs.isEmpty) {
        return dummyTeamStores.where((s) => s.isLive).toList();
      }""", """      if (snapshot.docs.isEmpty) return [];""")
replace('lib/services/team_store_service.dart', """    } catch (e) {
      _handleError(e, 'TeamStoreService.getStoreById');
      try {
        return dummyTeamStores.firstWhere((s) => s.id == storeId);
      } catch (_) {
        return null;
      }
    }""", """    } catch (e) {
      _handleError(e, 'TeamStoreService.getStoreById');
      return null;
    }""")
replace('lib/services/team_store_service.dart', """      if (snapshot.docs.isEmpty) {
        return dummyTeamStores.where((s) => s.status == 'pending').toList();
      }""", """      if (snapshot.docs.isEmpty) return [];""")
replace('lib/services/team_store_service.dart', """    } catch (_) {
      return dummyTeamStores.where((s) => s.status == 'pending').toList();
    }""", """    } catch (e) { _handleError(e, "TeamStoreService"); return []; }""")
replace('lib/services/team_store_service.dart', """            if (stores.isEmpty) {
              stores = dummyTeamStores;
            }""", "")
replace('lib/services/team_store_service.dart', """          if (stores.isEmpty) {
            stores = dummyTeamStores;
          }""", "")
replace('lib/services/team_store_service.dart', """        final adminUsers = dummyUsers.where((u) => u.isAdmin).map((u) => u.id).toSet();""", """        final adminUsers = <String>{};""")
replace('lib/services/team_store_service.dart', """    try {
      dummyTeamStores.add(store);
    } catch (_) {}""", "")
replace('lib/services/team_store_service.dart', """    try {
      final idx = dummyTeamStores.indexWhere((s) => s.id == store.id);
      if (idx != -1) dummyTeamStores[idx] = store;
    } catch (_) {}""", "")
