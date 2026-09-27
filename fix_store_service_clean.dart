import 'dart:io';

void main() {
  final file = File('lib/services/store_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  // getActiveStoreForCoach
  content = content.replaceAll(
    "    try { return dummyTeamStores.firstWhere((s) => s.userId == coachId && !s.isArchived); } catch (_) { return null; }",
    "    return null;"
  );

  // getPendingStoresStream
  content = content.replaceAll(
    "      return dummyTeamStores.where((s) => s.status == 'pending').toList();",
    "      return [];"
  );
  
  // getStoreById
  content = content.replaceAll(
    "    try { return dummyTeamStores.firstWhere((s) => s.id == storeId); } catch (_) { return null; }",
    "    return null;"
  );
  
  // getActiveStores
  content = content.replaceAll(
    "      return dummyTeamStores.where((s) => !s.isArchived && s.status == 'approved').toList();",
    "      return [];"
  );

  // getCampaignStores
  content = content.replaceAll(
    "      return dummyTeamStores.where((s) => !s.isArchived && s.status == 'campaign').toList();",
    "      return [];"
  );
  
  // createStore
  content = content.replaceAllMapped(
    RegExp(r"    try \{\s*dummyTeamStores\.add\(newStore\);\s*\} catch \(_\) \{\}"),
    (m) => ""
  );

  // approveStore, updateStoreDeadline, updateStore
  content = content.replaceAllMapped(
    RegExp(r"    try \{\s*final dummyIndex = dummyTeamStores\.indexWhere\(\(s\) => s\.id == storeId\);\s*if \(dummyIndex != -1\) \{\s*dummyTeamStores\[dummyIndex\] = dummyTeamStores\[dummyIndex\]\.copyWith\([^)]*\);\s*\}\s*\} catch \(_\) \{\}"),
    (m) => ""
  );
  
  // getStoreItems
  content = content.replaceAll(
    "      return dummyStoreItems.where((i) => i.teamStoreId == storeId).toList();",
    "      return [];"
  );
  
  // archiveStore
  content = content.replaceAllMapped(
    RegExp(r"    try \{\s*final dummyIndex = dummyTeamStores\.indexWhere\(\(s\) => s\.id == storeId\);\s*if \(dummyIndex != -1\) \{\s*dummyTeamStores\[dummyIndex\] = dummyTeamStores\[dummyIndex\]\.copyWith\(isArchived: true\);\s*\}\s*\} catch \(_\) \{\}"),
    (m) => ""
  );
  
  content = content.replaceAll(
    "    try { return dummyUsers.firstWhere((u) => u.id == store.userId); } catch (_) { return null; }",
    "    return null;"
  );
  
  // createStoreItem, deleteStoreItem, updateStoreItem
  content = content.replaceAllMapped(
    RegExp(r"    try \{\s*dummyStoreItems\.add\(newItem\);\s*\} catch \(_\) \{\}"),
    (m) => ""
  );
  content = content.replaceAllMapped(
    RegExp(r"    try \{\s*final dummyIndex = dummyStoreItems\.indexWhere\(\(i\) => i\.id == itemId\);\s*if \(dummyIndex != -1\) \{\s*dummyStoreItems\[dummyIndex\] = dummyStoreItems\[dummyIndex\]\.copyWith\([^)]*\);\s*\}\s*\} catch \(_\) \{\}"),
    (m) => ""
  );
  content = content.replaceAllMapped(
    RegExp(r"    try \{\s*dummyStoreItems\.removeWhere\(\(i\) => i\.id == itemId\);\s*\} catch \(_\) \{\}"),
    (m) => ""
  );
  
  // Any residual dummyTeamStores index mapping:
  content = content.replaceAllMapped(
    RegExp(r"    try \{\s*final dummyIndex = dummyTeamStores\.indexWhere[^\}]+\}\s*\} catch \(_\) \{\}"),
    (m) => ""
  );
  content = content.replaceAllMapped(
    RegExp(r"    try \{\s*final dummyIndex = dummyStoreItems\.indexWhere[^\}]+\}\s*\} catch \(_\) \{\}"),
    (m) => ""
  );
  
  file.writeAsStringSync(content);
}
