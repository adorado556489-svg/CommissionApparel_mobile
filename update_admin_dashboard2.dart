import 'dart:io';

void main() {
  final file = File('lib/screens/admin/admin_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  final oldString = '''  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        OrderService.getAllOrders(context.read<FirebaseFirestore>()),
        StoreService.getPendingStores(context.read<FirebaseFirestore>()),
        StoreService.getCampaignStores(context.read<FirebaseFirestore>()),
        StoreService.getActiveStores(context.read<FirebaseFirestore>()),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final allOrders = snapshot.data![0] as List<ParentOrder>;
        final pendingStores = snapshot.data![1] as List<TeamStore>;
        final campaignStores = snapshot.data![2] as List<TeamStore>;
        final activeStores = snapshot.data![3] as List<TeamStore>;
        
        final submittedBatches = <String, List<ParentOrder>>{};
        for (var o in allOrders) {
          if (o.batchId != null && o.status == 'Submitted') {
            submittedBatches.putIfAbsent(o.batchId!, () => []).add(o);
          }
        }''';

  final newString = '''  Future<List<dynamic>>? _dashboardFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dashboardFuture == null) {
      _loadDashboardData();
    }
  }

  void _loadDashboardData() {
    _dashboardFuture = Future.wait([
      OrderService.getSubmittedOrders(context.read<FirebaseFirestore>()),
      StoreService.getCampaignStores(context.read<FirebaseFirestore>()),
      StoreService.getActiveStores(context.read<FirebaseFirestore>()),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TeamStore>>(
      stream: StoreService.getPendingStoresStream(context.read<FirebaseFirestore>()),
      builder: (context, pendingStoresSnapshot) {
        final pendingStores = pendingStoresSnapshot.data ?? [];
        
        return FutureBuilder<List<dynamic>>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            
            final submittedOrders = snapshot.data![0] as List<ParentOrder>;
            final campaignStores = snapshot.data![1] as List<TeamStore>;
            final activeStores = snapshot.data![2] as List<TeamStore>;
            
            final submittedBatches = <String, List<ParentOrder>>{};
            for (var o in submittedOrders) {
              if (o.batchId != null) {
                submittedBatches.putIfAbsent(o.batchId!, () => []).add(o);
              }
            }''';

  content = content.replaceFirst(oldString, newString);
  
  // also add missing closing braces
  content = content.replaceFirst('          );\n        }\n      );\n    }\n', '          );\n        }\n      );\n      }\n    );\n  }\n');
  
  file.writeAsStringSync(content);
}
