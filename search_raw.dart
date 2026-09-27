import 'dart:io';
import 'dart:convert';

void main() {
  var path = 'C:/Users/User/.gemini/antigravity/brain/068df35f-91ee-4740-9ef4-9cc7d9377e9d/.system_generated/logs/transcript_full.jsonl';
  var lines = File(path).readAsLinesSync();
  
  String? lastOrderService;
  String? lastStoreService;
  
  for (var line in lines) {
    if (line.contains('class OrderService {')) {
      lastOrderService = line;
    }
    if (line.contains('class StoreService {')) {
      lastStoreService = line;
    }
  }
  
  if (lastOrderService != null) {
    print('Found OrderService in a block of length ${lastOrderService.length}');
    File('order_service_raw.txt').writeAsStringSync(lastOrderService);
  }
}
