import 'dart:io';

void replaceAllMatching(String path, RegExp regex, String replacement) {
  var file = File(path);
  var content = file.readAsStringSync();
  content = content.replaceAll(regex, replacement);
  file.writeAsStringSync(content);
}

void main() {
  var dir = Directory('lib/screens');
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      var content = file.readAsStringSync();
      content = content.replaceAll(RegExp(r"import '[^']+data/dummy_[^']+';\s*"), "");
      file.writeAsStringSync(content);
    }
  }

  // home_screen.dart: import for UserRole if needed, but not used there.

  // store_search_screen.dart
  replaceAllMatching('lib/screens/public/store_search_screen.dart', RegExp(r"final coach = User\(id: '', email: '', firstName: '', lastName: '', role: UserRole\.coach\);"), "final coach = _getEmptyCoach();");
  var userMethods = """
  User _getEmptyCoach() {
    return User(id: '', email: '', firstName: '', lastName: '', password: '', role: 'coach');
  }
""";
  var searchFile = File('lib/screens/public/store_search_screen.dart');
  var searchContent = searchFile.readAsStringSync();
  searchContent = searchContent.replaceAll("class _StoreSearchScreenState extends State<StoreSearchScreen> {", "class _StoreSearchScreenState extends State<StoreSearchScreen> {\n$userMethods");
  searchFile.writeAsStringSync(searchContent);
  
  // store_detail_screen.dart
  replaceAllMatching('lib/screens/public/store_detail_screen.dart', RegExp(r"final coach = _coach \?\? User\(id: '', email: '', firstName: '', lastName: '', role: UserRole\.coach\);"), "final coach = _coach ?? User(id: '', email: '', firstName: '', lastName: '', password: '', role: 'coach');");

  // parent_order_form_screen.dart
  replaceAllMatching('lib/screens/public/parent_order_form_screen.dart', RegExp(r"final s = dummyTeamStores\.firstWhere\(\(s\) => s\.id == widget\.storeId\);\s*storeItems = dummyStoreItems\.where\(\(i\) => i\.teamStoreId == s\.id\)\.toList\(\);"), 
    "final s = TeamStore(id: widget.storeId, userId: '', name: '', slug: '', createdAt: DateTime.now(), updatedAt: DateTime.now());\n        storeItems = [];");

  // admin_dashboard_screen.dart snapshot fix
  var adminFile = File('lib/screens/admin/admin_dashboard_screen.dart');
  var adminContent = adminFile.readAsStringSync();
  adminContent = adminContent.replaceAll("final submittedBatches = snapshot.data![0] as Map<String, List<ParentOrder>>;", "final submittedBatches = snapshot.data![0] as Map<String, List<ParentOrder>>;\n            final stores = snapshot.data![1] as List<TeamStore>;");
  adminContent = adminContent.replaceAll("final store = (snapshot.data![1] as List<TeamStore>).firstWhere", "final store = stores.firstWhere");
  adminFile.writeAsStringSync(adminContent);
}
