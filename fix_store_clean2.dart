import 'dart:io';

void replaceFallback(String path, String search, String replace) {
  var file = File(path);
  var content = file.readAsStringSync();
  content = content.replaceAll(search, replace);
  file.writeAsStringSync(content);
}

void main() {
  var storePath = 'lib/services/store_service.dart';
  
  // StoreService getActiveStoreForCoach
  replaceFallback(storePath,
    "      } catch (e) { _handleError(e, \"StoreService\");  }\n      try { return dummyTeamStores.firstWhere((s) => s.userId == coachId && !s.isArchived); } catch (_) { return null; }",
    "        return null;\n      } catch (e) {\n        _handleError(e, \"StoreService\");\n        return null;\n      }"
  );

  // StoreService getPendingStoresStream fallback
  replaceFallback(storePath,
    "      if (snapshot.docs.isEmpty) {\n        return dummyTeamStores.where((s) => s.status == 'pending').toList();\n      }",
    "      if (snapshot.docs.isEmpty) {\n        return [];\n      }"
  );
  replaceFallback(storePath,
    "      return dummyTeamStores.where((s) => s.status == 'pending').toList();",
    "      return [];"
  );
  
  // StoreService getStoreById
  replaceFallback(storePath,
    "    } catch (e) { _handleError(e, \"StoreService\");  }\n    try { return dummyTeamStores.firstWhere((s) => s.id == storeId); } catch (_) { return null; }",
    "      return null;\n    } catch (e) {\n      _handleError(e, \"StoreService\");\n      return null;\n    }"
  );

  // StoreService getActiveStores
  replaceFallback(storePath,
    "      } catch (e) { _handleError(e, \"StoreService\");  }\n      return dummyTeamStores.where((s) => !s.isArchived && s.status == 'approved').toList();",
    "        return [];\n      } catch (e) {\n        _handleError(e, \"StoreService\");\n        return [];\n      }"
  );
  
  // StoreService getCampaignStores
  replaceFallback(storePath,
    "      } catch (e) { _handleError(e, \"StoreService\");  }\n      return dummyTeamStores.where((s) => !s.isArchived && s.status == 'campaign').toList();",
    "        return [];\n      } catch (e) {\n        _handleError(e, \"StoreService\");\n        return [];\n      }"
  );
  
  // StoreService mutations
  replaceFallback(storePath,
    "    try {\n      dummyTeamStores.add(newStore);\n    } catch (_) {}", ""
  );
  replaceFallback(storePath,
    "    try {\n      final dummyIndex = dummyTeamStores.indexWhere((s) => s.id == storeId);\n      if (dummyIndex != -1) {\n        dummyTeamStores[dummyIndex] = dummyTeamStores[dummyIndex].copyWith(status: 'approved');\n      }\n    } catch (_) {}", ""
  );
  replaceFallback(storePath,
    "    try {\n      final dummyIndex = dummyTeamStores.indexWhere((s) => s.id == store.id);\n      if (dummyIndex != -1) {\n        dummyTeamStores[dummyIndex] = store;\n      } else {\n        dummyTeamStores.add(store);\n      }\n    } catch (_) {}", ""
  );
  replaceFallback(storePath,
    "    try {\n      final dummyIndex = dummyTeamStores.indexWhere((s) => s.id == storeId);\n      if (dummyIndex != -1) {\n        dummyTeamStores[dummyIndex] = dummyTeamStores[dummyIndex].copyWith(deadline: deadline);\n      }\n    } catch (_) {}", ""
  );
  replaceFallback(storePath,
    "      } catch (e) { _handleError(e, \"StoreService\");  }\n      return dummyStoreItems.where((i) => i.teamStoreId == storeId).toList();",
    "        return [];\n      } catch (e) {\n        _handleError(e, \"StoreService\");\n        return [];\n      }"
  );
  replaceFallback(storePath,
    "    try {\n      final dummyIndex = dummyTeamStores.indexWhere((s) => s.id == storeId);\n      if (dummyIndex != -1) {\n        dummyTeamStores[dummyIndex] = dummyTeamStores[dummyIndex].copyWith(isArchived: isArchived);\n      }\n    } catch (_) {}", ""
  );
  replaceFallback(storePath,
    "    try { return dummyUsers.firstWhere((u) => u.id == store.userId); } catch (_) { return null; }",
    "    return null;"
  );
  replaceFallback(storePath,
    "    try {\n      dummyStoreItems.add(newItem);\n    } catch (_) {}", ""
  );
  replaceFallback(storePath,
    "    try {\n      final dummyIndex = dummyStoreItems.indexWhere((i) => i.id == item.id);\n      if (dummyIndex != -1) {\n        dummyStoreItems[dummyIndex] = item;\n      } else {\n        dummyStoreItems.add(item);\n      }\n    } catch (_) {}", ""
  );
  replaceFallback(storePath,
    "    try {\n      dummyStoreItems.removeWhere((i) => i.id == itemId);\n    } catch (_) {}", ""
  );
}
