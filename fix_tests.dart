import 'dart:io';

void replace(String path, String oldStr, String newStr) {
  var file = File(path);
  var content = file.readAsStringSync();
  content = content.replaceFirst(oldStr, newStr);
  file.writeAsStringSync(content);
}

void replaceAll(String path, String oldStr, String newStr) {
  var file = File(path);
  var content = file.readAsStringSync();
  content = content.replaceAll(oldStr, newStr);
  file.writeAsStringSync(content);
}

void main() {
  // 1. coach_direct_order_test.dart
  replace('test/coach_direct_order_test.dart', "import 'package:flutter_test/flutter_test.dart';", "import 'package:flutter_test/flutter_test.dart';\nimport 'package:fake_cloud_firestore/fake_cloud_firestore.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';");
  replaceAll('test/coach_direct_order_test.dart', "OrderService.submitDirectOrder(", "await OrderService.submitDirectOrder(FakeFirebaseFirestore(), ");
  replaceAll('test/coach_direct_order_test.dart', "OrderService.finalizeDirectOrders(coach);", "await OrderService.finalizeDirectOrders(FakeFirebaseFirestore(), coach);");
  replaceAll('test/coach_direct_order_test.dart', "OrderService.archiveDirectOrderBatch(coach, 'batch-direct-1');", "await OrderService.archiveDirectOrderBatch(FakeFirebaseFirestore(), coach, 'batch-direct-1');");

  // 2. coach_order_edit_test.dart
  replace('test/coach_order_edit_test.dart', "import 'package:flutter_test/flutter_test.dart';", "import 'package:flutter_test/flutter_test.dart';\nimport 'package:fake_cloud_firestore/fake_cloud_firestore.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';");
  replaceAll('test/coach_order_edit_test.dart', "final error = OrderService.updateOrder(coach, updatedOrder);", "final error = await OrderService.updateOrder(FakeFirebaseFirestore(), coach, updatedOrder);");
  replaceAll('test/coach_order_edit_test.dart', "OrderService.submitDirectOrder(", "await OrderService.submitDirectOrder(FakeFirebaseFirestore(), ");
  replaceAll('test/coach_order_edit_test.dart', "final error = OrderService.deleteOrder(coach, tempOrder.id);", "final error = await OrderService.deleteOrder(FakeFirebaseFirestore(), coach, tempOrder.id);");

  // 3. phase9_cleanup_test.dart
  replace('test/phase9_cleanup_test.dart', "import 'package:flutter_test/flutter_test.dart';", "import 'package:flutter_test/flutter_test.dart';\nimport 'package:fake_cloud_firestore/fake_cloud_firestore.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';");
  replaceAll('test/phase9_cleanup_test.dart', "test('Admin deleting a Coach cascades to TeamStores and ParentOrders', () {", "test('Admin deleting a Coach cascades to TeamStores and ParentOrders', () async {");
  replaceAll('test/phase9_cleanup_test.dart', "final error = AdminService.deleteCoach(adminUser, coach.id);", "final error = await AdminService.deleteCoach(FakeFirebaseFirestore(), adminUser, coach.id);");
  replaceAll('test/phase9_cleanup_test.dart', "test('Admin deleting an unrelated Coach does NOT delete target Coach data', () {", "test('Admin deleting an unrelated Coach does NOT delete target Coach data', () async {");
  
  // phase9 deleteOrder replacements
  replaceAll('test/phase9_cleanup_test.dart', "test('Admin deletes a store-linked order succeeds', () {", "test('Admin deletes a store-linked order succeeds', () async {");
  replaceAll('test/phase9_cleanup_test.dart', "final error = OrderService.deleteOrder(adminUser, unrelatedStoreOrder.id);", "final error = await OrderService.deleteOrder(FakeFirebaseFirestore(), adminUser, unrelatedStoreOrder.id);");
  
  replaceAll('test/phase9_cleanup_test.dart', "test('Admin deletes a direct order (teamStoreId == null) succeeds', () {", "test('Admin deletes a direct order (teamStoreId == null) succeeds', () async {");
  replaceAll('test/phase9_cleanup_test.dart', "final error = OrderService.deleteOrder(adminUser, directOrder.id);", "final error = await OrderService.deleteOrder(FakeFirebaseFirestore(), adminUser, directOrder.id);");
  
  replaceAll('test/phase9_cleanup_test.dart', "test('Coach deletes their own authorized order preserves valid behavior', () {", "test('Coach deletes their own authorized order preserves valid behavior', () async {");
  replaceAll('test/phase9_cleanup_test.dart', "final error = OrderService.deleteOrder(coachUser, unrelatedStoreOrder.id);", "final error = await OrderService.deleteOrder(FakeFirebaseFirestore(), coachUser, unrelatedStoreOrder.id);");

  replaceAll('test/phase9_cleanup_test.dart', "test('Coach trying to delete someone else\\'s order is Unauthorized', () {", "test('Coach trying to delete someone else\\'s order is Unauthorized', () async {");
  replaceAll('test/phase9_cleanup_test.dart', "final error = OrderService.deleteOrder(invadingCoach, unrelatedStoreOrder.id);", "final error = await OrderService.deleteOrder(FakeFirebaseFirestore(), invadingCoach, unrelatedStoreOrder.id);");
  
  replaceAll('test/phase9_cleanup_test.dart', "test('Verify unrelated orders remain unchanged', () {", "test('Verify unrelated orders remain unchanged', () async {");
  replaceAll('test/phase9_cleanup_test.dart', "OrderService.deleteOrder(adminUser, directOrder.id);", "await OrderService.deleteOrder(FakeFirebaseFirestore(), adminUser, directOrder.id);");

  // 4. admin_batch_show_screen.dart
  replace('lib/screens/admin/admin_batch_show_screen.dart', "import 'package:provider/provider.dart';", "import 'package:provider/provider.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';");
  replace('lib/screens/admin/admin_batch_show_screen.dart', 
    "void _markAddressed(bool isDirect) {", 
    "Future<void> _markAddressed(bool isDirect) async {");
  replace('lib/screens/admin/admin_batch_show_screen.dart', 
    "error = AdminService.markDirectBatchAddressed(admin, widget.batchId);", 
    "error = await AdminService.markDirectBatchAddressed(context.read<FirebaseFirestore>(), admin, widget.batchId);");
  replace('lib/screens/admin/admin_batch_show_screen.dart', 
    "error = AdminService.markStoreBatchAddressed(admin, widget.batchId);", 
    "error = await AdminService.markStoreBatchAddressed(context.read<FirebaseFirestore>(), admin, widget.batchId);");
  
  replace('lib/screens/admin/admin_batch_show_screen.dart', "void _deleteBatch() {", "Future<void> _deleteBatch() async {");
  replace('lib/screens/admin/admin_batch_show_screen.dart', 
    "final error = AdminService.deleteArchivedOrderBatch(admin, widget.batchId);", 
    "final error = await AdminService.deleteArchivedOrderBatch(context.read<FirebaseFirestore>(), admin, widget.batchId);");
}
