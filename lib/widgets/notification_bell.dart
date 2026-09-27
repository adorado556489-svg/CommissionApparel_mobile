import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/content_service.dart';
import '../models/notification_item.dart';
import '../app/theme.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    if (user == null) return const SizedBox.shrink();

    final firestore = context.read<FirebaseFirestore>();
    final stream = ContentService.getUserNotificationsStream(firestore, user.id);

    return StreamBuilder<List<NotificationItem>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
           return const Icon(Icons.notifications, color: AppTheme.borderSubtle);
        }
        
        final notifications = snapshot.data ?? [];
        final unreadCount = notifications.where((n) => !n.isRead).length;

        return IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications),
              if (unreadCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () => _showNotifications(context, stream),
        );
      }
    );
  }

  void _showNotifications(BuildContext context, Stream<List<NotificationItem>> stream) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceLight,
      builder: (ctx) {
        return StreamBuilder<List<NotificationItem>>(
          stream: stream,
          builder: (ctx, snapshot) {
            final notifications = snapshot.data ?? [];
            final isLoading = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Notifications', style: Theme.of(ctx).textTheme.titleLarge),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : notifications.isEmpty
                          ? const Center(child: Text('No notifications.'))
                          : ListView.builder(
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
                                            final firestore = ctx.read<FirebaseFirestore>();
                                            await ContentService.markNotificationRead(firestore, n.id, ctx.read<AuthService>().currentUser!.id);
                                          },
                                          child: const Text('Mark Read', style: TextStyle(fontSize: 12)),
                                        )
                                      : null,
                                );
                              },
                            ),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
