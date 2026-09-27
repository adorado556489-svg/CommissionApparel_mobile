import 'dart:io';

void main() {
  var file = File('lib/services/store_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  content = content.replaceAll(
    "      } catch (e) { _handleError(e, \"StoreService\");  }\n      try { return dummyTeamStores.firstWhere((s) => s.userId == coachId && !s.isArchived); } catch (_) { return null; }",
    "        return null;\n      } catch (e) {\n        _handleError(e, \"StoreService\");\n        return null;\n      }"
  );

  content = content.replaceAll(
    "    } catch (e) { _handleError(e, \"StoreService\");  }\n    try { return dummyTeamStores.firstWhere((s) => s.id == storeId); } catch (_) { return null; }",
    "      return null;\n    } catch (e) {\n      _handleError(e, \"StoreService\");\n      return null;\n    }"
  );

  content = content.replaceAll(
    "      } catch (e) { _handleError(e, \"StoreService\");  }\n      return dummyTeamStores.where((s) => !s.isArchived && s.status == 'approved').toList();",
    "        return [];\n      } catch (e) {\n        _handleError(e, \"StoreService\");\n        return [];\n      }"
  );

  content = content.replaceAll(
    "      } catch (e) { _handleError(e, \"StoreService\");  }\n      return dummyTeamStores.where((s) => !s.isArchived && s.status == 'campaign').toList();",
    "        return [];\n      } catch (e) {\n        _handleError(e, \"StoreService\");\n        return [];\n      }"
  );

  content = content.replaceAll(
    "    try {\n      final dummyIndex = dummyTeamStores.indexWhere((s) => s.id == store.id);\n      if (dummyIndex != -1) {\n        dummyTeamStores[dummyIndex] = store;\n      } else {\n        dummyTeamStores.add(store);\n      }\n    } catch (_) {}",
    ""
  );

  content = content.replaceAll(
    "    try {\n      final dummyIndex = dummyTeamStores.indexWhere((s) => s.id == storeId);\n      if (dummyIndex != -1) {\n        dummyTeamStores[dummyIndex] = dummyTeamStores[dummyIndex].copyWith(isArchived: isArchived);\n      }\n    } catch (_) {}",
    ""
  );

  // Store Items
  content = content.replaceAll(
    "      } catch (e) { _handleError(e, \"StoreService\");  }\n      return dummyStoreItems.where((i) => i.teamStoreId == storeId).toList();",
    "        return [];\n      } catch (e) {\n        _handleError(e, \"StoreService\");\n        return [];\n      }"
  );

  content = content.replaceAll(
    "    try {\n      final dummyIndex = dummyStoreItems.indexWhere((i) => i.id == item.id);\n      if (dummyIndex != -1) {\n        dummyStoreItems[dummyIndex] = item;\n      } else {\n        dummyStoreItems.add(item);\n      }\n    } catch (_) {}",
    ""
  );
  
  content = content.replaceAll(
    "    try {\n      dummyStoreItems.removeWhere((i) => i.id == itemId);\n    } catch (_) {}",
    ""
  );

  // Realtime stream fallbacks
  content = content.replaceAll(
    "      if (snapshot.docs.isEmpty) {\n        return dummyTeamStores.where((s) => s.status == 'pending').toList();\n      }",
    ""
  );
  
  // Remove unused imports
  content = content.replaceAll("import '../data/dummy_stores.dart';", "");
  content = content.replaceAll("import '../data/dummy_users.dart';", "");
  
  file.writeAsStringSync(content);
}
