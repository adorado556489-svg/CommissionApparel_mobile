import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/content_service.dart';
import '../../models/notification_item.dart';
import '../../app/theme.dart';
import '../../widgets/app_scaffold.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    if (user == null) return const AppScaffold(title: 'Loading', body: Center(child: CircularProgressIndicator()));

    final firestore = context.read<FirebaseFirestore>();

    return AppScaffold(
      title: 'Notifications',
      // We don't map notifications to a bottom tab (since they're 5 total).
      // If we want it to highlight nothing, or something else. We'll leave it at 0 but it's not a tab.
      currentNavIndex: 0,
      body: StreamBuilder<List<NotificationItem>>(
        stream: ContentService.getUserNotificationsStream(firestore, user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications.'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (ctx, index) {
              final n = notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: n.isRead ? Colors.grey.shade300 : AppTheme.primary.withValues(alpha: 0.1),
                  child: Icon(
                    n.type == 'order' ? Icons.shopping_cart : Icons.info,
                    color: n.isRead ? Colors.grey : AppTheme.primary,
                  ),
                ),
                title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
                subtitle: Text(n.message),
                trailing: !n.isRead
                    ? TextButton(
                        onPressed: () async {
                          await ContentService.markNotificationRead(firestore, n.id, user.id);
                        },
                        child: const Text('Mark Read', style: TextStyle(fontSize: 12)),
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
