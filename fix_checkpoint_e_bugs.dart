import 'dart:io';

void main() {
  final file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  // Need to make sure dummy_orders is imported if I fallback to it, OR I just remove fallback for orders and use OrderService
  if (!content.contains('dummy_orders.dart')) {
    content = content.replaceFirst("import '../../data/dummy_stores.dart';", "import '../../data/dummy_stores.dart';\nimport '../../data/dummy_orders.dart';");
  }

  // Update _submitMasterOrder to use OrderService
  final oldSubmit = '''  Future<void> _submitMasterOrder() async {
    if (_activeStore == null || _unbatchedOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot submit an empty roster.')),
      );
      return;
    }

    final batchId = 'batch-\${Random().nextInt(10000)}';

    setState(() {
      final updatedStore = _activeStore!.copyWith(status: 'submitted_to_admin');
      final storeIdx = dummyTeamStores.indexWhere((s) => s.id == _activeStore!.id);
      if (storeIdx != -1) dummyTeamStores[storeIdx] = updatedStore;
      _activeStore = updatedStore;

      for (var order in _unbatchedOrders) {
        final idx = dummyParentOrders.indexWhere((o) => o.id == order.id);
        if (idx != -1) {
          dummyParentOrders[idx] = order.copyWith(
            status: 'Submitted to Admin',
            batchId: batchId,
          );
        }
      }
      
      _unbatchedOrders = dummyParentOrders.where((o) => o.teamStoreId == _activeStore!.id && o.batchId == null).toList();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Master order submitted successfully!')),
    );
  }''';

  final newSubmit = '''  Future<void> _submitMasterOrder() async {
    if (_activeStore == null || _unbatchedOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot submit an empty roster.')),
      );
      return;
    }

    final batchId = 'batch-\${DateTime.now().millisecondsSinceEpoch}';
    final firestore = context.read<FirebaseFirestore>();
    final user = context.read<AuthService>().currentUser!;

    await OrderService.submitStoreOrdersToAdmin(firestore, user, _activeStore!.id, batchId);
    await StoreService.updateStoreStatus(firestore, _activeStore!.id, 'submitted_to_admin');
    
    await _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Master order submitted successfully!')),
    );
  }''';
  
  if (content.contains('Future<void> _submitMasterOrder() async {')) {
     content = content.replaceFirst(oldSubmit, newSubmit);
  } else {
     // Checkpoint E had void _submitMasterOrder()
     final oldSubmit2 = oldSubmit.replaceFirst('Future<void> _submitMasterOrder() async {', 'void _submitMasterOrder() {');
     content = content.replaceFirst(oldSubmit2, newSubmit);
  }
  
  // Make _buildDirectOrdersTab await OrderService
  content = content.replaceAll(
    '''              onPressed: () {
                final error = OrderService.finalizeDirectOrders(context.read<FirebaseFirestore>(), user);''',
    '''              onPressed: () async {
                final error = await OrderService.finalizeDirectOrders(context.read<FirebaseFirestore>(), user);'''
  );

  content = content.replaceAll(
    '''                          onPressed: () {
                            OrderService.archiveDirectOrderBatch(context.read<FirebaseFirestore>(), user, e.key);''',
    '''                          onPressed: () async {
                            await OrderService.archiveDirectOrderBatch(context.read<FirebaseFirestore>(), user, e.key);'''
  );

  file.writeAsStringSync(content);
}
