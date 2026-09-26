import re

with open('lib/screens/coach/coach_dashboard_screen.dart', 'r') as f:
    code = f.read()

# Replace _pickCoverImage
code = re.sub(r'  Future<void> _pickCoverImage\(\) async \{.*?    \} catch \(\_\) \{\}\n  \}', '''  Future<void> _pickCoverImage() async {
    if (_activeStore == null) return;
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final updated = _activeStore!.copyWith(coverImagePath: pickedFile.path);
        await StoreService.updateStore(context.read<FirebaseFirestore>(), updated);
        if (mounted) {
          setState(() {
            _activeStore = updated;
          });
        }
      }
    } catch (_) {}
  }''', code, flags=re.DOTALL)

# Replace _setDeadline
code = re.sub(r'  Future<void> _setDeadline\(\) async \{.*?      \}\);\n    \}\n  \}', '''  Future<void> _setDeadline() async {
    if (_activeStore == null) return;
    final date = await showDatePicker(
      context: context,
      initialDate: _activeStore!.orderDeadline ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      final updated = _activeStore!.copyWith(orderDeadline: date);
      await StoreService.updateStore(context.read<FirebaseFirestore>(), updated);
      if (mounted) {
        setState(() {
          _activeStore = updated;
        });
      }
    }
  }''', code, flags=re.DOTALL)

# Replace _addStoreItem
code = re.sub(r'  void _addStoreItem\(DesignCatalog design\) \{.*?      _storeItems\.add\(newItem\);\n    \}\);\n  \}', '''  Future<void> _addStoreItem(DesignCatalog design) async {
    if (_activeStore == null) return;
    final newItem = StoreItem(
      id: 'item-',
      teamStoreId: _activeStore!.id,
      designCatalogId: design.id,
      name: design.name,
      types: design.types,
      imagePaths: design.imagePaths,
      wholesalePrice: design.wholesalePrice ?? 20.0,
      retailPrice: design.wholesalePrice ?? 20.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      sortOrder: 0,
      componentIds: const [],
    );
    
    await StoreService.createStoreItem(context.read<FirebaseFirestore>(), newItem);
    
    if (mounted) {
      setState(() {
        _storeItems.add(newItem);
      });
    }
  }''', code, flags=re.DOTALL)

# Replace _removeStoreItem
code = re.sub(r'  void _removeStoreItem\(String itemId\) \{.*?    \}\);\n  \}', '''  Future<void> _removeStoreItem(String itemId) async {
    await StoreService.deleteStoreItem(context.read<FirebaseFirestore>(), itemId);
    if (mounted) {
      setState(() {
        _storeItems.removeWhere((i) => i.id == itemId);
      });
    }
  }''', code, flags=re.DOTALL)

# Replace _updateItemMarkup
code = re.sub(r'  void _updateItemMarkup\(StoreItem item, double newRetail\) \{.*?    \}\);\n  \}', '''  Future<void> _updateItemMarkup(StoreItem item, double newRetail) async {
    if (newRetail < item.wholesalePrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Retail price cannot be less than wholesale price.')),
      );
      return;
    }
    
    final updated = item.copyWith(retailPrice: newRetail);
    await StoreService.updateStoreItem(context.read<FirebaseFirestore>(), updated);
    
    if (mounted) {
      setState(() {
        final idxLocal = _storeItems.indexWhere((i) => i.id == item.id);
        if (idxLocal != -1) _storeItems[idxLocal] = updated;
      });
    }
  }''', code, flags=re.DOTALL)

# Replace _bulkMarkup
code = re.sub(r'  void _bulkMarkup\(double additionalAmount\) \{.*?  \}', '''  Future<void> _bulkMarkup(double additionalAmount) async {
    for (var item in _storeItems) {
      await _updateItemMarkup(item, item.retailPrice + additionalAmount);
    }
  }''', code, flags=re.DOTALL)

# Replace _approvePricing
code = re.sub(r'  void _approvePricing\(\) \{.*?    \}\);\n  \}', '''  Future<void> _approvePricing() async {
    if (_activeStore == null) return;
    final updated = _activeStore!.copyWith(pricingApproved: true);
    await StoreService.updateStore(context.read<FirebaseFirestore>(), updated);
    
    if (mounted) {
      setState(() {
        _activeStore = updated;
      });
    }
  }''', code, flags=re.DOTALL)

# Replace _submitMasterOrder
code = re.sub(r'  void _submitMasterOrder\(\) \{.*?      _unbatchedOrders = dummyParentOrders\.where\(\(o\) => o\.teamStoreId == _activeStore!\.id && o\.batchId == null\)\.toList\(\);\n    \}\);\n    \n  \}', '''  Future<void> _submitMasterOrder() async {
    if (_activeStore == null || _unbatchedOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot submit an empty roster.')),
      );
      return;
    }

    final batchId = 'batch-';

    final updatedStore = _activeStore!.copyWith(status: 'submitted_to_admin');
    await StoreService.updateStore(context.read<FirebaseFirestore>(), updatedStore);
    
    // Fallback for orders (OrderService will be migrated later)
    for (var order in _unbatchedOrders) {
      final idx = dummyParentOrders.indexWhere((o) => o.id == order.id);
      if (idx != -1) {
        dummyParentOrders[idx] = order.copyWith(
          status: 'Submitted to Admin',
          batchId: batchId,
        );
      }
    }
    
    if (mounted) {
      setState(() {
        _activeStore = updatedStore;
        _unbatchedOrders = dummyParentOrders.where((o) => o.teamStoreId == _activeStore!.id && o.batchId == null).toList();
      });
    }
  }''', code, flags=re.DOTALL)

with open('lib/screens/coach/coach_dashboard_screen.dart', 'w') as f:
    f.write(code)
