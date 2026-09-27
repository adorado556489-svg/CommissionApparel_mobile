import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll(RegExp(r"Future<void> _setDeadline\(\) async \{[\s\S]+?\}\r?\n  \}"),
"""  Future<void> _setDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _activeStore?.orderDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      final firestore = context.read<FirebaseFirestore>();
      await StoreService.updateStore(firestore, _activeStore!.copyWith(orderDeadline: picked));
      await _loadData();
    }
  }""");

  content = content.replaceAll(RegExp(r"void _submitMasterOrder\(\) \{[\s\S]+?\}\r?\n  \}"),
"""  Future<void> _submitMasterOrder() async {
    if (_activeStore == null || _unbatchedOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot submit an empty roster.')),
      );
      return;
    }

    final firestore = context.read<FirebaseFirestore>();
    final user = context.read<AuthService>().currentUser!;
    final batchId = 'batch-\${DateTime.now().millisecondsSinceEpoch}';
    
    await OrderService.submitStoreOrdersToAdmin(firestore, user, _activeStore!.id, batchId);
    await _loadData();
    
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Master order submitted successfully!')),
    );
  }""");
  
  content = content.replaceAll(RegExp(r"void _approvePricing\(\) \{[\s\S]+?\}\r?\n  \}"),
"""  Future<void> _approvePricing() async {
    if (_activeStore == null) return;
    final firestore = context.read<FirebaseFirestore>();
    await StoreService.updateStore(firestore, _activeStore!.copyWith(pricingApproved: true));
    await _loadData();
  }""");

  content = content.replaceAll(RegExp(r"void _bulkMarkup\(double additionalAmount\) \{[\s\S]+?\}\r?\n  \}"),
"""  Future<void> _bulkMarkup(double additionalAmount) async {
    final firestore = context.read<FirebaseFirestore>();
    for (var item in _storeItems) {
      final newRetail = item.retailPrice + additionalAmount;
      if (newRetail >= item.wholesalePrice) {
        await StoreService.updateStoreItem(firestore, item.copyWith(retailPrice: newRetail));
      }
    }
    await _loadData();
  }""");
  
  content = content.replaceAll(RegExp(r"void _updateItemMarkup\(StoreItem item, double newRetail\) \{[\s\S]+?\}\r?\n  \}"),
"""  Future<void> _updateItemMarkup(StoreItem item, double newRetail) async {
    if (newRetail < item.wholesalePrice) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Retail price cannot be less than wholesale price.')),
      );
      return;
    }
    final firestore = context.read<FirebaseFirestore>();
    await StoreService.updateStoreItem(firestore, item.copyWith(retailPrice: newRetail));
    await _loadData();
  }""");

  content = content.replaceAll(RegExp(r"void _removeStoreItem\(String itemId\) \{[\s\S]+?\}\r?\n  \}"),
"""  Future<void> _removeStoreItem(String itemId) async {
    final firestore = context.read<FirebaseFirestore>();
    await StoreService.deleteStoreItem(firestore, itemId);
    await _loadData();
  }""");
  
  file.writeAsStringSync(content);
}
