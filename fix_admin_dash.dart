import 'dart:io';

void main() {
  var file = File('lib/screens/admin/admin_dashboard_screen.dart');
  var content = file.readAsStringSync();

  content = content.replaceAll(
      "import '../../data/dummy_orders.dart';",
      "import '../../services/order_service.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport '../../services/admin_service.dart';");

  content = content.replaceAll(
      '''  void _markBatchAddressed(String batchId) {
    setState(() {
      for (int i = 0; i < dummyParentOrders.length; i++) {
        if (dummyParentOrders[i].batchId == batchId) {
          dummyParentOrders[i] = dummyParentOrders[i].copyWith(
            status: 'Processing',
            isArchived: true,
          );
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Master Order Batch marked as addressed and archived.')),
    );
  }''',
      '''  Future<void> _markBatchAddressed(String batchId, bool isDirect) async {
    final admin = context.read<AuthService>().currentUser!;
    if (isDirect) {
      await AdminService.markDirectBatchAddressed(context.read<FirebaseFirestore>(), admin, batchId);
    } else {
      await AdminService.markStoreBatchAddressed(context.read<FirebaseFirestore>(), admin, batchId);
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Master Order Batch marked as addressed and archived.')),
    );
  }''');

  content = content.replaceAll(
      '''    // Find unique submitted batches
    final submittedBatches = <String, List<ParentOrder>>{};
    for (final order in dummyParentOrders) {
      if (order.status == 'Submitted to Admin' && order.batchId != null) {
        submittedBatches.putIfAbsent(order.batchId!, () => []).add(order);
      }
    }

    return AppScaffold(
      title: 'Admin Dashboard',
      currentNavIndex: 1,
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textMuted,
            indicatorColor: AppTheme.primary,
            tabs: const [
              Tab(text: 'STORES & ORDERS'),
              Tab(text: 'CAMPAIGN STORES'),
                Tab(text: 'COLLECTIONS'),
                Tab(text: 'CATALOG'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStoresAndOrdersTab(pendingStores, submittedBatches),
                _buildCampaignStoresTab(campaignStores),
                  const AdminCollectionsTab(),
                  const AdminCatalogTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }''',
      '''    return FutureBuilder<List<ParentOrder>>(
      future: OrderService.getAllOrders(context.read<FirebaseFirestore>()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final allOrders = snapshot.data!;
        final submittedBatches = <String, List<ParentOrder>>{};
        for (final order in allOrders) {
          if (order.status == 'Submitted to Admin' && order.batchId != null) {
            submittedBatches.putIfAbsent(order.batchId!, () => []).add(order);
          }
        }

        return AppScaffold(
          title: 'Admin Dashboard',
          currentNavIndex: 1,
          body: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.textMuted,
                indicatorColor: AppTheme.primary,
                tabs: const [
                  Tab(text: 'STORES & ORDERS'),
                  Tab(text: 'CAMPAIGN STORES'),
                    Tab(text: 'COLLECTIONS'),
                    Tab(text: 'CATALOG'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStoresAndOrdersTab(pendingStores, submittedBatches),
                    _buildCampaignStoresTab(campaignStores),
                      const AdminCollectionsTab(),
                      const AdminCatalogTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }''');

  content = content.replaceAll(
      "onPressed: () => _markBatchAddressed(batchId),",
      "onPressed: () => _markBatchAddressed(batchId, orders.first.teamStoreId == null),");
      
  file.writeAsStringSync(content);
}
