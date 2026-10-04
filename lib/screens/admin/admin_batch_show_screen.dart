import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../constants/statuses.dart';
import '../../models/parent_order.dart';
import '../../models/team_store.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/store_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/status_chip.dart';

/// One master order (batch): its orders, financials and production status.
/// The admin moves the whole batch forward one stage at a time.
class AdminBatchShowScreen extends StatefulWidget {
  final String batchId;
  const AdminBatchShowScreen({super.key, required this.batchId});

  @override
  State<AdminBatchShowScreen> createState() => _AdminBatchShowScreenState();
}

class _AdminBatchShowScreenState extends State<AdminBatchShowScreen> {
  bool _loading = true;
  bool _updating = false;
  String? _error;
  List<ParentOrder> _orders = [];
  TeamStore? _store;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    final firestore = context.read<FirebaseFirestore>();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final orders = (await OrderService.getOrdersForBatch(firestore, widget.batchId)).where((o) => !o.isCancelled).toList()
        ..sort((a, b) => a.athleteName.compareTo(b.athleteName));
      TeamStore? store;
      final storeId = orders.isEmpty ? null : orders.first.teamStoreId;
      if (storeId != null) store = await StoreService.getStoreById(firestore, storeId);
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _store = store;
        _loading = false;
      });
    } catch (e) {
      debugPrint('AdminBatchShow load failed: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Could not load this master order.';
        _loading = false;
      });
    }
  }

  String get _status {
    var slowest = _orders.first.status;
    for (final o in _orders) {
      if (OrderStatus.stepIndex(o.status) < OrderStatus.stepIndex(slowest)) slowest = o.status;
    }
    return OrderStatus.normalize(slowest);
  }

  Future<void> _advance() async {
    final admin = context.read<AuthService>().currentUser;
    if (admin == null || _orders.isEmpty) return;
    final next = OrderStatus.next(_status);
    if (next == null) return;

    String? tracking;
    if (next == OrderStatus.shipped) {
      tracking = await showDialog<String>(context: context, builder: (_) => const _TrackingDialog());
      if (tracking == null) return; // cancelled
    } else {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Mark as ${OrderStatus.label(next)}?'),
          content: Text('All ${_orders.length} orders in this master order move to "${OrderStatus.label(next)}" and the customers and coach are notified.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('CONFIRM')),
          ],
        ),
      );
      if (ok != true) return;
    }
    if (!mounted) return;

    setState(() => _updating = true);
    final firestore = context.read<FirebaseFirestore>();
    final error = await AdminService.advanceBatchStatus(firestore, admin, widget.batchId, trackingNumber: tracking);
    if (!mounted) return;
    setState(() => _updating = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error ?? 'Master order is now ${OrderStatus.label(next)}.')));
    if (error == null) await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(title: 'Master Order', body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _orders.isEmpty) {
      return AppScaffold(
        title: 'Master Order',
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error ?? 'Master order not found or empty.'),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _load, child: const Text('RETRY')),
            ],
          ),
        ),
      );
    }

    final fin = ParentOrder.calculateBatchFinancials(orders: _orders);
    final status = _status;
    final next = OrderStatus.next(status);
    final tracking = _orders.map((o) => o.trackingNumber).firstWhere((t) => t != null && t.isNotEmpty, orElse: () => null);

    return AppScaffold(
      title: 'Master Order',
      currentNavIndex: 1,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(_store?.name ?? _orders.first.storeName ?? 'Unknown store',
                                maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge),
                          ),
                          const SizedBox(width: 8),
                          StatusChip(label: OrderStatus.label(status), color: OrderStatus.color(status)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Batch ${widget.batchId}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 24,
                        runSpacing: 10,
                        children: [
                          _figure('Athletes', '${fin.orderCount}'),
                          _figure('Items', '${fin.totalItemsSold}'),
                          _figure('Gross sales', Fmt.money(fin.totalSales)),
                          _figure('Platform revenue', Fmt.money(fin.totalWholesaleCost), color: Colors.blue),
                          _figure('Coach commission', Fmt.money(fin.netProceeds), color: Colors.green),
                        ],
                      ),
                      if (tracking != null) ...[
                        const SizedBox(height: 12),
                        Text('Tracking number: $tracking'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Production progress', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      ..._steps(status),
                      const SizedBox(height: 12),
                      if (next != null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _updating ? null : _advance,
                            icon: _updating
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.arrow_forward),
                            label: Text('MARK AS ${OrderStatus.label(next).toUpperCase()}'),
                          ),
                        )
                      else
                        const Text('This master order is complete.', style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Orders in this master order', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ..._orders.map(_orderTile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _steps(String status) {
    const steps = [OrderStatus.submitted, OrderStatus.inProduction, OrderStatus.shipped, OrderStatus.delivered];
    final current = OrderStatus.stepIndex(status);
    return [
      for (final s in steps)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Icon(
                OrderStatus.stepIndex(s) <= current ? Icons.check_circle : Icons.radio_button_unchecked,
                color: OrderStatus.stepIndex(s) <= current ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                OrderStatus.label(s),
                style: TextStyle(fontWeight: OrderStatus.stepIndex(s) == current ? FontWeight.bold : FontWeight.normal),
              ),
            ],
          ),
        ),
    ];
  }

  Widget _orderTile(ParentOrder o) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(o.athleteName),
        subtitle: Text('${o.totalItemCount} item(s)  -  ${Fmt.money(o.effectiveRetailTotal)}${o.isPaid ? '  -  Paid' : '  -  Unpaid'}'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in o.itemEntries)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('${e.quantity} x ${e.name}${e.sizeSummary.isNotEmpty ? ' (${e.sizeSummary})' : ''}'),
            ),
          if ((o.jerseyName ?? '').isNotEmpty || (o.jerseyNumber ?? '').isNotEmpty)
            Text('Print: ${o.jerseyName ?? ''} ${o.jerseyNumber != null ? '#${o.jerseyNumber}' : ''}'),
          if ((o.specialNotes ?? '').isNotEmpty) Text('Notes: ${o.specialNotes}'),
        ],
      ),
    );
  }

  Widget _figure(String label, String value, {Color? color}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      );
}

/// Optional tracking number captured when a master order is shipped.
class _TrackingDialog extends StatefulWidget {
  const _TrackingDialog();

  @override
  State<_TrackingDialog> createState() => _TrackingDialogState();
}

class _TrackingDialogState extends State<_TrackingDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mark as Shipped'),
      content: SingleChildScrollView(
        child: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Tracking number (optional)',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
        ElevatedButton(onPressed: () => Navigator.pop(context, _controller.text), child: const Text('CONFIRM')),
      ],
    );
  }
}
