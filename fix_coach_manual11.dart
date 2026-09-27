import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  
  // Add CatalogService import
  if (!content.contains("import '../../services/catalog_service.dart';")) {
    content = content.replaceFirst("import '../../services/store_service.dart';", "import '../../services/store_service.dart';\nimport '../../services/catalog_service.dart';");
  }
  
  // DesignCatalog primaryImagePath issue:
  // _addStoreItem uses design.primaryImagePath, but the field might be just imagePath?
  content = content.replaceAll("design.primaryImagePath", "design.imagePath");
  
  // getUnbatchedOrdersForStore -> getUnbatchedOrders
  content = content.replaceAll("OrderService.getUnbatchedOrdersForStore", "OrderService.getUnbatchedOrders");
  
  file.writeAsStringSync(content);
}
