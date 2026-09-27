import 'dart:io';

void main() {
  final file = File('test/realtime_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  content = content.replaceAll(
    "final stream = OrderService.getUnbatchedOrdersForStoreStream(firestore, 'store1');",
    "final stream = OrderService.getUnbatchedOrdersForStoreStream(firestore, 'store1');\n      print('Stream emission: \${await stream.first}');"
  );

  file.writeAsStringSync(content);
}
