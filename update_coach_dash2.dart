import 'dart:io';

void main() {
  final file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  // 1. Remove getAllOrders from _loadData
  content = content.replaceFirst(
    '''      if (_activeStore != null) {
        _storeItems = await StoreService.getStoreItems(firestore, _activeStore!.id);
        
        final allOrders = await OrderService.getAllOrders(firestore);
        _unbatchedOrders = allOrders.where((o) => o.teamStoreId == _activeStore!.id && o.batchId == null && !o.isArchived).toList();
      } else {''',
    '''      if (_activeStore != null) {
        _storeItems = await StoreService.getStoreItems(firestore, _activeStore!.id);
      } else {'''
  );

  // 2. Rewrite _buildOrdersTab using StreamBuilder
  final buildOrdersStart = content.indexOf('  Widget _buildOrdersTab() {');
  final buildOrdersEnd = content.indexOf('  Widget _buildDirectOrdersTab() {');
  
  if (buildOrdersStart != -1 && buildOrdersEnd != -1) {
    final before = content.substring(0, buildOrdersStart);
    final after = content.substring(buildOrdersEnd);
    
    final newOrdersTab = '''  Widget _buildOrdersTab() {
    if (_activeStore == null) return _buildPlaceholderTab('Orders');
    
    return StreamBuilder<List<ParentOrder>>(
      stream: OrderService.getUnbatchedOrdersForStoreStream(context.read<FirebaseFirestore>(), _activeStore!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
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
              ...unbatchedOrders.map((order) {
                return GlassPanel(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('\${order.athleteFirstName} \${order.athleteLastName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Order: \${order.id}', style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 4),
                          Badge(
                            label: Text(order.status),
                            backgroundColor: order.status == 'Draft' ? Colors.grey : AppTheme.primary,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('\$ \${order.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppTheme.primary),
                            onPressed: () {
                              Navigator.pushNamed(context, '/coach/order/\${order.id}').then((_) => _loadData());
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 32),
          ],
        );
      }
    );
  }

''';
    content = before + newOrdersTab + after;
  }
  
  // 3. Fix _buildDirectOrdersTab to use getDirectOrdersForCoach
  content = content.replaceFirst(
    '''    return FutureBuilder<List<ParentOrder>>(
      future: OrderService.getAllOrders(context.read<FirebaseFirestore>()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final allOrders = snapshot.data!;
        final directOrders = allOrders.where((o) => o.teamStoreId == null && o.userId == user.id && !o.isArchived).toList();''',
    '''    return FutureBuilder<List<ParentOrder>>(
      future: OrderService.getDirectOrdersForCoach(context.read<FirebaseFirestore>(), user.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final allOrders = snapshot.data!;
        final directOrders = allOrders.where((o) => !o.isArchived).toList();'''
  );

  file.writeAsStringSync(content);
}
