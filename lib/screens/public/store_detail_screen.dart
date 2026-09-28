import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_panel.dart';
import '../../models/store_item.dart';
import '../../models/team_store.dart';
import '../../models/user.dart';
import '../../services/store_service.dart';
import '../../services/auth_service.dart';

class StoreDetailScreen extends StatelessWidget {
  final String storeId;

  const StoreDetailScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirebaseFirestore>();
    return FutureBuilder<TeamStore?>(
      future: StoreService.getStoreById(firestore, storeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return AppScaffold(title: 'Loading...', currentNavIndex: 2, body: Center(child: CircularProgressIndicator()));
        final store = snapshot.data;
        if (store == null) return AppScaffold(title: 'Store Not Found', currentNavIndex: 2, body: Center(child: Text('Store not found.')));
        
        return FutureBuilder<List<dynamic>>(
          future: Future.wait([
            AuthService(firestore: firestore).getUserById(store.userId),
            StoreService.getStoreItems(firestore, store.id)
          ]),
          builder: (context, snapshot2) {
            if (snapshot2.connectionState == ConnectionState.waiting) return AppScaffold(title: store.name, currentNavIndex: 2, body: Center(child: CircularProgressIndicator()));
            final coach = snapshot2.data?[0] as User?;
            final items = (snapshot2.data?[1] as List<StoreItem>?) ?? [];
            
            return AppScaffold(
              title: store.name,
              currentNavIndex: 2,
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHero(context),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStoreInfo(context, store, coach),
                          const SizedBox(height: 24.0),
                          Text('Available Items', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 16.0),
                          if (items.isEmpty)
                            const Text('No items available currently.')
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16.0,
                                mainAxisSpacing: 16.0,
                              ),
                              itemCount: items.length,
                              itemBuilder: (context, index) => _buildItemCard(context, items[index]),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: AppTheme.primary,
      ),
      child: Center(
        child: Text('TEAM STORE', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStoreInfo(BuildContext context, TeamStore store, User? coach) {
    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(store.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8.0),
            if (coach != null) Text('Coach: ${coach.fullName}'),
            const SizedBox(height: 8.0),
            Text('Closes: ${store.orderDeadline.toString().split(' ')[0]}', style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, StoreItem item) {
    return GestureDetector(
      onTap: () {
        // Navigate to item detail (not implemented in this stub)
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: const Icon(Icons.checkroom, size: 48, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('\$${item.retailPrice.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
