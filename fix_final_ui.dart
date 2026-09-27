import 'dart:io';

void replaceAllMatching(String path, RegExp regex, String replacement) {
  var file = File(path);
  var content = file.readAsStringSync();
  content = content.replaceAll(regex, replacement);
  file.writeAsStringSync(content);
}

void main() {
  // 1. Order Service Imports
  var orderFile = File('lib/services/order_service.dart');
  var orderLines = orderFile.readAsLinesSync();
  orderLines.insert(0, "import '../constants/firestore_paths.dart';");
  orderFile.writeAsStringSync(orderLines.join('\n'));
  
  var storeFile = File('lib/services/store_service.dart');
  var storeLines = storeFile.readAsLinesSync();
  storeLines.insert(0, "import '../constants/firestore_paths.dart';");
  storeFile.writeAsStringSync(storeLines.join('\n'));
  
  var catalogFile = File('lib/services/catalog_service.dart');
  var catalogLines = catalogFile.readAsLinesSync();
  catalogLines.insert(0, "import '../constants/firestore_paths.dart';");
  catalogFile.writeAsStringSync(catalogLines.join('\n'));

  // 2. Dashboard screen dummy stores
  replaceAllMatching('lib/screens/admin/admin_dashboard_screen.dart', 
    RegExp(r"final store = dummyTeamStores\.firstWhere\(\(s\) => s\.id == storeId, orElse: \(\) => TeamStore\("),
    "final store = stores.firstWhere((s) => s.id == storeId, orElse: () => TeamStore(");

  // 3. UI file imports
  replaceAllMatching('lib/screens/admin/widgets/admin_collections_tab.dart', RegExp(r"import '\.\./\.\./\.\./data/dummy_catalog\.dart';\s*"), "");
  replaceAllMatching('lib/screens/admin/widgets/admin_catalog_tab.dart', RegExp(r"import '\.\./\.\./\.\./data/dummy_catalog\.dart';\s*"), "");
  replaceAllMatching('lib/screens/admin/widgets/admin_catalog_tab.dart', RegExp(r"import '\.\./\.\./\.\./data/dummy_stores\.dart';\s*"), "");

  // Let's also check coach dashboard screen for dummyTeamStores or dummyStoreItems
  replaceAllMatching('lib/screens/coach/coach_dashboard_screen.dart', RegExp(r"import '\.\./\.\./data/dummy_stores\.dart';\s*"), "");
  replaceAllMatching('lib/screens/coach/coach_dashboard_screen.dart', RegExp(r"import '\.\./\.\./data/dummy_orders\.dart';\s*"), "");

  replaceAllMatching('lib/screens/coach/coach_dashboard_screen.dart', RegExp(r"final idx = dummyStoreItems\.indexWhere[^\n]+\n\s*if \(idx != -1\) dummyStoreItems\[idx\] = dummyStoreItems\[idx\]\.copyWith\(retailPrice: retailPrice\);"), 
    "StoreService.updateStoreItem(context.read<FirebaseFirestore>(), item.copyWith(retailPrice: retailPrice));");
    
  replaceAllMatching('lib/screens/coach/coach_dashboard_screen.dart', RegExp(r"final storeIdx = dummyTeamStores\.indexWhere[^\n]+\n\s*if \(storeIdx != -1\) dummyTeamStores\[storeIdx\] = updatedStore;"), 
    "StoreService.updateStore(context.read<FirebaseFirestore>(), updatedStore);");
    
  replaceAllMatching('lib/screens/coach/coach_dashboard_screen.dart', RegExp(r"final idx = dummyParentOrders\.indexWhere[^\n]+\n\s*if \(idx != -1\) \{\s*dummyParentOrders\[idx\] = order\.copyWith\(status: 'Submitted to Admin', batchId: batchId\);\s*\}"), 
    "OrderService.updateOrder(context.read<FirebaseFirestore>(), user, order.copyWith(status: 'Submitted to Admin', batchId: batchId));");
}
