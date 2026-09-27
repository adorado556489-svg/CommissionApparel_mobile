import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll(
    """  void _loadData() {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;

    // Find active store
    try {
      _activeStore = dummyTeamStores.firstWhere(
        (s) => s.userId == user.id && !s.isArchived,
      );
    } catch (_) {
      _activeStore = null;
    }

    if (_activeStore != null) {
      _storeItems = dummyStoreItems.where((i) => i.teamStoreId == _activeStore!.id).toList();
      _unbatchedOrders = dummyParentOrders.where((o) => o.teamStoreId == _activeStore!.id && o.batchId == null).toList();
    } else {
      _storeItems = [];
      _unbatchedOrders = [];
    }

    // Assume first 3 are assigned to coach
    _assignedDesigns = dummyDesignCatalog.where((d) => user.assignedDesignIds.contains(d.id)).toList();
    
    setState(() {});
  }""",
    """  Future<void> _loadData() async {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;
    
    final firestore = context.read<FirebaseFirestore>();
    _activeStore = await StoreService.getActiveStoreForCoach(firestore, user.id);
    if (_activeStore != null) {
      _storeItems = await StoreService.getStoreItems(firestore, _activeStore!.id);
      _unbatchedOrders = await OrderService.getUnbatchedOrdersForStore(firestore, _activeStore!.id);
    } else {
      _storeItems = [];
      _unbatchedOrders = [];
    }
    _assignedDesigns = await CatalogService.getAllDesignCatalog(firestore);
    if (mounted) setState(() {});
  }"""
  );
  file.writeAsStringSync(content);
}
