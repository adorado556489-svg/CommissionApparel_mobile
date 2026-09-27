import 'dart:io';

void main() {
  var file = File('lib/screens/admin/admin_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    "final batchId = entry.key;\n            final orders = entry.value;\n            final storeId = orders.first.teamStoreId;\n            final stores = snapshot.data![1] as List<TeamStore>;\n            final store = stores.firstWhere",
    "final batchId = entry.key;\n            final orders = entry.value;\n            final storeId = orders.first.teamStoreId;\n            final store = (snapshot.data![1] as List<TeamStore>).firstWhere"
  );
  file.writeAsStringSync(content);
}
