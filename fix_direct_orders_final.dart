import 'dart:io';

void main() {
  final file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  content = content.replaceFirst(
    '''  Widget _buildDirectOrdersTab() {
    final user = context.watch<AuthService>().currentUser!;
    return FutureBuilder<List<ParentOrder>>(
      future: OrderService.getAllOrders(context.read<FirebaseFirestore>()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final allOrders = snapshot.data!;
        final draftOrders = allOrders.where((o) => o.teamStoreId == null && o.userId == user.id && o.status == 'Draft').toList();
        final batchedOrders = allOrders.where((o) => o.teamStoreId == null && o.userId == user.id && o.batchId != null && !o.isArchived).toList();''',
    '''  Widget _buildDirectOrdersTab() {
    final user = context.watch<AuthService>().currentUser!;
    return FutureBuilder<List<ParentOrder>>(
      future: OrderService.getDirectOrdersForCoach(context.read<FirebaseFirestore>(), user.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final allOrders = snapshot.data!;
        final draftOrders = allOrders.where((o) => o.status == 'Draft').toList();
        final batchedOrders = allOrders.where((o) => o.batchId != null && !o.isArchived).toList();'''
  );

  file.writeAsStringSync(content);
}
