import 'dart:io';

void main() {
  var adminFile = File('lib/screens/admin/admin_dashboard_screen.dart');
  var adminContent = adminFile.readAsStringSync();
  adminContent = adminContent.replaceAll(
    "_buildStoresAndOrdersTab(pendingStores, submittedBatches),",
    "_buildStoresAndOrdersTab(pendingStores, submittedBatches, campaignStores),"
  );
  adminContent = adminContent.replaceAll(
    "Widget _buildStoresAndOrdersTab(List<TeamStore> pendingStores, Map<String, List<ParentOrder>> submittedBatches) {",
    "Widget _buildStoresAndOrdersTab(List<TeamStore> pendingStores, Map<String, List<ParentOrder>> submittedBatches, List<TeamStore> campaignStores) {"
  );
  adminContent = adminContent.replaceAll(
    "final stores = snapshot.data![1] as List<TeamStore>;",
    "final stores = campaignStores;"
  );
  adminFile.writeAsStringSync(adminContent);
}
