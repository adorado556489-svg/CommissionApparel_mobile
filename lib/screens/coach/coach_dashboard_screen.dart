import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/parent_order.dart';
import '../../models/team_store.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/store_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_panel.dart';
import 'widgets/coach_catalog_tab.dart';
import 'widgets/coach_collections_tab.dart';
import 'widgets/coach_earnings_tab.dart';
import 'widgets/coach_orders_tab.dart';
import 'widgets/coach_store_tab.dart';

/// Store management console for an approved coach.
///
/// Tabs: STORE (profile, deadline, payment info), PRODUCTS (designs sold),
/// COLLECTIONS, ORDERS (customer orders + master order) and EARNINGS.
class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key});

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  TeamStore? _store;
  bool _loading = true;
  String? _error;

  List<ParentOrder> _orders = const [];
  bool _ordersLoaded = false;
  StreamSubscription<List<ParentOrder>>? _ordersSub;
  String? _watchedStoreId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  /// Loads the owner's store. [showSpinner] is false for silent refreshes so
  /// the active tab keeps its state.
  Future<void> _load({bool showSpinner = true}) async {
    if (!mounted) return;
    final user = context.read<AuthService>().currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    final firestore = context.read<FirebaseFirestore>();
    if (showSpinner) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final store =
          await StoreService.getOwnerStoreIncludingArchived(firestore, user.id);
      if (!mounted) return;
      _watchOrders(firestore, store);
      setState(() {
        _store = store;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      debugPrint('CoachDashboard load failed: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load your store. Check your connection and retry.';
      });
    }
  }

  bool _isManageable(TeamStore? s) =>
      s != null && !s.isArchived && (s.isApproved || s.isLocked);

  void _watchOrders(FirebaseFirestore firestore, TeamStore? store) {
    if (!_isManageable(store)) {
      _ordersSub?.cancel();
      _ordersSub = null;
      _watchedStoreId = null;
      _orders = const [];
      _ordersLoaded = false;
      return;
    }
    if (_watchedStoreId == store!.id) return;
    _ordersSub?.cancel();
    _watchedStoreId = store.id;
    _ordersLoaded = false;
    _ordersSub = OrderService.watchOrdersForStore(firestore, store.id).listen(
      (orders) {
        if (!mounted) return;
        setState(() {
          _orders = orders;
          _ordersLoaded = true;
        });
      },
      onError: (Object e) {
        debugPrint('CoachDashboard orders stream failed: $e');
        if (!mounted) return;
        setState(() => _ordersLoaded = true);
      },
    );
  }

  int get _pendingCount =>
      _orders.where((o) => !o.isCancelled && !o.isBatched).length;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Store Management',
      currentNavIndex: 1,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return _StatePanel(
        icon: Icons.cloud_off,
        title: 'Something went wrong',
        message: _error!,
        action: ElevatedButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          label: const Text('RETRY'),
        ),
      );
    }

    final store = _store;
    if (store == null) {
      return _StatePanel(
        icon: Icons.storefront_outlined,
        title: 'You do not have a store yet',
        message:
            'Send a store request. Once an admin approves it you can add designs, share your store and collect orders.',
        action: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/user/open-store-request'),
          icon: const Icon(Icons.add_business),
          label: const Text('REQUEST A TEAM STORE'),
        ),
      );
    }

    if (store.isArchived) {
      return _StatePanel(
        icon: Icons.pause_circle_outline,
        title: '"${store.name}" is suspended',
        message:
            'An administrator has suspended this store, so it is hidden from customers. Contact support to have it restored.',
        action: OutlinedButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          label: const Text('CHECK AGAIN'),
        ),
      );
    }

    if (store.isPending) {
      return _StatePanel(
        icon: Icons.hourglass_top,
        title: '"${store.name}" is awaiting approval',
        message:
            'An admin is reviewing your request. You will get access to store management as soon as it is approved.',
        action: OutlinedButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          label: const Text('CHECK STATUS'),
        ),
      );
    }

    if (store.isDeclined) {
      final reason = (store.declineReason ?? '').trim();
      return _StatePanel(
        icon: Icons.block,
        title: '"${store.name}" was declined',
        message: reason.isEmpty
            ? 'Your request was not approved. You can submit a new request.'
            : 'Reason: $reason',
        action: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/user/open-store-request'),
          icon: const Icon(Icons.add_business),
          label: const Text('SUBMIT A NEW REQUEST'),
        ),
      );
    }

    return Column(
      children: [
        Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              const Tab(text: 'STORE'),
              const Tab(text: 'PRODUCTS'),
              const Tab(text: 'COLLECTIONS'),
              Tab(text: _pendingCount > 0 ? 'ORDERS ($_pendingCount)' : 'ORDERS'),
              const Tab(text: 'EARNINGS'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              CoachStoreTab(
                store: store,
                onChanged: () => _load(showSpinner: false),
              ),
              CoachCatalogTab(store: store),
              const CoachCollectionsTab(),
              CoachOrdersTab(
                store: store,
                orders: _orders,
                loaded: _ordersLoaded,
                onStoreChanged: () => _load(showSpinner: false),
              ),
              CoachEarningsTab(orders: _orders, loaded: _ordersLoaded),
            ],
          ),
        ),
      ],
    );
  }
}

/// Centered explanatory panel for the non-manageable store states.
class _StatePanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const _StatePanel({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: GlassPanel(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 56, color: Theme.of(context).primaryColor),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                if (action != null) ...[
                  const SizedBox(height: 20),
                  action!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
