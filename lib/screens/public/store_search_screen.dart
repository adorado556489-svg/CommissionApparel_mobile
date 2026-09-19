import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../data/dummy_stores.dart';
import '../../data/dummy_users.dart';
import '../../models/team_store.dart';

class StoreSearchScreen extends StatefulWidget {
  const StoreSearchScreen({super.key});

  @override
  State<StoreSearchScreen> createState() => _StoreSearchScreenState();
}

class _StoreSearchScreenState extends State<StoreSearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only show live stores
    var activeStores = dummyTeamStores.where((s) => s.isLive).toList();

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      activeStores = activeStores.where((s) {
        final coach = dummyUsers.firstWhere((u) => u.id == s.userId, orElse: () => dummyAdmin);
        return s.name.toLowerCase().contains(q) ||
               (coach.organization?.toLowerCase().contains(q) ?? false) ||
               (coach.fullName.toLowerCase().contains(q)) ||
               (coach.sport?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return AppScaffold(
      title: 'Team Stores',
      currentNavIndex: 2,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  if (activeStores.isEmpty)
                    _buildEmptyState()
                  else
                    _buildGrid(context, activeStores),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.surfaceLight,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TEAM STORES',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            'Choose your team and continue to the same parent order page.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search by store, coach, organization, or sport',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (val) {
              setState(() => _searchQuery = val);
            },
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            setState(() => _searchQuery = _searchController.text);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: const Text('SEARCH'),
        ),
      ],
    );
  }

  Widget _buildGrid(BuildContext context, List<TeamStore> stores) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        final coach = dummyUsers.firstWhere((u) => u.id == store.userId, orElse: () => dummyAdmin);

        return InkWell(
          onTap: () {
            // Navigate to Store Detail
            Navigator.of(context).pushNamed('/store/detail', arguments: store.id);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (coach.sport ?? 'Team Athletics').toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            store.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            coach.organization ?? 'Organization not set',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            'Coach ${coach.fullName}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                      ),
                      child: const Text('OPEN', style: TextStyle(color: AppTheme.success, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const Spacer(),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        store.orderDeadline != null 
                            ? 'Deadline: ${store.orderDeadline!.month}/${store.orderDeadline!.day}/${store.orderDeadline!.year}'
                            : 'No deadline posted',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'OPEN STORE →',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.secondary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          const Icon(Icons.store, size: 48, color: AppTheme.borderSubtle),
          const SizedBox(height: 16),
          Text(
            'NO TEAM STORES FOUND',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term or check back later for newly opened stores.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
