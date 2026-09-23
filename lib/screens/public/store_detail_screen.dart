import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_panel.dart';
import '../../data/dummy_stores.dart';
import '../../data/dummy_users.dart';
import '../../models/store_item.dart';

class StoreDetailScreen extends StatelessWidget {
  final String storeId;

  const StoreDetailScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final store = dummyTeamStores.firstWhere(
      (s) => s.id == storeId,
      orElse: () => dummyTeamStores.first,
    );
    final coach = dummyUsers.firstWhere((u) => u.id == store.userId, orElse: () => dummyAdmin);
    final items = dummyStoreItems.where((i) => i.teamStoreId == store.id).toList();

    return AppScaffold(
      title: store.name,
      currentNavIndex: 2,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHero(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: _buildHeaderInfo(context, store, coach),
            ),
            
            if (!store.isLive)
              _buildStoreClosedAlert(context, store),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                'AVAILABLE ITEMS',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            
            if (items.isEmpty)
              _buildEmptyState(context)
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: _buildItemsGrid(context, items),
              ),
              
            const SizedBox(height: 48),
          ],
        ),
      ),
      floatingActionButton: store.isAcceptingOrders && items.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).pushNamed('/store/order', arguments: store.id);
              },
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.shopping_cart),
              label: const Text('PLACE ORDER', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      color: AppTheme.primary.withValues(alpha: 0.1),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/team-store-background-v2.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: AppTheme.primary.withValues(alpha: 0.2)),
          ),
          Container(color: Colors.black.withValues(alpha: 0.4)),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context, dynamic store, dynamic coach) {
    return GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: const Icon(Icons.shield, size: 40, color: AppTheme.borderSubtle),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Text(
                    (coach.sport ?? 'Team Athletics').toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  store.name.toUpperCase(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Official Custom Apparel Storefront • Coach ${coach.fullName}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (store.orderDeadline != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Column(
                children: [
                  Text('ORDER DEADLINE', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '${store.orderDeadline!.month}/${store.orderDeadline!.day}/${store.orderDeadline!.year}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStoreClosedAlert(BuildContext context, dynamic store) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.warning),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'This store is currently not accepting orders.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.warning, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsGrid(BuildContext context, List<StoreItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(context, item);
      },
    );
  }

  Widget _buildItemCard(BuildContext context, StoreItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: AppTheme.primary.withValues(alpha: 0.05),
              width: double.infinity,
              child: const Center(
                child: Icon(Icons.image, size: 64, color: AppTheme.borderSubtle),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.isPackage)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      'PACKAGE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.secondary, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${item.retailPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.success, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderSubtle, style: BorderStyle.solid),
        ),
        child: Text(
          'NO ITEMS AVAILABLE IN THIS STORE.',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.textMuted, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
