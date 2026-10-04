import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/statuses.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../models/parent_order.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/status_chip.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  Future<List<ParentOrder>>? _future;
  String? _loadedFor;

  /// Loads once per user instead of refetching on every rebuild.
  Future<List<ParentOrder>> _ordersFor(FirebaseFirestore firestore, String userId) {
    if (_future == null || _loadedFor != userId) {
      _loadedFor = userId;
      _future = OrderService.getOrdersForUser(firestore, userId)
          .then((list) => list..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
    }
    return _future!;
  }

  Future<void> _refresh() async {
    setState(() => _future = null);
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;
    await _ordersFor(context.read<FirebaseFirestore>(), user.id).catchError((_) => <ParentOrder>[]);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    if (user == null) return const AppScaffold(title: 'Loading', body: Center(child: CircularProgressIndicator()));

    final firestore = context.read<FirebaseFirestore>();

    return AppScaffold(
      title: 'My Orders',
      currentNavIndex: 3, // resolved from the route; fallback only
      body: FutureBuilder<List<ParentOrder>>(
        future: _ordersFor(firestore, user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Failed to load orders.'),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: _refresh, child: const Text('RETRY')),
                ],
              ),
            );
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text('You have no order history.'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              itemCount: orders.length,
              itemBuilder: (context, index) => _OrderCard(order: orders[index]),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final ParentOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final o = order;
    final title = o.isDirectOrder
        ? 'Direct Order'
        : ((o.storeName ?? '').trim().isEmpty ? 'Store Order' : o.storeName!);
    final history = [...o.statusHistory]..sort((a, b) => a.at.compareTo(b.at));
    final payColor = o.isCancelled ? Colors.grey : (o.isPaid ? Colors.green : Colors.orange);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusChip(label: OrderStatus.label(o.status), color: OrderStatus.color(o.status)),
              Text(Fmt.money(o.effectiveRetailTotal), style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(Fmt.date(o.createdAt), style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
            ],
          ),
        ),
        children: [
          if (o.athleteName.trim().isNotEmpty) Text('For: ${o.athleteName}'),
          const SizedBox(height: 4),
          Text(
            o.isCancelled ? 'Order cancelled' : (o.isPaid ? 'Payment received' : 'Awaiting payment to your coach'),
            style: TextStyle(color: payColor, fontWeight: FontWeight.w600),
          ),
          if ((o.trackingNumber ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Tracking number: ${o.trackingNumber}'),
          ],
          const Divider(height: 24),
          for (final e in o.itemEntries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text('${e.quantity} x ${e.name}${e.sizeSummary.isEmpty ? '' : ' (${e.sizeSummary})'}'),
                  ),
                  const SizedBox(width: 8),
                  Text(Fmt.money(e.lineTotal)),
                ],
              ),
            ),
          if (history.isNotEmpty) ...[
            const Divider(height: 24),
            for (final ev in history)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(child: Text(OrderStatus.label(ev.status))),
                    Text(Fmt.dateTime(ev.at), style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
