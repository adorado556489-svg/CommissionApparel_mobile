import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/store_service.dart';
import '../../services/order_service.dart';
import '../../services/catalog_service.dart';
import '../../models/team_store.dart';
import '../../models/store_item.dart';
import '../../models/parent_order.dart';
import '../../models/design_catalog.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_panel.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/storage_service.dart';

class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key});

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  TeamStore? _activeStore;
  bool _isLoading = true;
  List<StoreItem> _storeItems = [];
  List<DesignCatalog> _assignedDesigns = [];
  List<ParentOrder> _unbatchedOrders = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = context.read<AuthService>().currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final firestore = context.read<FirebaseFirestore>();

    try {
      _activeStore = await StoreService.getActiveStoreForCoach(firestore, user.id);
      if (_activeStore != null) {
        _storeItems = await StoreService.getStoreItems(firestore, _activeStore!.id);
        _assignedDesigns = await CatalogService.getAllDesignCatalog(firestore);
        _unbatchedOrders = await OrderService.getUnbatchedOrdersForStoreStream(firestore, _activeStore!.id).first;
      }
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _createStore(String name, String description) async {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;
    
    final firestore = context.read<FirebaseFirestore>();
    final newStore = TeamStore(
      id: 'store-${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      name: name,
      slug: TeamStore.generateSlug(name),
      description: description,
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await StoreService.createStore(firestore, newStore);
    await _loadData();
  }

  Future<void> _pickCoverImage() async {
    if (_activeStore == null) return;
    // We are mocking this for the test, but the requirement is to use existing StorageService logic if this were full real.
    // In Phase 3, we just pretend it uploads and update the path.
    // "Upload/select store cover image using the existing StorageService".
    // For now, I'll just change the string or wait to see what StorageService has.
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final storage = StorageService();
      final path = '/stores/${_activeStore!.id}/cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final url = await storage.uploadFile(path, File(picked.path));
      if (url != null) {
        final store = _activeStore!.copyWith(coverImagePath: url);
        await StoreService.updateStore(context.read<FirebaseFirestore>(), store);
        await _loadData();
      }
    }
  }

  Future<void> _setDeadline() async {
    if (_activeStore == null) return;
    final date = await showDatePicker(
      context: context,
      initialDate: _activeStore!.orderDeadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'CHANGE DATE',
    );
    if (date != null) {
      final store = _activeStore!.copyWith(orderDeadline: date);
      await StoreService.updateStore(context.read<FirebaseFirestore>(), store);
      await _loadData();
    }
  }

  Future<void> _addStoreItem(DesignCatalog design) async {
    if (_activeStore == null) return;
    final newItem = StoreItem(
      id: 'item-${DateTime.now().millisecondsSinceEpoch}',
      teamStoreId: _activeStore!.id,
      designCatalogId: design.id, name: design.name,
      wholesalePrice: design.wholesalePrice, retailPrice: design.wholesalePrice + 5.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await StoreService.createStoreItem(context.read<FirebaseFirestore>(), newItem);
    await _loadData();
  }

  Future<void> _removeStoreItem(String itemId) async {
    await StoreService.deleteStoreItem(context.read<FirebaseFirestore>(), itemId);
    await _loadData();
  }

  Future<void> _updateItemMarkup(StoreItem item, double retailPrice) async {
    if (retailPrice < item.wholesalePrice) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Retail price cannot be less than wholesale price.')));
      return;
    }
    final updated = item.copyWith(retailPrice: retailPrice, updatedAt: DateTime.now());
    await StoreService.updateStoreItem(context.read<FirebaseFirestore>(), updated);
    await _loadData();
  }

  Future<void> _submitMasterOrder() async {
    if (_activeStore == null) return;
    print('SUBMIT MASTER ORDER: length=${_unbatchedOrders.length}');
      if (_unbatchedOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot submit an empty roster.')));
      return;
    }
    final firestore = context.read<FirebaseFirestore>();
    final user = context.read<AuthService>().currentUser!;
    
    final batchId = 'batch-${DateTime.now().millisecondsSinceEpoch}';
    final error = await OrderService.submitStoreOrdersToAdmin(firestore, user, _activeStore!.id, batchId);
    if (error != null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    
    final updatedStore = _activeStore!.copyWith(
      status: 'submitted_to_admin',
      updatedAt: DateTime.now(),
    );
    await StoreService.updateStore(firestore, updatedStore);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Master order submitted successfully!')));
    }
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    if (user == null) {
      return const AppScaffold(title: 'My Store', body: Center(child: Text('Not Authenticated')));
    }
    if (_isLoading) return const AppScaffold(title: 'My Store', body: Center(child: CircularProgressIndicator()));

    return AppScaffold(
      title: 'My Store',
      currentNavIndex: 1, // Phase 2: Index 1 is My Store for User
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _activeStore == null ? _buildCreateStore() : _buildStoreManagement(),
      ),
    );
  }

  Widget _buildCreateStore() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create Team Store', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Store Name')),
          const SizedBox(height: 16),
          TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _createStore(nameCtrl.text, descCtrl.text),
            child: const Text('REQUEST STORE'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreManagement() {
    final store = _activeStore!;
    
    if (store.isLocked) {
      return GlassPanel(
        child: Column(
          children: [
            Text(store.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            const Text('LOCKED', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('MASTER ORDER SUBMITTED', style: TextStyle(color: Colors.red, fontSize: 18)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(store.name, style: Theme.of(context).textTheme.headlineSmall),
              Text('Status: ${store.status}', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Deadline: '),
                  Text(store.orderDeadline?.toIso8601String().substring(0, 10) ?? 'Not set'),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: _setDeadline, child: const Text('CHANGE DATE')),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _pickCoverImage, child: const Text('UPDATE COVER IMAGE')),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Store Items', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ..._assignedDesigns.map((d) {
                final isAdded = _storeItems.any((i) => i.designCatalogId == d.id);
                return ListTile(
                  title: Text(d.name),
                  subtitle: Text('Wholesale: \$${d.wholesalePrice}'),
                  trailing: isAdded
                    ? IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
                        final item = _storeItems.firstWhere((i) => i.designCatalogId == d.id);
                        _removeStoreItem(item.id);
                      })
                    : IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: () => _addStoreItem(d)),
                );
              }),
              const Divider(),
              ..._storeItems.map((item) {
                final design = _assignedDesigns.firstWhere((d) => d.id == item.designCatalogId, orElse: () => DesignCatalog(id: '', name: 'Unknown', wholesalePrice: 0, createdAt: DateTime.now(), updatedAt: DateTime.now()));
                return Row(
                  children: [
                    Expanded(child: Text(design.name)),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Retail Price'),
                        keyboardType: TextInputType.number,
                        onSubmitted: (val) {
                          if (val.isNotEmpty) _updateItemMarkup(item, double.tryParse(val) ?? item.retailPrice);
                        },
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Unbatched Orders: ${_unbatchedOrders.length}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitMasterOrder,
                child: const Text('SUBMIT MASTER ORDER'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}



