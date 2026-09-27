import 'dart:io';

void main() {
  final file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  // 1. Remove manual unbatched loading from _loadData
  final loadDataOld = '''        if (_activeStore != null) {
          _storeItems = await StoreService.getStoreItems(firestore, _activeStore!.id);
          
          final allOrders = await OrderService.getAllOrders(firestore);
          _unbatchedOrders = allOrders.where((o) => o.teamStoreId == _activeStore!.id && o.batchId == null && !o.isArchived).toList();
        } else {
          _storeItems = [];
          _unbatchedOrders = [];
        }''';
  final loadDataNew = '''        if (_activeStore != null) {
          _storeItems = await StoreService.getStoreItems(firestore, _activeStore!.id);
        } else {
          _storeItems = [];
        }''';
  content = content.replaceFirst(loadDataOld, loadDataNew);
  
  // 2. Refactor _buildOrdersTab to use StreamBuilder
  final buildOrdersOld = '''  Widget _buildOrdersTab() {
    if (_activeStore == null) return _buildPlaceholderTab('Orders');
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Current Unbatched Orders', style: Theme.of(context).textTheme.titleLarge),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/coach/direct-order').then((_) => _loadData());
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              child: const Text('NEW DIRECT ORDER'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_unbatchedOrders.isEmpty)
          const GlassPanel(child: Padding(padding: EdgeInsets.all(16.0), child: Text('No unbatched orders found for this store.')))
        else
          ..._unbatchedOrders.map((order) {''';

  final buildOrdersNew = '''  Widget _buildOrdersTab() {
    if (_activeStore == null) return _buildPlaceholderTab('Orders');
    
    return StreamBuilder<List<ParentOrder>>(
      stream: OrderService.getUnbatchedOrdersForStoreStream(context.read<FirebaseFirestore>(), _activeStore!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Filter out archived just in case
        final unbatchedOrders = (snapshot.data ?? []).where((o) => !o.isArchived).toList();
        
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Current Unbatched Orders', style: Theme.of(context).textTheme.titleLarge),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/coach/direct-order').then((_) => _loadData());
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                  child: const Text('NEW DIRECT ORDER'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (unbatchedOrders.isEmpty)
              const GlassPanel(child: Padding(padding: EdgeInsets.all(16.0), child: Text('No unbatched orders found for this store.')))
            else
              ...unbatchedOrders.map((order) {''';
              
  content = content.replaceFirst(buildOrdersOld, buildOrdersNew);
  
  // Need to fix the closing braces for StreamBuilder in _buildOrdersTab.
  // The original ended with `        const SizedBox(height: 32), ...`
  // I need to add `      }\n    );` at the end of `_buildOrdersTab`.
  final endTabOld = '''        const SizedBox(height: 32),
      ],
    );
  }''';
  final endTabNew = '''        const SizedBox(height: 32),
          ],
        );
      }
    );
  }''';
  content = content.replaceFirst(endTabOld, endTabNew);
  
  file.writeAsStringSync(content);
}
