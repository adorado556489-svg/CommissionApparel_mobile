import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/store_service.dart';
import '../../services/content_service.dart';
import '../../models/team_store.dart';
import '../../models/notification_item.dart';
import '../../app/theme.dart';
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
      future: StoreService.getActiveStoreForCoach(firestore, userId),
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
                Text('No Active Store', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text('Get started by creating your team store today.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/coach/dashboard'),
                  child: const Text('Create My Store'),
                ),
              ],
            ),
          );
        }

        return GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Store: ${store.name}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Status: ${store.status.toUpperCase()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/coach/dashboard'),
                child: const Text('Manage Store'),
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
