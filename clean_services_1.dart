import 'dart:io';

void replaceAllInFile(String path, Map<String, String> replacements) {
  var file = File(path);
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  for (var entry in replacements.entries) {
    content = content.replaceAll(entry.key, entry.value);
  }
  file.writeAsStringSync(content);
}

void main() {
  replaceAllInFile('lib/services/store_service.dart', {
    "import '../data/dummy_stores.dart';": "",
    "import '../data/dummy_users.dart';": "",
    "} catch (e) { _handleError(e, \"StoreService\");  }\n    try { return dummyTeamStores.firstWhere((s) => s.userId == coachId && !s.isArchived); } catch (_) { return null; }": "} catch (e) { _handleError(e, \"StoreService\"); }\n    return null;",
    "} catch (e) { _handleError(e, \"StoreService\");  }\n    return dummyTeamStores.where((s) => s.isLive).toList();": "} catch (e) { _handleError(e, \"StoreService\"); }\n    return [];",
    "} catch (e) { _handleError(e, \"StoreService\");  }\n    try { return dummyTeamStores.firstWhere((s) => s.id == storeId); } catch (_) { return null; }": "} catch (e) { _handleError(e, \"StoreService\"); }\n    return null;",
    "if (snapshot.docs.isEmpty) {\n        return dummyTeamStores.where((s) => s.status == 'pending').toList();\n      }": "if (snapshot.docs.isEmpty) return [];",
    "} catch (_) {\n      return dummyTeamStores.where((s) => s.status == 'pending').toList();\n    }": "} catch (e) {\n      _handleError(e, \"StoreService\");\n      return [];\n    }",
    "} catch (e) { _handleError(e, \"StoreService\");  }\n    return dummyTeamStores.where((s) => !s.isArchived && s.status == 'approved').toList();": "} catch (e) { _handleError(e, \"StoreService\"); }\n    return [];",
    "} catch (e) { _handleError(e, \"StoreService\");  }\n    return dummyTeamStores.where((s) => !s.isArchived && s.status == 'campaign').toList();": "} catch (e) { _handleError(e, \"StoreService\"); }\n    return [];",
    "try {\n      dummyTeamStores.add(store);\n    } catch (_) {}": "",
    "try {\n      final idx = dummyTeamStores.indexWhere((s) => s.id == store.id);\n      if (idx != -1) dummyTeamStores[idx] = store;\n    } catch (_) {}": "",
    "try {\n      dummyTeamStores.removeWhere((s) => s.userId == coachId);\n    } catch (_) {}": "",
    "} catch (e) { _handleError(e, \"StoreService\");  }\n    return dummyStoreItems.where((i) => i.teamStoreId == storeId).toList();": "} catch (e) { _handleError(e, \"StoreService\"); }\n    return [];",
    "try {\n      dummyStoreItems.add(item);\n    } catch (_) {}": "",
    "try {\n      final idx = dummyStoreItems.indexWhere((i) => i.id == item.id);\n      if (idx != -1) dummyStoreItems[idx] = item;\n    } catch (_) {}": "",
    "try {\n      dummyStoreItems.removeWhere((i) => i.id == itemId);\n    } catch (_) {}": "",
    "final adminUsers = dummyUsers.where((u) => u.isAdmin).map((u) => u.id).toSet();": "final adminUsers = <String>{};",
  });
}
