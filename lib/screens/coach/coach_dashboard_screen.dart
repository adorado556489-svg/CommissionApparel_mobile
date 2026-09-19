import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_panel.dart';
import '../../app/theme.dart';
import '../../models/team_store.dart';
import '../../models/store_item.dart';
import '../../models/parent_order.dart';
import '../../models/design_catalog.dart';
import '../../data/dummy_stores.dart';
import '../../data/dummy_orders.dart';
import '../../data/dummy_catalog.dart';

class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key});

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  String _activeTab = 'overview';
  
  TeamStore? _activeStore;
  List<StoreItem> _storeItems = [];
  List<ParentOrder> _unbatchedOrders = [];
  List<DesignCatalog> _assignedDesigns = [];
  
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;

    // Find active store
    try {
      _activeStore = dummyTeamStores.firstWhere(
        (s) => s.userId == user.id && !s.isArchived,
      );
    } catch (_) {
      _activeStore = null;
    }

    if (_activeStore != null) {
      _storeItems = dummyStoreItems.where((i) => i.teamStoreId == _activeStore!.id).toList();
      _unbatchedOrders = dummyParentOrders.where((o) => o.teamStoreId == _activeStore!.id && o.batchId == null).toList();
    } else {
      _storeItems = [];
      _unbatchedOrders = [];
    }

    // Assume first 3 are assigned to coach
    _assignedDesigns = dummyDesignCatalog.where((d) => user.assignedDesignIds.contains(d.id)).toList();
    
    setState(() {});
  }

  void _createStore(String name, String desc, String packageType) {
    final user = context.read<AuthService>().currentUser;
    if (user == null || _activeStore != null) return;

    final newStore = TeamStore(
      id: 'store-${Random().nextInt(10000)}',
      userId: user.id,
      name: name,
      slug: TeamStore.generateSlug(name),
      description: desc,
      packageType: packageType,
      status: 'pending',
      pricingApproved: false,
      isArchived: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      dummyTeamStores.add(newStore);
      _activeStore = newStore;
    });
  }

  Future<void> _pickCoverImage() async {
    if (_activeStore == null) return;
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          final updated = _activeStore!.copyWith(coverImagePath: pickedFile.path);
          final idx = dummyTeamStores.indexWhere((s) => s.id == _activeStore!.id);
          if (idx != -1) dummyTeamStores[idx] = updated;
          _activeStore = updated;
        });
      }
    } catch (_) {}
  }

  Future<void> _setDeadline() async {
    if (_activeStore == null) return;
    final date = await showDatePicker(
      context: context,
      initialDate: _activeStore!.orderDeadline ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        final updated = _activeStore!.copyWith(orderDeadline: date);
        final idx = dummyTeamStores.indexWhere((s) => s.id == _activeStore!.id);
        if (idx != -1) dummyTeamStores[idx] = updated;
        _activeStore = updated;
      });
    }
  }

  void _addStoreItem(DesignCatalog design) {
    if (_activeStore == null) return;
    final newItem = StoreItem(
      id: 'item-${Random().nextInt(10000)}',
      teamStoreId: _activeStore!.id,
      designCatalogId: design.id,
      name: design.name,

      types: design.types,
      imagePaths: design.imagePaths,
      wholesalePrice: design.wholesalePrice ?? 20.0,
      retailPrice: design.wholesalePrice ?? 20.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      sortOrder: 0,
      componentIds: const [],
    );
    
    setState(() {
      dummyStoreItems.add(newItem);
      _storeItems.add(newItem);
    });
  }

  void _removeStoreItem(String itemId) {
    setState(() {
      dummyStoreItems.removeWhere((i) => i.id == itemId);
      _storeItems.removeWhere((i) => i.id == itemId);
    });
  }

  void _updateItemMarkup(StoreItem item, double newRetail) {
    if (newRetail < item.wholesalePrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Retail price cannot be less than wholesale price.')),
      );
      return;
    }
    
    setState(() {
      final updated = item.copyWith(retailPrice: newRetail);
      final idxGlobal = dummyStoreItems.indexWhere((i) => i.id == item.id);
      if (idxGlobal != -1) dummyStoreItems[idxGlobal] = updated;
      
      final idxLocal = _storeItems.indexWhere((i) => i.id == item.id);
      if (idxLocal != -1) _storeItems[idxLocal] = updated;
    });
  }
  
  void _bulkMarkup(double additionalAmount) {
    for (var item in _storeItems) {
      _updateItemMarkup(item, item.retailPrice + additionalAmount);
    }
  }

  void _approvePricing() {
    if (_activeStore == null) return;
    setState(() {
      final updated = _activeStore!.copyWith(pricingApproved: true);
      final idx = dummyTeamStores.indexWhere((s) => s.id == _activeStore!.id);
      if (idx != -1) dummyTeamStores[idx] = updated;
      _activeStore = updated;
    });
  }

  void _submitMasterOrder() {
    if (_activeStore == null || _unbatchedOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot submit an empty roster.')),
      );
      return;
    }

    final batchId = 'batch-${Random().nextInt(10000)}';

    setState(() {
      final updatedStore = _activeStore!.copyWith(status: 'submitted_to_admin');
      final storeIdx = dummyTeamStores.indexWhere((s) => s.id == _activeStore!.id);
      if (storeIdx != -1) dummyTeamStores[storeIdx] = updatedStore;
      _activeStore = updatedStore;

      for (var order in _unbatchedOrders) {
        final idx = dummyParentOrders.indexWhere((o) => o.id == order.id);
        if (idx != -1) {
          dummyParentOrders[idx] = order.copyWith(
            status: 'Submitted to Admin',
            batchId: batchId,
          );
        }
      }
      
      _unbatchedOrders = dummyParentOrders.where((o) => o.teamStoreId == _activeStore!.id && o.batchId == null).toList();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Master order submitted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Coach Dashboard',
      currentNavIndex: 1,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTabs(),
            const SizedBox(height: 24),
            if (_activeTab == 'overview') _buildOverviewTab(),
            if (_activeTab == 'create_order') _buildPlaceholderTab('Create Order'),
            if (_activeTab == 'sales') _buildPlaceholderTab('Sales'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        _tabButton('Overview', 'overview'),
        const SizedBox(width: 12),
        _tabButton('Create Order', 'create_order'),
        const SizedBox(width: 12),
        _tabButton('Sales', 'sales'),
      ],
    );
  }

  Widget _tabButton(String label, String id) {
    final isActive = _activeTab == id;
    return InkWell(
      onTap: () => setState(() => _activeTab = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppTheme.textMuted,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab(String title) {
    return GlassPanel(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text('$title - Coming Soon', style: Theme.of(context).textTheme.titleMedium),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_activeStore == null) {
      return _buildCreateStoreView();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStoreStatusCard(),
        const SizedBox(height: 24),
        _buildStoreSettingsCard(),
        const SizedBox(height: 24),
        _buildStoreItemsCard(),
      ],
    );
  }

  Widget _buildCreateStoreView() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create Team Store', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Store Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descCtrl,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                _createStore(nameCtrl.text, descCtrl.text, 'individual');
              }
            },
            child: const Text('REQUEST STORE'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreStatusCard() {
    final store = _activeStore!;
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(store.name, style: Theme.of(context).textTheme.titleLarge),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: store.isLive ? Colors.green : (store.isLocked ? Colors.blue : Colors.orange),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  store.isLive ? 'LIVE' : (store.isLocked ? 'LOCKED' : store.status.toUpperCase()),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text('Unbatched Orders: ${_unbatchedOrders.length}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: store.isLocked ? null : _submitMasterOrder,
            style: ElevatedButton.styleFrom(backgroundColor: store.isLocked ? Colors.grey : AppTheme.primary),
            child: Text(store.isLocked ? 'MASTER ORDER SUBMITTED' : 'SUBMIT MASTER ORDER'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreSettingsCard() {
    final store = _activeStore!;
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Store Settings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Deadline'),
                    Text(
                      store.orderDeadline != null 
                        ? '${store.orderDeadline!.month}/${store.orderDeadline!.day}/${store.orderDeadline!.year}'
                        : 'Not set',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: _setDeadline,
                child: const Text('CHANGE DATE'),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cover Image'),
                    Text(
                      store.coverImagePath != null ? 'Local file selected' : 'No image',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: _pickCoverImage,
                child: const Text('UPLOAD IMAGE'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreItemsCard() {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('Store Items & Pricing', style: Theme.of(context).textTheme.titleLarge, overflow: TextOverflow.ellipsis)),
              if (!_activeStore!.pricingApproved)
                ElevatedButton(
                  onPressed: _approvePricing,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('APPROVE PRICING'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: const Text('Bulk Markup')),
              Row(
                children: [
                  OutlinedButton(onPressed: () => _bulkMarkup(5.0), child: const Text('+\$5')),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: () => _bulkMarkup(10.0), child: const Text('+\$10')),
                ],
              )
            ],
          ),
          const Divider(height: 32),
          ..._storeItems.map((item) => _buildItemRow(item)).toList(),
          const SizedBox(height: 16),
          const Text('Available Designs:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._assignedDesigns.map((design) {
            final isAdded = _storeItems.any((i) => i.designCatalogId == design.id);
            return ListTile(
              title: Text(design.name),
              subtitle: Text('Wholesale: \$${design.wholesalePrice?.toStringAsFixed(2)}'),
              trailing: isAdded
                ? const Icon(Icons.check, color: Colors.green)
                : IconButton(
                    icon: const Icon(Icons.add_circle, color: AppTheme.secondary),
                    onPressed: () => _addStoreItem(design),
                  ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildItemRow(StoreItem item) {
    final ctrl = TextEditingController(text: item.retailPrice.toStringAsFixed(2));
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(item.name, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: Text('W: \$${item.wholesalePrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: TextField(
              controller: ctrl,
              decoration: const InputDecoration(labelText: 'Retail', isDense: true),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onSubmitted: (val) {
                final numVal = double.tryParse(val);
                if (numVal != null) {
                  _updateItemMarkup(item, numVal);
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _removeStoreItem(item.id),
          )
        ],
      ),
    );
  }
}
