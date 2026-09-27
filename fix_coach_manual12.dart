import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll("onPressed: () {\n                final error = await OrderService.finalizeDirectOrders", "onPressed: () async {\n                final error = await OrderService.finalizeDirectOrders");
  
  content = content.replaceAll("onPressed: () {\n                          await OrderService.archiveDirectOrderBatch", "onPressed: () async {\n                          await OrderService.archiveDirectOrderBatch");

  file.writeAsStringSync(content);
}
