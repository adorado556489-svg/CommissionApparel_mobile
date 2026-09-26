import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();

  content = content.replaceAll(
      "import '../../data/dummy_orders.dart';",
      "import '../../services/order_service.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport '../../services/store_service.dart';");

  content = content.replaceAll(
      '''  Future<void> _submitMasterOrder() async {
    if (_activeStore == null || _unbatchedOrders.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Master Order?'),
        content: const Text('This will finalize all pending orders and submit them to Commission Apparel for processing. The store will be locked.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('SUBMIT')),
        ],
      ),
    );

    if (confirm == true) {
      final batchId = 'batch-\';
  
      final updatedStore = _activeStore!.copyWith(status: 'submitted_to_admin');
      // In real app, this updates DB. Here we just update local state.
      
      for (var order in _unbatchedOrders) {
        final idx = dummyParentOrders.indexWhere((o) => o.id == order.id);
        if (idx != -1) {
          dummyParentOrders[idx] = order.copyWith(
            status: 'Submitted to Admin',
            batchId: batchId,
            updatedAt: DateTime.now(),
          );
        }
      }
      
      if (mounted) {
        setState(() {
          _activeStore = updatedStore;
          _unbatchedOrders = dummyParentOrders.where((o) => o.teamStoreId == _activeStore!.id && o.batchId == null).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Master order submitted successfully!')),
        );
      }
    }
  }''',
      '''  Future<void> _submitMasterOrder() async {
    if (_activeStore == null || _unbatchedOrders.isEmpty) return;
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Submit Master Order?'),
      content: const Text('This will finalize all pending orders and submit them to Commission Apparel for processing. The store will be locked.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('SUBMIT')),
      ],
    ));
    if (confirm == true) {
      final firestore = context.read<FirebaseFirestore>();
      final batchId = 'batch-\';
      final updatedStore = _activeStore!.copyWith(status: 'submitted_to_admin');
      await StoreService.updateStore(firestore, updatedStore);
      await OrderService.submitStoreOrdersToAdmin(firestore, context.read<AuthService>().currentUser!, _activeStore!.id, batchId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Master order submitted successfully!')));
      }
    }
  }''');

  content = content.replaceAll(
      '''  Widget _buildDirectOrdersTab() {
    final user = context.watch<AuthService>().currentUser!;
    final draftOrders = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == user.id && o.status == 'Draft').toList();
    final batchedOrders = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == user.id && o.batchId != null && !o.isArchived).toList();''',
      '''  Widget _buildDirectOrdersTab() {
    final user = context.watch<AuthService>().currentUser!;
    return FutureBuilder<List<ParentOrder>>(
      future: OrderService.getAllOrders(context.read<FirebaseFirestore>()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final allOrders = snapshot.data!;
        final draftOrders = allOrders.where((o) => o.teamStoreId == null && o.userId == user.id && o.status == 'Draft').toList();
        final batchedOrders = allOrders.where((o) => o.teamStoreId == null && o.userId == user.id && o.batchId != null && !o.isArchived).toList();''');

  content = content.replaceAll(
      '''                  final error = OrderService.finalizeDirectOrders(user);
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your direct orders have been submitted to The Commission Apparel!')));
                    setState(() {});
                  }''',
      '''                  OrderService.finalizeDirectOrders(context.read<FirebaseFirestore>(), user).then((error) {
                    if (error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your direct orders have been submitted to The Commission Apparel!')));
                      setState(() {});
                    }
                  });''');

  content = content.replaceAll(
      '''                          onPressed: () {
                            OrderService.archiveDirectOrderBatch(user, e.key);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Batch has been archived successfully.'))
                            );
                          },''',
      '''                          onPressed: () {
                            OrderService.archiveDirectOrderBatch(context.read<FirebaseFirestore>(), user, e.key).then((_) {
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Batch has been archived successfully.'))
                              );
                            });
                          },''');

  content = content.replaceAll(
      '''        ],
      );
    }''',
      '''        ],
      );
      }
    );
  }''');

  file.writeAsStringSync(content);
}
