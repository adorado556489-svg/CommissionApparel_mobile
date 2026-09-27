import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  
  // Remove dummy fallbacks
  content = content.replaceAll(RegExp(r"\} catch \(_\) \{\s*try \{\s*_activeStore = dummyTeamStores\.firstWhere[^\}]+\}\s*catch \(_\) \{\s*_activeStore = null;\s*\}\s*if \(_activeStore != null\) \{\s*_storeItems = dummyStoreItems[^\}]+\}\s*else \{\s*_storeItems = \[\];\s*_unbatchedOrders = \[\];\s*\}\s*\}"), 
  "} catch (e) { _activeStore = null; _storeItems = []; _unbatchedOrders = []; }");

  content = content.replaceAll(RegExp(r"_assignedDesigns = dummyDesignCatalog\.take\(3\)\.toList\(\);"), "_assignedDesigns = []; // Fetch from catalog later if needed");
  
  content = content.replaceAll(RegExp(r"try \{\s*await StoreService\.createStore\(firestore, newStore\);\s*\} catch \(_\) \{\s*dummyTeamStores\.add\(newStore\);\s*\}"),
  "await StoreService.createStore(firestore, newStore);");

  // Fix build context warnings by adding if (!mounted) return;
  content = content.replaceAll(RegExp(r"ScaffoldMessenger\.of\(context\)"), "if (mounted) ScaffoldMessenger.of(context)");
  
  file.writeAsStringSync(content);
}
