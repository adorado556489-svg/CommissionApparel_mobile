import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../models/parent_order.dart';
import '../../app/theme.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/app_scaffold.dart';

class OrdersHistoryScreen extends StatelessWidget {
  const OrdersHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    if (user == null) return const AppScaffold(title: 'Loading', body: Center(child: CircularProgressIndicator()));

    final firestore = context.read<FirebaseFirestore>();

    return AppScaffold(
      title: 'My Orders',
      currentNavIndex: 3, // 0=Home, 1=My Store, 2=Catalog, 3=Orders, 4=Account
      body: FutureBuilder<List<ParentOrder>>(
        future: OrderService.getOrdersForUser(firestore, user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load orders.'));
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text('You have no order history.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final o = orders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(o.isDirectOrder ? 'Direct Order' : 'Store Order: ${o.athleteName}'),
                  subtitle: Text('Status: ${o.status}\nTotal: \$${o.totalRetailPrice.toStringAsFixed(2)}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
