import 'dart:io';
void main() {
  var c = File('lib/screens/coach/coach_dashboard_screen.dart').readAsStringSync();

  c = c.replaceAll(
    """  void _approvePricing() {
    setState(() {
      _activeStore = _activeStore!.copyWith(pricingApproved: true);
    });
  }""",
    """  Future<void> _approvePricing() async {
    await StoreService.updateStore(context.read<FirebaseFirestore>(), _activeStore!.copyWith(pricingApproved: true));
    await _loadData();
  }"""
  );

  c = c.replaceAll(
    """  void _addStoreItem(DesignCatalog design) {
    setState(() {
      _storeItems.add(StoreItem(
        id: 'item-\${Random().nextInt(1000)}',
        teamStoreId: _activeStore!.id,
        designCatalogId: design.id,
        name: design.name,
        types: const ['Jersey', 'Shorts'], // Demo default
        imagePaths: design.primaryImagePath != null ? [design.primaryImagePath!] : const [],
        wholesalePrice: design.wholesalePrice ?? 0,
        retailPrice: (design.wholesalePrice ?? 0) + 10.0,
        sortOrder: _storeItems.length,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    });
  }""",
    """  Future<void> _addStoreItem(DesignCatalog design) async {
    await StoreService.createStoreItem(context.read<FirebaseFirestore>(), StoreItem(
      id: 'item-\${DateTime.now().millisecondsSinceEpoch}',
      teamStoreId: _activeStore!.id,
      designCatalogId: design.id,
      name: design.name,
      types: const ['Jersey', 'Shorts'],
      imagePaths: design.primaryImagePath != null ? [design.primaryImagePath!] : const [],
      wholesalePrice: design.wholesalePrice ?? 0,
      retailPrice: (design.wholesalePrice ?? 0) + 10.0,
      sortOrder: _storeItems.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    await _loadData();
  }"""
  );

  c = c.replaceAll(
    """  void _updateItemMarkup(StoreItem item, double retailPrice) {
    if (retailPrice < item.wholesalePrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Retail price cannot be less than wholesale price.')),
      );
      return;
    }
    setState(() {
      final idx = _storeItems.indexWhere((i) => i.id == item.id);
      if (idx != -1) {
        _storeItems[idx] = _storeItems[idx].copyWith(retailPrice: retailPrice);
      }
    });
  }""",
    """  Future<void> _updateItemMarkup(StoreItem item, double retailPrice) async {
    if (retailPrice < item.wholesalePrice) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Retail price cannot be less than wholesale price.')),
      );
      return;
    }
    await StoreService.updateStoreItem(context.read<FirebaseFirestore>(), item.copyWith(retailPrice: retailPrice));
    await _loadData();
  }"""
  );

  c = c.replaceAll(
    """  void _removeStoreItem(String itemId) {
    setState(() {
      _storeItems.removeWhere((i) => i.id == itemId);
    });
  }""",
    """  Future<void> _removeStoreItem(String itemId) async {
    await StoreService.deleteStoreItem(context.read<FirebaseFirestore>(), itemId);
    await _loadData();
  }"""
  );

  c = c.replaceAll(
    """  void _bulkMarkup(double amount) {
    setState(() {
      for (var i = 0; i < _storeItems.length; i++) {
        _storeItems[i] = _storeItems[i].copyWith(retailPrice: _storeItems[i].retailPrice + amount);
      }
    });
  }""",
    """  Future<void> _bulkMarkup(double amount) async {
    for (var i = 0; i < _storeItems.length; i++) {
      await StoreService.updateStoreItem(context.read<FirebaseFirestore>(), _storeItems[i].copyWith(retailPrice: _storeItems[i].retailPrice + amount));
    }
    await _loadData();
  }"""
  );
  
  c = c.replaceAll(
    """  void _submitMasterOrder() {
    if (_activeStore == null || _unbatchedOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot submit an empty roster.')),
      );
      return;
    }

    setState(() {
      _activeStore = _activeStore!.copyWith(status: 'submitted_to_admin');
      for (var i = 0; i < _unbatchedOrders.length; i++) {
        _unbatchedOrders[i] = _unbatchedOrders[i].copyWith(status: 'Processing');
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Master order submitted successfully!')),
    );
  }""",
    """  Future<void> _submitMasterOrder() async {
    if (_activeStore == null || _unbatchedOrders.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
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
  }"""
  );

  File('lib/screens/coach/coach_dashboard_screen.dart').writeAsStringSync(c);
}
