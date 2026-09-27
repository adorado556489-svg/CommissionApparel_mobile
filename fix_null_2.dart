import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  
  var newTab = """
  Widget _buildOverviewTab() {
    if (_activeStore == null) {
      return const Center(child: Text('You do not have an active store.'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_activeStore!.name, style: Theme.of(context).textTheme.headlineSmall),
              Text(_activeStore!.isLive ? 'LIVE' : _activeStore!.isLocked ? 'LOCKED' : _activeStore!.status.toUpperCase()),
              if (_activeStore!.status == 'submitted_to_admin') const Text('MASTER ORDER SUBMITTED'),
            ],
          )
        ),
        const SizedBox(height: 24),
        StreamBuilder<List<ParentOrder>>(
          stream: OrderService.getUnbatchedOrdersForStoreStream(context.read<FirebaseFirestore>(), _activeStore!.id),
          builder: (context, snapshot) {
            _unbatchedOrders = snapshot.data ?? _unbatchedOrders;
            return GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Unbatched Orders: \${_unbatchedOrders.length}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _activeStore!.isLocked ? null : _submitMasterOrder,
                    child: const Text('SUBMIT MASTER ORDER'),
                  ),
                ],
              )
            );
          }
        ),
        const SizedBox(height: 24),
        _buildStoreSettingsCard(),
        const SizedBox(height: 24),
        _buildStoreItemsCard(),
      ],
    );
  }
""";

  // Find where _buildOverviewTab is and replace it.
  var start = content.indexOf('Widget _buildOverviewTab() {');
  if (start != -1) {
    var end = content.indexOf('Widget _buildDirectOrdersTab() {');
    content = content.replaceRange(start, end, newTab + "\n  ");
  }
  
  file.writeAsStringSync(content);
}
