import 'package:flutter/material.dart';

import '../../../constants/statuses.dart';
import '../../../models/parent_order.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/glass_panel.dart';
import '../../../widgets/status_chip.dart';

/// Coach "EARNINGS" tab. Figures come from the immutable price snapshots on
/// each order, so later price edits never change past earnings.
class CoachEarningsTab extends StatelessWidget {
  final List<ParentOrder> orders;
  final bool loaded;

  const CoachEarningsTab({super.key, required this.orders, required this.loaded});

  @override
  Widget build(BuildContext context) {
    if (!loaded) return const Center(child: CircularProgressIndicator());

    final active = orders.where((o) => !o.isCancelled).toList();
    final totals = ParentOrder.calculateBatchFinancials(orders: active);

    final delivered = active.where((o) => OrderStatus.normalize(o.status) == OrderStatus.delivered).toList();
    final payable = delivered.fold<double>(0, (s, o) => s + o.coachEarnings);
    final pendingEarnings = totals.netProceeds - payable;

    final collected = active.where((o) => o.isPaid).fold<double>(0, (s, o) => s + o.effectiveRetailTotal);
    final awaiting = totals.totalSales - collected;

    final counts = <String, int>{};
    for (final o in active) {
      final key = OrderStatus.normalize(o.status);
      counts[key] = (counts[key] ?? 0) + 1;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        KpiWrap(
          cards: [
            KpiCard(
              label: 'Your commission',
              value: Fmt.money(totals.netProceeds),
              icon: Icons.account_balance_wallet_outlined,
              color: Colors.green,
            ),
            KpiCard(
              label: 'Total sales',
              value: Fmt.money(totals.totalSales),
              icon: Icons.payments_outlined,
            ),
            KpiCard(
              label: 'Production cost',
              value: Fmt.money(totals.totalWholesaleCost),
              icon: Icons.factory_outlined,
              color: Colors.blueGrey,
            ),
            KpiCard(
              label: 'Items sold',
              value: '${totals.totalItemsSold}',
              icon: Icons.checkroom,
              color: Colors.indigo,
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassPanel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Commission', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _line('Ready for payout (delivered)', payable, color: Colors.green),
              _line('Pending (not yet delivered)', pendingEarnings),
              const SizedBox(height: 8),
              Text(
                'Commission is your retail price minus the production cost, and is settled once the master order is delivered.',
                style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Customer payments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _line('Collected', collected, color: Colors.green),
              _line('Awaiting payment', awaiting, color: awaiting > 0 ? Colors.redAccent : null),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Orders by status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (counts.isEmpty)
                const Text('No orders yet.')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final status in OrderStatus.pipeline)
                      if ((counts[status] ?? 0) > 0)
                        StatusChip(
                          label: '${OrderStatus.label(status)}: ${counts[status]}',
                          color: OrderStatus.color(status),
                        ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _line(String label, double value, {Color? color}) {
    final style = TextStyle(fontWeight: FontWeight.w600, color: color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(Fmt.money(value), style: style),
        ],
      ),
    );
  }
}
