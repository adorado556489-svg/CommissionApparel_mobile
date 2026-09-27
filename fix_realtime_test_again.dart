import 'dart:io';

void main() {
  final file = File('test/realtime_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  content = content.replaceAll(
    "// final stream = ContentService.getUserNotificationsStream(firestore, 'user1');",
    "final stream = ContentService.getUserNotificationsStream(firestore, 'user1');"
  );
  
  content = content.replaceAll(
    "// final stream2 = StoreService.getPendingStoresStream(firestore);",
    "final stream2 = StoreService.getPendingStoresStream(firestore);"
  );
  
  content = content.replaceAll(
    "// final stream3 = OrderService.getUnbatchedOrdersForStoreStream(firestore, 'store1');",
    "final stream3 = OrderService.getUnbatchedOrdersForStoreStream(firestore, 'store1');"
  );

  file.writeAsStringSync(content);
}
