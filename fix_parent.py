import os

filepath = r'c:\Users\User\Flutter Projects\commission_apparel_flutter\lib\screens\public\parent_order_form_screen.dart'
with open(filepath, 'r') as f:
    content = f.read()

# Replace imports
old_imports = '''import '../../data/dummy_stores.dart';
import '../../data/dummy_orders.dart';
import '../../models/store_item.dart';'''
new_imports = '''import '../../models/store_item.dart';
import '../../models/team_store.dart';
import '../../services/store_service.dart';'''
content = content.replace(old_imports, new_imports)

# Replace state and initState
old_state = '''  late final dynamic store;
  late final List<StoreItem> storeItems;

  @override
  void initState() {
    super.initState();
    store = dummyTeamStores.firstWhere(
      (s) => s.id == widget.storeId,
      orElse: () => dummyTeamStores.first,
    );
    storeItems = dummyStoreItems.where((i) => i.teamStoreId == store.id).toList();

    // Initialize state for each available item (unselected by default)
    for (final item in storeItems) {
      _itemStates[item.id] = _OrderItemState(item: item);
    }
  }'''
new_state = '''  TeamStore? store;
  List<StoreItem> storeItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final firestore = context.read<FirebaseFirestore>();
    final s = await StoreService.getStoreById(firestore, widget.storeId);
    
    if (s != null) {
      store = s;
      storeItems = await StoreService.getStoreItems(firestore, s.id);

      for (final item in storeItems) {
        _itemStates[item.id] = _OrderItemState(item: item);
      }
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }'''
content = content.replace(old_state, new_state)

# Replace build start
old_build = '''  @override
  Widget build(BuildContext context) {
    if (!store.isAcceptingOrders) {
      return AppScaffold(
        title: 'Store Closed',
        currentNavIndex: 2,
        body: Center(
          child: Text('This store is not accepting orders: '),
        ),
      );
    }'''
new_build = '''  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppScaffold(
        title: 'Loading...',
        currentNavIndex: 2,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (store == null) {
      return const AppScaffold(
        title: 'Store Not Found',
        currentNavIndex: 2,
        body: Center(child: Text('Store not found.')),
      );
    }

    if (!store!.isAcceptingOrders) {
      return AppScaffold(
        title: 'Store Closed',
        currentNavIndex: 2,
        body: Center(
          child: Text('This store is not accepting orders: '),
        ),
      );
    }'''
content = content.replace(old_build, new_build)

with open(filepath, 'w') as f:
    f.write(content)

print('Done')
