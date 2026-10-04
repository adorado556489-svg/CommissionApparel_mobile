import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../constants/statuses.dart';
import '../../models/parent_order.dart';
import '../../models/team_store.dart';
import '../../models/user.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/store_service.dart';
import '../../services/user_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/managed_image.dart';
import '../../widgets/status_chip.dart';

/// Platform-operator console.
///
/// The admin approves store requests, monitors every store and master order,
/// moves master orders through production and tracks platform revenue.
/// Merchant work (creating stores/products, pricing) belongs to coaches.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  bool _loading = true;
  String? _error;
  List<TeamStore> _stores = [];
  List<ParentOrder> _batched = [];
  Map<String, User> _owners = {};
  bool _showDelivered = false;
  final Set<String> _busy = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    final firestore = context.read<FirebaseFirestore>();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        StoreService.getAllStores(firestore),
        OrderService.getBatchedOrders(firestore),
      ]);
      final stores = results[0] as List<TeamStore>;
      final owners = await UserService.getUsersByIds(firestore, stores.map((s) => s.userId));
      if (!mounted) return;
      setState(() {
        _stores = stores;
        _batched = results[1] as List<ParentOrder>;
        _owners = owners;
        _loading = false;
      });
    } catch (e) {
      debugPrint('AdminDashboard load failed: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Could not load dashboard data. Pull down to retry.';
        _loading = false;
      });
    }
  }

  // ---------------------------------------------------------------- actions

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _run(String key, Future<String?> Function() action, String success) async {
    if (_busy.contains(key)) return;
    setState(() => _busy.add(key));
    final error = await action();
    if (!mounted) return;
    setState(() => _busy.remove(key));
    _toast(error ?? success);
    if (error == null) await _load();
  }

  Future<bool> _confirm(String title, String message, {String action = 'CONFIRM', bool destructive = false}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: destructive ? ElevatedButton.styleFrom(backgroundColor: Colors.red) : null,
            child: Text(action),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _approve(TeamStore store) async {
    final admin = context.read<AuthService>().currentUser;
    if (admin == null) return;
    final ok = await _confirm(
      'Approve "${store.name}"?',
      'The store goes live for customers and its owner is upgraded to Coach so they can manage it.',
    );
    if (!ok || !mounted) return;
    final firestore = context.read<FirebaseFirestore>();
    await _run('approve-${store.id}', () => AdminService.approveStore(firestore, admin, store),
        'Store "${store.name}" approved. ${_ownerName(store.userId)} is now a Coach.');
  }

  Future<void> _decline(TeamStore store) async {
    final admin = context.read<AuthService>().currentUser;
    if (admin == null) return;
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => const _ReasonDialog(),
    );
    if (reason == null || !mounted) return;
    final firestore = context.read<FirebaseFirestore>();
    await _run('decline-${store.id}', () => AdminService.declineStore(firestore, admin, store, reason: reason),
        'Store "${store.name}" declined.');
  }

  Future<void> _toggleSuspend(TeamStore store) async {
    final admin = context.read<AuthService>().currentUser;
    if (admin == null) return;
    final suspend = !store.isArchived;
    final ok = await _confirm(
      suspend ? 'Suspend "${store.name}"?' : 'Restore "${store.name}"?',
      suspend
          ? 'The store is hidden from customers and the coach cannot edit or sell until it is restored.'
          : 'The store becomes visible again and the coach can resume managing it.',
      action: suspend ? 'SUSPEND' : 'RESTORE',
      destructive: suspend,
    );
    if (!ok || !mounted) return;
    final firestore = context.read<FirebaseFirestore>();
    await _run('suspend-${store.id}', () => AdminService.setStoreArchived(firestore, admin, store, suspend),
        suspend ? 'Store suspended.' : 'Store restored.');
  }

  // ---------------------------------------------------------------- helpers

  String _ownerName(String userId) {
    final u = _owners[userId];
    if (u == null) return 'The owner';
    final name = u.fullName.trim();
    return name.isEmpty ? u.email : name;
  }

  String _storeName(String? storeId, {String? fallback}) {
    for (final s in _stores) {
      if (s.id == storeId) return s.name;
    }
    return fallback ?? 'Unknown store';
  }

  /// Orders grouped by master order, newest activity first.
  List<MapEntry<String, List<ParentOrder>>> _batches() {
    final map = <String, List<ParentOrder>>{};
    for (final o in _batched) {
      if (o.batchId == null || o.isCancelled) continue;
      map.putIfAbsent(o.batchId!, () => []).add(o);
    }
    final list = map.entries.toList()
      ..sort((a, b) => _latest(b.value).compareTo(_latest(a.value)));
    return list;
  }

  DateTime _latest(List<ParentOrder> orders) =>
      orders.map((o) => o.updatedAt).reduce((a, b) => a.isAfter(b) ? a : b);

  /// A master order is as far along as its slowest order.
  String _batchStatus(List<ParentOrder> orders) {
    var slowest = orders.first.status;
    for (final o in orders) {
      if (OrderStatus.stepIndex(o.status) < OrderStatus.stepIndex(slowest)) slowest = o.status;
    }
    return OrderStatus.normalize(slowest);
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final pending = _stores.where((s) => s.isPending).length;
    return AppScaffold(
      title: 'Admin Dashboard',
      currentNavIndex: 1,
      actions: [
        IconButton(icon: const Icon(Icons.refresh), tooltip: 'Refresh', onPressed: _loading ? null : _load),
      ],
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textMuted,
            indicatorColor: AppTheme.primary,
            tabs: [
              Tab(text: pending > 0 ? 'OVERVIEW ($pending)' : 'OVERVIEW'),
              const Tab(text: 'STORES'),
              const Tab(text: 'ORDERS'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _scrollable(_buildOverviewTab()),
                _scrollable(_buildStoresTab()),
                _scrollable(_buildOrdersTab()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Wraps a tab body so it supports pull-to-refresh, loading and error states.
  Widget _scrollable(List<Widget> children) {
    if (_loading && _stores.isEmpty && _batched.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ),
          ...children,
        ],
      ),
    );
  }

  // --------------------------------------------------------------- overview

  List<Widget> _buildOverviewTab() {
    final pending = _stores.where((s) => s.isPending).toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final active = _stores.where((s) => (s.isApproved || s.isLocked) && !s.isArchived).length;
    final batches = _batches();
    final inProgress = batches.where((b) => !OrderStatus.isFinal(_batchStatus(b.value))).length;
    final fin = ParentOrder.calculateBatchFinancials(orders: batches.expand((b) => b.value).toList());

    return [
      KpiWrap(cards: [
        KpiCard(label: 'Pending approvals', value: '${pending.length}', icon: Icons.pending_actions, color: Colors.orange),
        KpiCard(label: 'Active stores', value: '$active', icon: Icons.storefront, color: Colors.green),
        KpiCard(label: 'Master orders in progress', value: '$inProgress', icon: Icons.local_shipping_outlined, color: Colors.indigo),
        KpiCard(label: 'Platform revenue (base cost)', value: Fmt.money(fin.totalWholesaleCost), icon: Icons.account_balance_wallet_outlined, color: Colors.blue),
        KpiCard(label: 'Coach commissions', value: Fmt.money(fin.netProceeds), icon: Icons.savings_outlined, color: Colors.teal),
        KpiCard(label: 'Gross customer sales', value: Fmt.money(fin.totalSales), icon: Icons.payments_outlined),
      ]),
      const SizedBox(height: 24),
      Text('Stores awaiting approval', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      if (pending.isEmpty)
        const Text('No pending requests. New store requests will appear here.', style: TextStyle(color: AppTheme.textMuted))
      else
        ...pending.map(_pendingCard),
    ];
  }

  Widget _pendingCard(TeamStore store) {
    final busy = _busy.contains('approve-${store.id}') || _busy.contains('decline-${store.id}');
    final owner = _owners[store.userId];
    return GlassPanel(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(store.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            'Requested by ${_ownerName(store.userId)}${owner != null ? ' (${owner.email})' : ''} on ${Fmt.date(store.createdAt)}',
            style: const TextStyle(color: AppTheme.textMuted),
          ),
          if ((store.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(store.description!, maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: busy ? null : () => _approve(store),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('APPROVE'),
              ),
              OutlinedButton(
                onPressed: busy ? null : () => _decline(store),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                child: const Text('DECLINE'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------- stores

  List<Widget> _buildStoresTab() {
    final stores = _stores.where((s) => !s.isPending).toList();
    return [
      Text('All stores', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 4),
      const Text('Read-only monitoring. Stores are managed by their coaches; you can suspend a store if needed.',
          style: TextStyle(color: AppTheme.textMuted)),
      const SizedBox(height: 12),
      if (stores.isEmpty)
        const Text('No stores yet.', style: TextStyle(color: AppTheme.textMuted))
      else
        ...stores.map(_storeCard),
    ];
  }

  Widget _storeCard(TeamStore store) {
    final busy = _busy.contains('suspend-${store.id}');
    return GlassPanel(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppImage(
                store.logoPath,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(10),
                placeholderIcon: Icons.storefront,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(store.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('Coach: ${_ownerName(store.userId)}', style: const TextStyle(color: AppTheme.textMuted)),
                    Text('Deadline: ${Fmt.date(store.orderDeadline)}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              StatusChip(label: StoreStatus.label(store.status), color: StoreStatus.color(store.status)),
              if (store.isArchived) const StatusChip(label: 'Suspended', color: Colors.red, icon: Icons.block),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/store/detail', arguments: store.id),
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('VIEW STOREFRONT'),
              ),
              if (!store.isDeclined)
                OutlinedButton.icon(
                  onPressed: busy ? null : () => _toggleSuspend(store),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: store.isArchived ? Colors.green : Colors.red,
                    side: BorderSide(color: store.isArchived ? Colors.green : Colors.red),
                  ),
                  icon: Icon(store.isArchived ? Icons.restore : Icons.block, size: 18),
                  label: Text(store.isArchived ? 'RESTORE' : 'SUSPEND'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------- orders

  List<Widget> _buildOrdersTab() {
    final all = _batches();
    final batches = _showDelivered ? all : all.where((b) => _batchStatus(b.value) != OrderStatus.delivered).toList();
    return [
      Row(
        children: [
          Expanded(child: Text('Master orders', style: Theme.of(context).textTheme.titleLarge)),
          const Text('Show delivered'),
          Switch(value: _showDelivered, onChanged: (v) => setState(() => _showDelivered = v)),
        ],
      ),
      const SizedBox(height: 8),
      if (batches.isEmpty)
        const Text('No master orders yet. They appear here when a coach submits their store orders.',
            style: TextStyle(color: AppTheme.textMuted))
      else
        ...batches.map((e) => _batchCard(e.key, e.value)),
    ];
  }

  Widget _batchCard(String batchId, List<ParentOrder> orders) {
    final status = _batchStatus(orders);
    final fin = ParentOrder.calculateBatchFinancials(orders: orders);
    final storeId = orders.first.teamStoreId;
    final name = _storeName(storeId, fallback: orders.first.storeName);
    return GlassPanel(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              const SizedBox(width: 8),
              StatusChip(label: OrderStatus.label(status), color: OrderStatus.color(status)),
            ],
          ),
          const SizedBox(height: 2),
          Text('Batch ${_shortId(batchId)}  -  ${fin.orderCount} athletes  -  ${fin.totalItemsSold} items',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _figure('Gross sales', Fmt.money(fin.totalSales)),
              _figure('Platform revenue', Fmt.money(fin.totalWholesaleCost), color: Colors.blue),
              _figure('Coach commission', Fmt.money(fin.netProceeds), color: Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/admin/batch/show', arguments: batchId);
              if (mounted) _load();
            },
            child: Text(OrderStatus.next(status) == null ? 'VIEW DETAILS' : 'VIEW / UPDATE STATUS'),
          ),
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

  String _shortId(String id) => id.length <= 12 ? id : id.substring(id.length - 12);
}

/// Asks the admin for an optional reason when declining a store request.
class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog();

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Decline store request'),
      content: SingleChildScrollView(
        child: TextField(
          controller: _controller,
          maxLines: 3,
          maxLength: 200,
          decoration: const InputDecoration(
            labelText: 'Reason (shown to the requester)',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('DECLINE'),
        ),
      ],
    );
  }
}
