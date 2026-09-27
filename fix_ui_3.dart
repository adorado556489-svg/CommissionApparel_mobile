import 'dart:io';

void replaceAllMatching(String path, RegExp regex, String replacement) {
  var file = File(path);
  var content = file.readAsStringSync();
  content = content.replaceAll(regex, replacement);
  file.writeAsStringSync(content);
}

void main() {
  // parent_order_form_screen.dart
  replaceAllMatching('lib/screens/public/parent_order_form_screen.dart', 
    RegExp(r"dummyTeamStores"), "([])");
  replaceAllMatching('lib/screens/public/parent_order_form_screen.dart', 
    RegExp(r"dummyStoreItems"), "([])");

  // admin_dashboard_screen.dart
  var adminFile = File('lib/screens/admin/admin_dashboard_screen.dart');
  var adminContent = adminFile.readAsStringSync();
  adminContent = adminContent.replaceAll(
    "final storeId = orders.first.teamStoreId;\n            final store = stores.firstWhere((s) => s.id == storeId, orElse: () => TeamStore(",
    "final storeId = orders.first.teamStoreId;\n            final stores = snapshot.data![1] as List<TeamStore>;\n            final store = stores.firstWhere((s) => s.id == storeId, orElse: () => TeamStore("
  );
  adminFile.writeAsStringSync(adminContent);
  
  // store_search_screen.dart
  var searchFile = File('lib/screens/public/store_search_screen.dart');
  var searchContent = searchFile.readAsStringSync();
  if (!searchContent.contains("import '../../models/user.dart';")) {
    searchContent = "import '../../models/user.dart';\n" + searchContent;
  }
  searchContent = searchContent.replaceAll("role: 'coach'", "role: 'coach', createdAt: DateTime.now(), updatedAt: DateTime.now()");
  searchFile.writeAsStringSync(searchContent);
  
  // store_detail_screen.dart
  var detailFile = File('lib/screens/public/store_detail_screen.dart');
  var detailContent = detailFile.readAsStringSync();
  detailContent = detailContent.replaceAll("role: 'coach'", "role: 'coach', createdAt: DateTime.now(), updatedAt: DateTime.now()");
  detailFile.writeAsStringSync(detailContent);
}
