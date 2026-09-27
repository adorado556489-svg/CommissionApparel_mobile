import 'dart:io';

void replaceAllMatching(String path, RegExp regex, String replacement) {
  var file = File(path);
  var content = file.readAsStringSync();
  content = content.replaceAll(regex, replacement);
  file.writeAsStringSync(content);
}

void main() {
  // home_screen.dart
  replaceAllMatching('lib/screens/public/home_screen.dart', RegExp(r"SiteSetting\.getValue\(dummySiteSettings,"), "SiteSetting.getValue([],");
  replaceAllMatching('lib/screens/public/home_screen.dart', RegExp(r"if \(dummyTestimonials\.isEmpty\)"), "if (true)");
  replaceAllMatching('lib/screens/public/home_screen.dart', RegExp(r"dummyTestimonials\.length"), "0");
  replaceAllMatching('lib/screens/public/home_screen.dart', RegExp(r"final testimonial = dummyTestimonials\[index\];"), "final testimonial = null;");
  
  // store_search_screen.dart
  replaceAllMatching('lib/screens/public/store_search_screen.dart', RegExp(r"var activeStores = dummyTeamStores\.where\(\(s\) => s\.isLive\)\.toList\(\);"), "var activeStores = <TeamStore>[];");
  replaceAllMatching('lib/screens/public/store_search_screen.dart', RegExp(r"final coach = dummyUsers\.firstWhere\(\(u\) => u\.id == s\.userId, orElse: \(\) => dummyAdmin\);"), "final coach = User(id: '', email: '', firstName: '', lastName: '', role: UserRole.coach);");
  replaceAllMatching('lib/screens/public/store_search_screen.dart', RegExp(r"final coach = dummyUsers\.firstWhere\(\(u\) => u\.id == store\.userId, orElse: \(\) => dummyAdmin\);"), "final coach = User(id: '', email: '', firstName: '', lastName: '', role: UserRole.coach);");

  // store_detail_screen.dart
  replaceAllMatching('lib/screens/public/store_detail_screen.dart', RegExp(r"final coach = _coach \?\? dummyAdmin;"), "final coach = _coach ?? User(id: '', email: '', firstName: '', lastName: '', role: UserRole.coach);");
  
  // parent_order_form_screen.dart
  replaceAllMatching('lib/screens/public/parent_order_form_screen.dart', RegExp(r"final s = dummyTeamStores\.firstWhere[^\n]+\n\s*storeItems = dummyStoreItems\.where[^\n]+"), 
  "final s = TeamStore(id: widget.storeId, userId: '', name: '', slug: '', createdAt: DateTime.now(), updatedAt: DateTime.now());\nstoreItems = [];");
}
