import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_panel.dart';
import '../../app/theme.dart';
import '../../data/dummy_stores.dart';
import '../../models/team_store.dart';
import '../../models/store_item.dart';
import '../../data/dummy_catalog.dart';

class AdminStoreEditScreen extends StatefulWidget {
  final String storeId;
  const AdminStoreEditScreen({super.key, required this.storeId});

  @override
  State<AdminStoreEditScreen> createState() => _AdminStoreEditScreenState();
}

class _AdminStoreEditScreenState extends State<AdminStoreEditScreen> {
  late TeamStore _store;
  late List<StoreItem> _storeItems;
  final ImagePicker _picker = ImagePicker();
  
  // Pricing controllers map: ItemId -> [WholesaleController, RetailController]
  final Map<String, List<TextEditingController>> _pricingControllers = {};

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  void _loadStoreData() {
    _store = dummyTeamStores.firstWhere((s) => s.id == widget.storeId);
    _storeItems = dummyStoreItems.where((i) => i.teamStoreId == widget.storeId).toList();
    
    _pricingControllers.clear();
    for (var item in _storeItems) {
      _pricingControllers[item.id] = [
        TextEditingController(text: item.wholesalePrice.toString()),
        TextEditingController(text: item.retailPrice.toString()),
      ];
    }
  }
  
  @override
  void dispose() {
    for (var controllers in _pricingControllers.values) {
      controllers[0].dispose();
      controllers[1].dispose();
    }
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        final index = dummyTeamStores.indexWhere((s) => s.id == _store.id);
        if (index != -1) {
          dummyTeamStores[index] = _store.copyWith(coverImagePath: image.path);
          _loadStoreData();
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cover image updated.')),
        );
      }
    }
  }

  void _toggleArchive() {
    setState(() {
      final index = dummyTeamStores.indexWhere((s) => s.id == _store.id);
      if (index != -1) {
        dummyTeamStores[index] = _store.copyWith(isArchived: !_store.isArchived);
        _loadStoreData();
      }
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_store.isArchived ? 'Store archived.' : 'Store unarchived.')),
    );
  }

  void _updatePricing() {
    // Note: Admin validation does NOT require retail >= wholesale per Laravel rules
    setState(() {
      for (var i = 0; i < dummyStoreItems.length; i++) {
        final item = dummyStoreItems[i];
        if (item.teamStoreId == _store.id && _pricingControllers.containsKey(item.id)) {
          final wPrice = double.tryParse(_pricingControllers[item.id]![0].text) ?? item.wholesalePrice;
          final rPrice = double.tryParse(_pricingControllers[item.id]![1].text) ?? item.retailPrice;
          dummyStoreItems[i] = item.copyWith(wholesalePrice: wPrice, retailPrice: rPrice);
        }
      }
      _loadStoreData();
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Store item pricing updated.')),
    );
  }

  void _addDesignToStore(String designId) {
    final design = dummyDesignCatalog.firstWhere((d) => d.id == designId);
    setState(() {
      final newItem = StoreItem(
        id: 'item-${DateTime.now().millisecondsSinceEpoch}',
        teamStoreId: _store.id,
        designCatalogId: design.id,
        name: design.name,
        types: design.types,
        imagePaths: design.imagePaths,
        wholesalePrice: design.wholesalePrice ?? 15.0,
        retailPrice: design.wholesalePrice ?? 20.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        sortOrder: 0,
        componentIds: const [],
      );
      dummyStoreItems.add(newItem);
      _loadStoreData();
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item added to store.')),
    );
  }

  void _removeStoreItem(String itemId) {
    setState(() {
      dummyStoreItems.removeWhere((i) => i.id == itemId);
      _loadStoreData();
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item removed.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Edit Store: ${_store.name}',
      currentNavIndex: 1,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text('Edit Store', style: Theme.of(context).textTheme.headlineSmall),
                ),
                ElevatedButton(
                  onPressed: _toggleArchive,
                  style: ElevatedButton.styleFrom(backgroundColor: _store.isArchived ? Colors.green : Colors.red),
                  child: Text(_store.isArchived ? 'UNARCHIVE STORE' : 'ARCHIVE STORE'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GlassPanel(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cover Image', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  if (_store.coverImagePath != null)
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: Text('Local Image Selected')),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _pickCoverImage,
                    child: const Text('UPDATE COVER IMAGE'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Update Pricing', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            GlassPanel(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ..._storeItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(item.name)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _pricingControllers[item.id]![0],
                              decoration: const InputDecoration(labelText: 'Wholesale'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _pricingControllers[item.id]![1],
                              decoration: const InputDecoration(labelText: 'Retail'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeStoreItem(item.id),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _updatePricing,
                    child: const Text('SAVE PRICING'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Package Management', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            GlassPanel(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _storeItems.where((i) => i.name.toLowerCase().contains('package')).map((package) {
                  final components = _storeItems.where((c) => package.componentIds.contains(c.id)).toList();
                  final available = _storeItems.where((c) => c.id != package.id && !package.componentIds.contains(c.id)).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(package.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ...components.map((c) => Row(
                        children: [
                          Text('- ${c.name}'),
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red, size: 16),
                            onPressed: () {
                              setState(() {
                                final index = dummyStoreItems.indexWhere((i) => i.id == package.id);
                                dummyStoreItems[index] = package.copyWith(
                                  componentIds: List.from(package.componentIds)..remove(c.id)
                                );
                                _loadStoreData();
                              });
                            }
                          )
                        ]
                      )),
                      if (available.isNotEmpty)
                        DropdownButton<String>(
                          hint: const Text('Attach Component'),
                          items: available.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                final index = dummyStoreItems.indexWhere((i) => i.id == package.id);
                                dummyStoreItems[index] = package.copyWith(
                                  componentIds: List.from(package.componentIds)..add(val)
                                );
                                _loadStoreData();
                              });
                            }
                          },
                        ),
                      const Divider(),
                    ]
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Text('Add Design to Store', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            GlassPanel(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: dummyDesignCatalog.map((design) => ListTile(
                  title: Text(design.name),
                  subtitle: Text('Base Cost: \$${design.wholesalePrice}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle, color: AppTheme.primary),
                    onPressed: () => _addDesignToStore(design.id),
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

