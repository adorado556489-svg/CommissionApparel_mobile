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
import '../../services/user_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/managed_image.dart';

class StoreDetailScreen extends StatelessWidget {
  final String storeId;

  const StoreDetailScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirebaseFirestore>();
    return FutureBuilder<TeamStore?>(
      future: StoreService.getStoreById(firestore, storeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return AppScaffold(
            title: 'Loading...',
            currentNavIndex: 2,
            body: Center(child: CircularProgressIndicator()),
          );
        final store = snapshot.data;
        if (store == null)
          return AppScaffold(
            title: 'Store Not Found',
            currentNavIndex: 2,
            body: Center(child: Text('Store not found.')),
          );

        return FutureBuilder<List<dynamic>>(
          future: Future.wait([
            UserService.getUserById(firestore, store.userId),
            StoreService.getStoreItems(firestore, store.id),
          ]),
          builder: (context, snapshot2) {
            if (snapshot2.connectionState == ConnectionState.waiting)
              return AppScaffold(
                title: store.name,
                currentNavIndex: 2,
                body: Center(child: CircularProgressIndicator()),
              );
            final coach = snapshot2.data?[0] as User?;
            final items = (snapshot2.data?[1] as List<StoreItem>?) ?? [];

            return AppScaffold(
              title: store.name,
              currentNavIndex: 2,
              floatingActionButton: store.isAcceptingOrders
                  ? FloatingActionButton.extended(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/store/order',
                        arguments: store.id,
                      ),
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Place Order'),
                    )
                  : null,
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHero(context, store),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStoreInfo(context, store, coach),
                          const SizedBox(height: 24.0),
                          Text(
                            'Available Items',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16.0),
                          if (items.isEmpty)
                            const Text('No items available currently.')
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 240,
                                    mainAxisExtent: 250,
                                    crossAxisSpacing: 16.0,
                                    mainAxisSpacing: 16.0,
                                  ),
                              itemCount: items.length,
                              itemBuilder: (context, index) =>
                                  _buildItemCard(context, store, items[index]),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHero(BuildContext context, TeamStore store) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          store.coverImagePath != null
              ? AppImage(store.coverImagePath, fit: BoxFit.cover)
              : Container(
                  color: AppTheme.primary,
                  child: Center(
                    child: Text(
                      'TEAM STORE',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
          if (store.logoPath != null)
            Positioned(
              left: 20,
              bottom: 16,
              child: Container(
                width: 68,
                height: 68,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppImage(
                  store.logoPath,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
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
            if ((store.description ?? '').trim().isNotEmpty) ...[
              Text(store.description!.trim()),
              const SizedBox(height: 8.0),
            ],
            Text(
              store.orderDeadline == null ? 'Open until further notice' : 'Closes: ${Fmt.date(store.orderDeadline)}',
              style: const TextStyle(
                color: AppTheme.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (store.closedMessage != null) ...[
              const SizedBox(height: 12.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Text(store.closedMessage!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, TeamStore store, StoreItem item) {
    return GestureDetector(
      onTap: () {
        if (store.isAcceptingOrders) {
          Navigator.pushNamed(context, '/store/order', arguments: store.id);
        }
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: item.displayImage != null
                  ? AppImage(item.displayImage, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.checkroom,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.retailPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
