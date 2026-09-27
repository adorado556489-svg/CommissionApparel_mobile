import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  
  // Let's manually replace all the dummy variables with Firebase calls
  content = content.replaceAll(RegExp(r"void _loadData\(\) \{[\s\S]+?setState\(\(\) \{\}\);\r?\n  \}"),
"""  Future<void> _loadData() async {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;

    final firestore = context.read<FirebaseFirestore>();

    try {
      _activeStore = await StoreService.getActiveStoreForCoach(firestore, user.id);
    } catch (_) {
      _activeStore = null;
    }

    if (_activeStore != null) {
      _storeItems = await StoreService.getStoreItems(firestore, _activeStore!.id);
      _unbatchedOrders = await OrderService.getUnbatchedOrdersForStore(firestore, _activeStore!.id);
    } else {
      _storeItems = [];
      _unbatchedOrders = [];
    }

    _assignedDesigns = await CatalogService.getAllDesignCatalog(firestore);
    
    if (mounted) setState(() {});
  }""");

  content = content.replaceAll(RegExp(r"void _createStore\(String name, String desc, String packageType\) \{[\s\S]+?_activeStore = newStore;\r?\n    \}\);\r?\n  \}"),
"""  Future<void> _createStore(String name, String desc, String packageType) async {
    final user = context.read<AuthService>().currentUser;
    if (user == null || _activeStore != null) return;

    final newStore = TeamStore(
      id: 'store-\${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      name: name,
      slug: TeamStore.generateSlug(name),
      description: desc,
      packageType: packageType,
      status: 'pending',
      pricingApproved: false,
      isArchived: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await StoreService.createStore(context.read<FirebaseFirestore>(), newStore);
    await _loadData();
  }""");

  content = content.replaceAll(RegExp(r"void _submitMasterOrder\(\) \{[\s\S]+?\}\);\r?\n  \}"),
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
  
  content = content.replaceAll(RegExp(r"void _approvePricing\(\) \{[\s\S]+?\}\);\r?\n  \}"),
"""  Future<void> _approvePricing() async {
    final firestore = context.read<FirebaseFirestore>();
    await StoreService.updateStore(firestore, _activeStore!.copyWith(pricingApproved: true));
    await _loadData();
  }""");

  content = content.replaceAll(RegExp(r"void _bulkMarkup\(double amount\) \{[\s\S]+?\}\);\r?\n  \}"),
"""  Future<void> _bulkMarkup(double amount) async {
    final firestore = context.read<FirebaseFirestore>();
    for (var i = 0; i < _storeItems.length; i++) {
      await StoreService.updateStoreItem(firestore, _storeItems[i].copyWith(retailPrice: _storeItems[i].retailPrice + amount));
    }
    await _loadData();
  }""");
  
  content = content.replaceAll(RegExp(r"void _addStoreItem\(DesignCatalog design\) \{[\s\S]+?\}\);\r?\n  \}"),
"""  Future<void> _addStoreItem(DesignCatalog design) async {
    final firestore = context.read<FirebaseFirestore>();
    final newItem = StoreItem(
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
    );
    await StoreService.createStoreItem(firestore, newItem);
    await _loadData();
  }""");

  content = content.replaceAll(RegExp(r"void _updateItemMarkup\(StoreItem item, double retailPrice\) \{[\s\S]+?\}\);\r?\n  \}"),
"""  Future<void> _updateItemMarkup(StoreItem item, double retailPrice) async {
    if (retailPrice < item.wholesalePrice) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Retail price cannot be less than wholesale price.')),
      );
      return;
    }
    final firestore = context.read<FirebaseFirestore>();
    await StoreService.updateStoreItem(firestore, item.copyWith(retailPrice: retailPrice));
    await _loadData();
  }""");

  content = content.replaceAll(RegExp(r"void _removeStoreItem\(String itemId\) \{[\s\S]+?\}\);\r?\n  \}"),
"""  Future<void> _removeStoreItem(String itemId) async {
    final firestore = context.read<FirebaseFirestore>();
    await StoreService.deleteStoreItem(firestore, itemId);
    await _loadData();
  }""");

  content = content.replaceAll(RegExp(r"void _setDeadline\(\) async \{[\s\S]+?\}\);\r?\n    \}\r?\n  \}"),
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
  
  content = content.replaceAll(RegExp(r"Future<void> _pickCoverImage\(\) async \{[\s\S]+?\}\r?\n    \} catch \(_\) \{\}\r?\n  \}"),
"""  Future<void> _pickCoverImage() async {
    if (_activeStore == null) return;
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final firestore = context.read<FirebaseFirestore>();
        await StoreService.updateStore(firestore, _activeStore!.copyWith(coverImagePath: pickedFile.path));
        await _loadData();
      }
    } catch (_) {}
  }""");

  file.writeAsStringSync(content);
}
