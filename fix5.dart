import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var code = file.readAsStringSync();
  
  // Replace using Regex to ignore newlines/whitespace
  code = code.replaceFirst(RegExp(r"onPressed:\s*\(\)\s*\{\s*final error = await OrderService.finalizeDirectOrders"), "onPressed: () async {\n                final error = await OrderService.finalizeDirectOrders");
  
  code = code.replaceFirst(RegExp(r"onPressed:\s*\(\)\s*\{\s*await OrderService.archiveDirectOrderBatch"), "onPressed: () async {\n                          await OrderService.archiveDirectOrderBatch");
  
  file.writeAsStringSync(code);
}
