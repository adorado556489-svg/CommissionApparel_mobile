import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/statuses.dart';
import '../../../models/parent_order.dart';
import '../../../models/team_store.dart';
import '../../../services/auth_service.dart';
import '../../../services/order_service.dart';
import '../../../services/store_service.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/glass_panel.dart';
import '../../../widgets/status_chip.dart';

enum _OrderFilter { all, toSubmit, unpaid, paid, submitted }

/// Coach "ORDERS" tab: every customer order in the store, payment tracking
/// and the master-order submission to the factory.
class CoachOrdersTab extends StatefulWidget {
  final TeamStore store;
  final List<ParentOrder> orders;
  final bool loaded;

  /// Called after the store's state changed (e.g. locked after submitting).
  final VoidCallback onStoreChanged;

  const CoachOrdersTab({
    super.key,
    required this.store,
    required this.orders,
    required this.loaded,
    required this.onStoreChanged,
  });

  @override
  State<CoachOrdersTab> createState() => _CoachOrdersTabState();
}

class _CoachOrdersTabState extends State<CoachOrdersTab>
    with AutomaticKeepAliveClientMixin {
  _OrderFilter _filter = _OrderFilter.all;
  final Set<String> _busy = {};

  @override
  bool get wantKeepAlive => true;

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  List<ParentOrder> get _active => widget.orders.where((o) => !o.isCancelled).toList();
  List<ParentOrder> get _toSubmit => _active.where((o) => !o.isBatched).toList();

  bool _matches(ParentOrder o) {
    switch (_filter) {
      case _OrderFilter.all:
        return true;
      case _OrderFilter.toSubmit:
        return !o.isCancelled && !o.isBatched;
      case _OrderFilter.unpaid:
        return !o.isCancelled && !o.isPaid;
      case _OrderFilter.paid:
        return !o.isCancelled && o.isPaid;
      case _OrderFilter.submitted:
        return o.isBatched;
    }
  }

  Future<void> _setPaid(ParentOrder order, bool paid) async {
    if (_busy.contains(order.id)) return;
    setState(() => _busy.add(order.id));
    final error = await OrderService.setOrderPaid(
      context.read<FirebaseFirestore>(),
      order.id,
      paid,
    );
    if (!mounted) return;
    setState(() => _busy.remove(order.id));
    if (error != null) _toast(error);
  }

  Future<void> _submitMasterOrder() async {
    final pending = _toSubmit;
    if (pending.isEmpty) {
      _toast('No unbatched orders to submit.');
      return;
    }
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;

    final unpaid = pending.where((o) => !o.isPaid).length;
    final items = pending.fold<int>(0, (s, o) => s + o.totalItemCount);
    final base = pending.fold<double>(0, (s, o) => s + o.snapshotBaseTotal);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit master order?'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${pending.length} order${pending.length == 1 ? '' : 's'} - $items item${items == 1 ? '' : 's'}'),
              const SizedBox(height: 4),
              Text('Production cost: ${Fmt.money(base)}'),
              if (unpaid > 0) ...[
                const SizedBox(height: 12),
                Text(
                  '$unpaid order${unpaid == 1 ? ' is' : 's are'} still marked unpaid.',
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 12),
              const Text(
                'Orders are sent to production and can no longer be edited. Your store closes to new orders until you re-open it.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('SUBMIT')),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _busy.add('submit'));
    final firestore = context.read<FirebaseFirestore>();
    final batchId = 'batch-${widget.store.id}-${DateTime.now().millisecondsSinceEpoch}';
    final error = await OrderService.submitStoreOrdersToAdmin(
      firestore,
      user,
      widget.store.id,
      batchId,
    );
    if (error != null) {
      debugPrint('submitStoreOrdersToAdmin failed: $error');
      if (!mounted) return;
      setState(() => _busy.remove('submit'));
      _toast('Could not submit the master order. Please try again.');
      return;
    }

    // Closing the store is best effort: the orders are already with the admin.
    final lockError = await StoreService.setStoreStatus(
      firestore,
      widget.store.id,
      StoreStatus.submittedToAdmin,
    );
    if (lockError != null) debugPrint('Store lock failed: $lockError');

    if (!mounted) return;
    setState(() => _busy.remove('submit'));
    _toast('Master order submitted successfully!');
    widget.onStoreChanged();
  }

  void _showDetails(ParentOrder order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _OrderDetailSheet(
        order: order,
        onEdit: order.isEditable
            ? () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, '/coach/order/edit', arguments: order.id);
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!widget.loaded) return const Center(child: CircularProgressIndicator());

    final active = _active;
    final toSubmit = _toSubmit;
    final unpaid = active.where((o) => !o.isPaid).length;
    final sales = active.fold<double>(0, (s, o) => s + o.effectiveRetailTotal);
    final visible = widget.orders.where(_matches).toList();
    final submitting = _busy.contains('submit');

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverList.list(
            children: [
              KpiWrap(
                cards: [
                  KpiCard(label: 'Orders', value: '${active.length}', icon: Icons.receipt_long),
                  KpiCard(label: 'Total sales', value: Fmt.money(sales), icon: Icons.payments_outlined, color: Colors.green),
                  KpiCard(label: 'To submit', value: '${toSubmit.length}', icon: Icons.outbox, color: Colors.orange),
                  KpiCard(label: 'Awaiting payment', value: '$unpaid', icon: Icons.hourglass_bottom, color: Colors.redAccent),
                ],
              ),
              const SizedBox(height: 16),
              GlassPanel(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Master order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      widget.store.isLocked
                          ? 'Your last master order was sent to production. Re-open the store (STORE tab) to start a new campaign.'
                          : 'When the deadline is reached and payments are collected, send all pending orders to production in one batch.',
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: submitting ? null : _submitMasterOrder,
                      icon: submitting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.local_shipping_outlined),
                      label: Text(toSubmit.isEmpty ? 'SUBMIT MASTER ORDER' : 'SUBMIT MASTER ORDER (${toSubmit.length})'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final f in _OrderFilter.values)
                    ChoiceChip(
                      label: Text(_filterLabel(f)),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        if (visible.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  widget.orders.isEmpty
                      ? 'No orders yet. Share your store so customers can order.'
                      : 'No orders match this filter.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 24),
            sliver: SliverList.builder(
              itemCount: visible.length,
              itemBuilder: (context, i) {
                final order = visible[i];
                return _OrderCard(
                  order: order,
                  busy: _busy.contains(order.id),
                  onTap: () => _showDetails(order),
                  onPaidChanged: (v) => _setPaid(order, v),
                );
              },
            ),
          ),
      ],
    );
  }

  String _filterLabel(_OrderFilter f) {
    switch (f) {
      case _OrderFilter.all:
        return 'All';
      case _OrderFilter.toSubmit:
        return 'To submit';
      case _OrderFilter.unpaid:
        return 'Unpaid';
      case _OrderFilter.paid:
        return 'Paid';
      case _OrderFilter.submitted:
        return 'Submitted';
    }
  }
}

class _OrderCard extends StatelessWidget {
  final ParentOrder order;
  final bool busy;
  final VoidCallback onTap;
  final ValueChanged<bool> onPaidChanged;

  const _OrderCard({
    required this.order,
    required this.busy,
    required this.onTap,
    required this.onPaidChanged,
  });

  @override
  Widget build(BuildContext context) {
    final canTogglePaid = order.isEditable && !busy;
    final payColor = order.isCancelled
        ? Colors.grey
        : (order.isPaid ? Colors.green : Colors.redAccent);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.athleteName.trim().isEmpty ? 'Customer order' : order.athleteName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: StatusChip(
                      label: OrderStatus.label(order.status),
                      color: OrderStatus.color(order.status),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${order.totalItemCount} item${order.totalItemCount == 1 ? '' : 's'}  |  ${Fmt.money(order.effectiveRetailTotal)}  |  ${Fmt.relative(order.createdAt)}',
                style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(order.isPaid ? Icons.check_circle : Icons.pending, size: 18, color: payColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.isCancelled ? 'Cancelled' : (order.isPaid ? 'Paid' : 'Awaiting payment'),
                      style: TextStyle(color: payColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (!order.isCancelled)
                    Tooltip(
                      message: canTogglePaid || busy
                          ? 'Mark as paid'
                          : 'Locked after submission',
                      child: Switch(
                        value: order.isPaid,
                        onChanged: canTogglePaid ? onPaidChanged : null,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet with everything the coach needs to fulfil one order.
class _OrderDetailSheet extends StatelessWidget {
  final ParentOrder order;
  final VoidCallback? onEdit;

  const _OrderDetailSheet({required this.order, this.onEdit});

  Widget _row(String label, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = [...order.statusHistory]..sort((a, b) => a.at.compareTo(b.at));
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.athleteName.trim().isEmpty ? 'Customer order' : order.athleteName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  StatusChip(label: OrderStatus.label(order.status), color: OrderStatus.color(order.status)),
                  StatusChip(
                    label: order.isPaid ? 'Paid' : 'Awaiting payment',
                    color: order.isPaid ? Colors.green : Colors.redAccent,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _row('Placed', Fmt.dateTime(order.createdAt)),
              _row('Contact', order.contactPhone),
              _row('Jersey name', order.jerseyName),
              _row('Jersey number', order.jerseyNumber),
              _row('Tracking', order.trackingNumber),
              _row('Notes', order.specialNotes),
              const Divider(height: 24),
              const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              for (final e in order.itemEntries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${e.quantity} x ${e.name}'),
                            if (e.sizeSummary.isNotEmpty)
                              Text('Size: ${e.sizeSummary}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(Fmt.money(e.lineTotal)),
                    ],
                  ),
                ),
              const Divider(height: 24),
              _amount('Order total', order.effectiveRetailTotal, bold: true),
              _amount('Production cost', order.snapshotBaseTotal),
              _amount('Your earnings', order.coachEarnings, color: Colors.green),
              if (history.isNotEmpty) ...[
                const Divider(height: 24),
                const Text('Status history', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                for (final ev in history)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(child: Text(OrderStatus.label(ev.status))),
                        Text(Fmt.dateTime(ev.at), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
              ],
              if (onEdit != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('EDIT ORDER'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _amount(String label, double value, {bool bold = false, Color? color}) {
    final style = TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(Fmt.money(value), style: style),
        ],
      ),
    );
  }
}
