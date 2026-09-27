import 'dart:io';

void replaceAllMatching(String path, RegExp regex, String replacement) {
  var file = File(path);
  var content = file.readAsStringSync();
  content = content.replaceAll(regex, replacement);
  file.writeAsStringSync(content);
}

void main() {
  // admin_dashboard_screen.dart
  replaceAllMatching('lib/screens/admin/admin_dashboard_screen.dart', 
    RegExp(r"final batchId = entry\.key;\s*final orders = entry\.value;\s*final storeId = orders\.first\.teamStoreId;\s*final store = stores\.firstWhere"),
    "final batchId = entry.key;\n            final orders = entry.value;\n            final storeId = orders.first.teamStoreId;\n            final stores = snapshot.data![1] as List<TeamStore>;\n            final store = stores.firstWhere");

  // coach_dashboard_screen.dart
  replaceAllMatching('lib/screens/coach/coach_dashboard_screen.dart', 
    RegExp(r"final idx = dummyTeamStores\.indexWhere\(\(s\) => s\.id == _activeStore!\.id\);\s*if \(idx != -1\) dummyTeamStores\[idx\] = dummyTeamStores\[idx\]\.copyWith\(orderDeadline: date\);"),
    "StoreService.updateStore(context.read<FirebaseFirestore>(), _activeStore!.copyWith(orderDeadline: date));");

  replaceAllMatching('lib/screens/coach/coach_dashboard_screen.dart', 
    RegExp(r"final idx = dummyTeamStores\.indexWhere\(\(s\) => s\.id == _activeStore!\.id\);\s*if \(idx != -1\) dummyTeamStores\[idx\] = dummyTeamStores\[idx\]\.copyWith\(pricingApproved: true\);"),
    "StoreService.updateStore(context.read<FirebaseFirestore>(), _activeStore!.copyWith(pricingApproved: true));");

  replaceAllMatching('lib/screens/coach/coach_dashboard_screen.dart', 
    RegExp(r"final idx = dummyStoreItems\.indexWhere\(\(i\) => i\.id == item\.id\);\s*if \(idx != -1\) dummyStoreItems\[idx\] = dummyStoreItems\[idx\]\.copyWith\(retailPrice: dummyStoreItems\[idx\]\.retailPrice \+ amount\);"),
    "StoreService.updateStoreItem(context.read<FirebaseFirestore>(), item.copyWith(retailPrice: item.retailPrice + amount));");

  replaceAllMatching('lib/screens/coach/coach_dashboard_screen.dart', 
    RegExp(r"dummyStoreItems\.add\(item\);"),
    "StoreService.createStoreItem(context.read<FirebaseFirestore>(), item);");
    
  replaceAllMatching('lib/screens/coach/coach_dashboard_screen.dart', 
    RegExp(r"dummyStoreItems\.removeWhere\(\(i\) => i\.id == itemId\);"),
    "StoreService.deleteStoreItem(context.read<FirebaseFirestore>(), itemId);");
}
