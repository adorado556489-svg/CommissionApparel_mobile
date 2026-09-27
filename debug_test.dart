import 'dart:io';

void main() {
  final file = File('test/coach_direct_order_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  content = content.replaceAll(
    "final error = await OrderService.finalizeDirectOrders(FakeFirebaseFirestore(), coach);",
    "print('Draft orders in dummy data: \${dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == coach.id && o.status == 'Draft').toList()}');\n      final error = await OrderService.finalizeDirectOrders(FakeFirebaseFirestore(), coach);"
  );

  file.writeAsStringSync(content);
}
