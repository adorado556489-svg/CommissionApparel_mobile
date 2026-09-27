import 'dart:io';

String refactorDashboard(String content) {
  content = content.replaceAll(
    'StoreService.getCampaignStores(context.read<FirebaseFirestore>()),',
    '''StoreService.getCampaignStores(context.read<FirebaseFirestore>()),
        StoreService.getActiveStores(context.read<FirebaseFirestore>()),'''
  );
  
  content = content.replaceAll(
    'final campaignStores = snapshot.data![2] as List<TeamStore>;',
    '''final campaignStores = snapshot.data![2] as List<TeamStore>;
        final activeStores = snapshot.data![3] as List<TeamStore>;'''
  );
  
  content = content.replaceAll(
    '_buildStoresAndOrdersTab(pendingStores, submittedBatches),',
    '_buildStoresAndOrdersTab(pendingStores, submittedBatches, activeStores),'
  );
  
  content = content.replaceAll(
    'Widget _buildStoresAndOrdersTab(List<TeamStore> pendingStores, Map<String, List<ParentOrder>> submittedBatches) {',
    'Widget _buildStoresAndOrdersTab(List<TeamStore> pendingStores, Map<String, List<ParentOrder>> submittedBatches, List<TeamStore> activeStores) {'
  );

  content = content.replaceAll(
    '''final storeId = orders.first.teamStoreId;
            final store = dummyTeamStores.firstWhere((s) => s.id == storeId, orElse: () => TeamStore(
              id: '', userId: '', name: 'Unknown', slug: '', createdAt: DateTime.now(), updatedAt: DateTime.now()
            ));''',
    '''final storeId = orders.first.teamStoreId;
            final store = activeStores.firstWhere((s) => s.id == storeId, orElse: () => TeamStore(
              id: storeId ?? '', userId: '', name: storeId == null ? 'Direct Order' : 'Unknown Store', slug: '', createdAt: DateTime.now(), updatedAt: DateTime.now()
            ));'''
  );

  return content;
}

void main() {
  final file = File('lib/screens/admin/admin_dashboard_screen.dart');
  file.writeAsStringSync(refactorDashboard(file.readAsStringSync()));
}
