import 'dart:io';

void processFile(String path, List<String> toRemove) {
  var file = File(path);
  var content = file.readAsStringSync();
  
  // Remove dummy imports
  content = content.replaceAll(RegExp(r"import '\.\./data/dummy_[^']+';\n?"), "");
  
  file.writeAsStringSync(content);
}

void main() {
  processFile('lib/services/auth_service.dart', []);
  processFile('lib/services/admin_service.dart', []);
  processFile('lib/services/catalog_service.dart', []);
  processFile('lib/services/order_service.dart', []);
  processFile('lib/services/store_service.dart', []);
  processFile('lib/services/team_store_service.dart', []);
}
