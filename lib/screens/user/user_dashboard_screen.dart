import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/statuses.dart';
import '../../services/auth_service.dart';
import '../../services/store_service.dart';
import '../../services/content_service.dart';
import '../../models/team_store.dart';
import '../../models/notification_item.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/app_scaffold.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  Future<TeamStore?>? _storeFuture;
  String? _loadedForUserId;

  /// Loads the user's store once per user instead of on every rebuild.
  Future<TeamStore?> _storeFor(FirebaseFirestore firestore, String userId) {
    if (_storeFuture == null || _loadedForUserId != userId) {
      _loadedForUserId = userId;
      _storeFuture = StoreService.getOwnerStoreIncludingArchived(firestore, userId);
    }
    return _storeFuture!;
  }

  void _reload() => setState(() => _storeFuture = null);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    if (user == null) return const AppScaffold(title: 'Loading', body: Center(child: CircularProgressIndicator()));

    final firestore = context.read<FirebaseFirestore>();

    return AppScaffold(
      title: 'Home',
      currentNavIndex: 0,
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back, ${user.firstName}!', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              if (auth.isAdmin)
                _buildAdminCard(context)
              else ...[
                _buildBrowseStoresCard(context),
                const SizedBox(height: 24),
                _buildStoreSummary(context, firestore, user.id, auth),
              ],
              const SizedBox(height: 24),
              _buildNotificationsSummary(context, firestore, user.id),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.admin_panel_settings, color: Colors.blue, size: 28),
              const SizedBox(width: 8),
              Expanded(child: Text('Admin Console', style: Theme.of(context).textTheme.titleLarge)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Review store requests, monitor stores and master orders, and track platform revenue.'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/admin/dashboard'),
            icon: const Icon(Icons.dashboard),
            label: const Text('Open Admin Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseStoresCard(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.explore, color: Colors.teal, size: 28),
              const SizedBox(width: 8),
              Expanded(child: Text('Browse Team Stores', style: Theme.of(context).textTheme.titleLarge)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Find your team or organization\'s store, pick your gear and place an order.'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/store/search'),
            icon: const Icon(Icons.search),
            label: const Text('Find a Store'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreSummary(BuildContext context, FirebaseFirestore firestore, String userId, AuthService auth) {
    return FutureBuilder<TeamStore?>(
      future: _storeFor(firestore, userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final store = snapshot.data;
        if (store == null) {
          return GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storefront, color: Colors.blue, size: 28),
                    const SizedBox(width: 8),
                    Expanded(child: Text('No Team Store Yet', style: Theme.of(context).textTheme.titleLarge)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Want to sell custom apparel for your team or organization? Submit a request to open a store. Once approved by an Admin, you will be upgraded to a Coach account.',
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed('/user/open-store-request'),
                  icon: const Icon(Icons.add_business),
                  label: const Text('Request to Open a Store'),
                ),
              ],
            ),
          );
        }

        if (store.isArchived) {
          return GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pause_circle_outline, color: Colors.grey, size: 28),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Store Suspended: ${store.name}', style: Theme.of(context).textTheme.titleLarge)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('An administrator has suspended this store. It is hidden from customers until it is restored.'),
              ],
            ),
          );
        }

        if (store.status == StoreStatus.pending) {
          return GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pending_actions, color: Colors.orange, size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Store Request: ${store.name}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: const Text(
                    'STATUS: PENDING ADMIN APPROVAL',
                    style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your store request is currently under review by our admin team. Once approved, your account will automatically unlock store management features.',
                ),
              ],
            ),
          );
        }

        if (store.status == StoreStatus.declined) {
          final reason = (store.declineReason ?? '').trim();
          return GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 28),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Store Request Declined', style: Theme.of(context).textTheme.titleLarge)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Your request for "${store.name}" was declined. You may submit a new request with updated information.'),
                if (reason.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Reason: $reason', style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed('/user/open-store-request'),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Submit New Request'),
                ),
              ],
            ),
          );
        }

        // Approved / locked store
        final isCoach = auth.currentRole == UserRole.coach;
        final color = StoreStatus.color(store.status);
        return GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified, color: Colors.green, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('My Store: ${store.name}', style: Theme.of(context).textTheme.titleLarge),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color),
                ),
                child: Text(
                  'STATUS: ${StoreStatus.label(store.status).toUpperCase()}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              if (isCoach)
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/coach/dashboard'),
                  icon: const Icon(Icons.store),
                  label: const Text('Go to Store Management'),
                )
              else
                const Text(
                  'Your store is approved, but your account has not been upgraded to Coach yet. Please contact support so store management can be unlocked.',
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationsSummary(BuildContext context, FirebaseFirestore firestore, String userId) {
    return StreamBuilder<List<NotificationItem>>(
      stream: ContentService.getUserNotificationsStream(firestore, userId),
      builder: (context, snapshot) {
        final count = (snapshot.data ?? []).where((n) => !n.isRead).length;
        return GlassPanel(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text('You have $count unread notification(s).'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/notifications'),
                child: const Text('View All'),
              ),
            ],
          ),
        );
      },
    );
  }
}
