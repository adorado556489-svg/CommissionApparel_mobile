import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var code = file.readAsStringSync();
  
  // Fix finalize direct orders
  code = code.replaceAll(
    "onPressed: () {\n                final error = await OrderService.finalizeDirectOrders", 
    "onPressed: () async {\n                final error = await OrderService.finalizeDirectOrders"
  );
  
  // Fix archive
  code = code.replaceAll(
    "onPressed: () {\n                          await OrderService.archiveDirectOrderBatch", 
    "onPressed: () async {\n                          await OrderService.archiveDirectOrderBatch"
  );
  
  // Add CatalogService import if missing
  if (!code.contains("import '../../services/catalog_service.dart';")) {
    code = code.replaceAll("import '../../data/dummy_catalog.dart';", "import '../../data/dummy_catalog.dart';\nimport '../../services/catalog_service.dart';");
  }

  file.writeAsStringSync(code);
}
