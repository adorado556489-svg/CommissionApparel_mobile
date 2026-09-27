import 'dart:io';

void main() {
  final file = File('lib/screens/admin/admin_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  final buildIdx = content.indexOf('Widget build(BuildContext context) {');
  final afterBuildIdx = content.indexOf('return AppScaffold(', buildIdx);
  
  if (buildIdx != -1 && afterBuildIdx != -1) {
    final beforeBuild = content.substring(0, buildIdx);
    final afterBuild = content.substring(afterBuildIdx);
    
    final newBuild = '''Future<List<dynamic>>? _dashboardFuture;

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
            for (final order in submittedOrders) {
              if (order.status == 'Submitted to Admin' && order.batchId != null) {
                submittedBatches.putIfAbsent(order.batchId!, () => []).add(order);
              }
            }
  
          ''';
    
    content = beforeBuild + newBuild + afterBuild;
    
    // Add the extra missing closing braces
    // At the end of the file, we have:
    //       );
    //     }
    //   );
    // }
    content = content.replaceFirst(
      '          );\n        }\n      );\n    }\n',
      '          );\n        }\n      );\n      }\n    );\n  }\n'
    );
    
    // And replace setState(() {}); with _loadDashboardData(); setState(() {});
    content = content.replaceAll('setState(() {});', '_loadDashboardData();\n      setState(() {});');
    file.writeAsStringSync(content);
  } else {
    print('Failed to find indices');
  }
}
