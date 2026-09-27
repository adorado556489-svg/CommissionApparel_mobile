import 'dart:io';

void replaceAllMatching(String path, RegExp regex, String replacement) {
  var file = File(path);
  var content = file.readAsStringSync();
  content = content.replaceAll(regex, replacement);
  file.writeAsStringSync(content);
}

void main() {
  replaceAllMatching('lib/screens/admin/admin_store_edit_screen.dart', 
    RegExp(r"final index = dummyStoreItems\.indexWhere\(\(i\) => i\.id == package\.id\);\s*dummyStoreItems\[index\] = package\.copyWith\(\s*componentIds: List\.from\(package\.componentIds\)\.\.remove\(c\.id\)\s*\);"),
    "StoreService.updateStoreItem(context.read<FirebaseFirestore>(), package.copyWith(componentIds: List.from(package.componentIds)..remove(c.id)));");

  replaceAllMatching('lib/screens/admin/admin_store_edit_screen.dart', 
    RegExp(r"final index = dummyStoreItems\.indexWhere\(\(i\) => i\.id == package\.id\);\s*dummyStoreItems\[index\] = package\.copyWith\(\s*componentIds: List\.from\(package\.componentIds\)\.\.add\(val\)\s*\);"),
    "StoreService.updateStoreItem(context.read<FirebaseFirestore>(), package.copyWith(componentIds: List.from(package.componentIds)..add(val)));");

  replaceAllMatching('lib/screens/admin/admin_store_edit_screen.dart', RegExp(r"import '\.\./\.\./data/dummy_stores\.dart';\s*"), "");

  // Now admin_dashboard_screen.dart
  replaceAllMatching('lib/screens/admin/admin_dashboard_screen.dart', RegExp(r"import '\.\./\.\./data/dummy_stores\.dart';\s*"), "");
  replaceAllMatching('lib/screens/admin/admin_dashboard_screen.dart', RegExp(r"import '\.\./\.\./data/dummy_users\.dart';\s*"), "");
  
  // 'OrderService.getSubmittedOrders(context.read<FirebaseFirestore>())' -> actually there is no getSubmittedOrders? Wait, what does it call?
  // Let's replace getSubmittedOrders with getAllOrders... or getBatchedOrders?
}
