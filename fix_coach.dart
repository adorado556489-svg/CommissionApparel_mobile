import 'dart:io';

void main() {
  final file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var code = file.readAsStringSync();
  
  // 1. Imports
  code = code.replaceAll("import '../../data/dummy_orders.dart';", "import '../../services/order_service.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport '../../services/store_service.dart';");

  // 2. _buildDirectOrdersTab
  final directOld = RegExp(r"Widget _buildDirectOrdersTab\(\) \{[\s\S]*?final batchedOrders = dummyParentOrders\.where\(\(o\) => o\.teamStoreId == null && o\.userId == user\.id && o\.batchId != null && !o\.isArchived\)\.toList\(\);");
  final directNew = """Widget _buildDirectOrdersTab() {
    final user = context.watch<AuthService>().currentUser!;
    return FutureBuilder<List<ParentOrder>>(
      future: OrderService.getAllOrders(context.read<FirebaseFirestore>()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final allOrders = snapshot.data!;
        final draftOrders = allOrders.where((o) => o.teamStoreId == null && o.userId == user.id && o.status == 'Draft').toList();
        final batchedOrders = allOrders.where((o) => o.teamStoreId == null && o.userId == user.id && o.batchId != null && !o.isArchived).toList();""";
        
  if (code.contains(directOld)) {
    code = code.replaceAll(directOld, directNew);
    
    // add closing braces before _buildOrderRow
    final orderRowIdx = code.indexOf("  Widget _buildOrderRow");
    if (orderRowIdx != -1) {
       final before = code.substring(0, orderRowIdx);
       final after = code.substring(orderRowIdx);
       // before ends with:       ],\n    );\n  }\n\n
       // we need to inject:      }\n    );\n  }\n\n
       
       code = before.trimRight() + "\n      }\n    );\n  }\n\n" + after;
    }
  }
  
  // 3. finalizeDirectOrders
  code = code.replaceAll("OrderService.finalizeDirectOrders(user);", "await OrderService.finalizeDirectOrders(context.read<FirebaseFirestore>(), user);");
  code = code.replaceAll("void _finalizeDraftOrders() {", "Future<void> _finalizeDraftOrders() async {");
  
  // 4. archiveDirectOrderBatch
  code = code.replaceAll("OrderService.archiveDirectOrderBatch(user, e.key);", "await OrderService.archiveDirectOrderBatch(context.read<FirebaseFirestore>(), user, e.key);");
  code = code.replaceAll("void _archiveBatch(String batchId) {", "Future<void> _archiveBatch(String batchId) async {");
  code = code.replaceAll("onPressed: () => _archiveBatch(e.key),", "onPressed: () => _archiveBatch(e.key),"); // wait, if it's async, it doesn't matter for onPressed
  
  // 5. _submitMasterOrder
  code = code.replaceAll("OrderService.submitStoreOrdersToAdmin(user, store.id);", "await OrderService.submitStoreOrdersToAdmin(context.read<FirebaseFirestore>(), user, store.id);");
  code = code.replaceAll("void _submitMasterOrder() {", "Future<void> _submitMasterOrder() async {");

  // fix up dummy parent orders usage in _buildOverviewTab? Wait, no, _buildOverviewTab didn't use dummyParentOrders directly? Let's check!
  
  file.writeAsStringSync(code);
  print("Updated coach_dashboard_screen.dart");
}
