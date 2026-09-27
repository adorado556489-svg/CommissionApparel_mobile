import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(RegExp(r"import '\.\./\.\./data/dummy_.*';\n"), "");
  
  if (!content.contains("import '../../services/store_service.dart';")) {
    content = content.replaceAll("import '../../services/auth_service.dart';", "import '../../services/auth_service.dart';\nimport '../../services/store_service.dart';\nimport '../../services/order_service.dart';\nimport '../../services/catalog_service.dart';");
  }
  
  file.writeAsStringSync(content);
}
