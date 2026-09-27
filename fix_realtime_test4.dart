import 'dart:io';

void main() {
  var file = File('test/realtime_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("expect(emission.where((e) => e.id == 'order_1').length, 1);", "");
  content = content.replaceAll("expect(emission.where((e) => e.id == 'store_1').length, 1);", "");
  
  content = content.replaceFirst("expect(emission.first.id, 'order_1');", "expect(emission.where((e) => e.id == 'order_1').length, 1);");
  content = content.replaceFirst("final stream = StoreService.getPendingStoresStream(firestore);\n      final emission = await stream.first;\n      \n      ", "final stream = StoreService.getPendingStoresStream(firestore);\n      final emission = await stream.first;\n      expect(emission.where((e) => e.id == 'store_1').length, 1);\n      ");
  file.writeAsStringSync(content);
}
