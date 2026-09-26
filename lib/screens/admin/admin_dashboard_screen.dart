import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_panel.dart';
import '../../app/theme.dart';
import '../../data/dummy_stores.dart';
import '../../data/dummy_users.dart';
import '../../services/order_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/admin_service.dart';
import '../../models/team_store.dart';
import '../../services/store_service.dart';
import '../../models/parent_order.dart';

import 'widgets/admin_collections_tab.dart';
import 'widgets/admin_catalog_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _approveStore(TeamStore store) async {
    final firestore = context.read<FirebaseFirestore>();
    await StoreService.updateStore(firestore, store.copyWith(status: 'approved'));
    setState(() {});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Store "${store.name}" has been activated.')));
  }

  Future<void> _declineStore(TeamStore store) async {
    final firestore = context.read<FirebaseFirestore>();
    await StoreService.updateStore(firestore, store.copyWith(status: 'declined'));
    setState(() {});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Store "${store.name}" has been declined.')));
  }

  Future<void> _markBatchAddressed(String batchId, bool isDirect) async {
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
  }

  Future<void> _createCampaignStore() async {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;
    
    final firestore = context.read<FirebaseFirestore>();
    final newStore = TeamStore(
      id: 'store-campaign-${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      name: 'New Campaign Store',
      slug: 'campaign-${DateTime.now().millisecondsSinceEpoch}',
      status: 'approved',
      pricingApproved: true,
      packageType: 'individual',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await StoreService.createStore(firestore, newStore);
    setState(() {});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Campaign Store created successfully.')));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        OrderService.getAllOrders(context.read<FirebaseFirestore>()),
        StoreService.getPendingStores(context.read<FirebaseFirestore>()),
        StoreService.getCampaignStores(context.read<FirebaseFirestore>()),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final allOrders = snapshot.data![0] as List<ParentOrder>;
        final pendingStores = snapshot.data![1] as List<TeamStore>;
        final campaignStores = snapshot.data![2] as List<TeamStore>;
        
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
  }

  Widget _buildStoresAndOrdersTab(List<TeamStore> pendingStores, Map<String, List<ParentOrder>> submittedBatches) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (pendingStores.isNotEmpty) ...[
          Text('Stores Pending Approval', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ...pendingStores.map((store) => GlassPanel(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(store.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Requested: ${store.createdAt.toString().split(' ')[0]}', style: const TextStyle(color: AppTheme.textMuted)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _approveStore(store),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('APPROVE'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _declineStore(store),
                      child: const Text('DECLINE', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
        
        const SizedBox(height: 24),
        Text('Submitted Master Orders', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        if (submittedBatches.isEmpty)
          const Text('No submitted batches.', style: TextStyle(color: AppTheme.textMuted))
        else
          ...submittedBatches.entries.map((entry) {
            final batchId = entry.key;
            final orders = entry.value;
            final storeId = orders.first.teamStoreId;
            final store = dummyTeamStores.firstWhere((s) => s.id == storeId, orElse: () => TeamStore(
              id: '', userId: '', name: 'Unknown', slug: '', createdAt: DateTime.now(), updatedAt: DateTime.now()
            ));

            return GlassPanel(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(store.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Batch: $batchId', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  Text('${orders.length} Athletes', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/admin/store/edit', arguments: store.id),
                        child: const Text('REVIEW / EDIT STORE'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => _markBatchAddressed(batchId, orders.first.teamStoreId == null),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.green, side: const BorderSide(color: Colors.green)),
                        child: const Text('MARK ADDRESSED'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildCampaignStoresTab(List<TeamStore> campaignStores) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Campaign Stores', style: Theme.of(context).textTheme.titleLarge),
            ElevatedButton(
              onPressed: _createCampaignStore,
              child: const Text('CREATE CAMPAIGN STORE'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (campaignStores.isEmpty)
          const Text('No campaign stores have been created yet.', style: TextStyle(color: AppTheme.textMuted))
        else
          ...campaignStores.map((store) => GlassPanel(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(store.isArchived ? 'ARCHIVED' : 'ACTIVE', style: TextStyle(color: store.isArchived ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/admin/store/edit', arguments: store.id),
                  child: const Text('MANAGE STORE'),
                ),
              ],
            ),
          )),
      ],
    );
  }
}



