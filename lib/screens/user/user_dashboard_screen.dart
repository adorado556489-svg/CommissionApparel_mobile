import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/store_service.dart';
import '../../services/content_service.dart';
import '../../models/team_store.dart';
import '../../models/notification_item.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/app_scaffold.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    if (user == null) return const AppScaffold(title: 'Loading', body: Center(child: CircularProgressIndicator()));

    final firestore = context.read<FirebaseFirestore>();

    return AppScaffold(
      title: 'Home',
      currentNavIndex: 0,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back, ${user.firstName}!', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            _buildStoreSummary(context, firestore, user.id),
            const SizedBox(height: 24),
            _buildNotificationsSummary(context, firestore, user.id),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreSummary(BuildContext context, FirebaseFirestore firestore, String userId) {
    return FutureBuilder<TeamStore?>(
      future: StoreService.getStoreForUser(firestore, userId),
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
                    Text('No Team Store Yet', style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Want to sell custom apparel for your team or organization? Submit a request to open a store. Once approved by an Admin, you will be upgraded to a Coach account.',
                ),
                if (!context.read<AuthService>().isAdmin) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/user/open-store-request'),
                    icon: const Icon(Icons.add_business),
                    label: const Text('Request to Open a Store'),
                  ),
                ],
              ],
            ),
          );
        }

        if (store.status == 'pending') {
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

        if (store.status == 'declined') {
          return GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 28),
                    const SizedBox(width: 8),
                    Text('Store Request Declined', style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Your request for "${store.name}" was declined. You may submit a new request with updated information.'),
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

        // Approved / Active store
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
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  'STATUS: ${store.status.toUpperCase()}',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/coach/dashboard'),
                icon: const Icon(Icons.store),
                label: const Text('Go to Store Management'),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('You have $count unread notification(s).'),
                ],
              ),
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
