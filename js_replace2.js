const fs = require('fs');
let code = fs.readFileSync('lib/screens/admin/admin_dashboard_screen.dart', 'utf8');

const r1 = `  Future<void> _markBatchAddressed(String batchId, bool isDirect) async {
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
  }`;

code = code.replace(/  void _markBatchAddressed\(String batchId\) \{[\s\S]*?const SnackBar\(content: Text\('Master Order Batch marked as addressed and archived\.'\)\),\n    \);\n  \}/, r1);

const r2 = `    return FutureBuilder<List<ParentOrder>>(
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
  }`;

code = code.replace(/    \/\/ Find unique submitted batches\n    final submittedBatches = <String, List<ParentOrder>>\{\};\n    for \(final order in dummyParentOrders\) \{[\s\S]*?const AdminCatalogTab\(\),\n              \],\n            \),\n          \),\n        \],\n      \),\n    \);\n  \}/, r2);

fs.writeFileSync('lib/screens/admin/admin_dashboard_screen.dart', code, 'utf8');
console.log("Done");
