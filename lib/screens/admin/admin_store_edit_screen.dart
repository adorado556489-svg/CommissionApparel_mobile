import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_panel.dart';
import '../../app/theme.dart';
import '../../data/dummy_stores.dart';
import '../../models/team_store.dart';
import '../../models/store_item.dart';
import '../../data/dummy_catalog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../services/store_service.dart';

class AdminStoreEditScreen extends StatefulWidget {
  final String storeId;
  const AdminStoreEditScreen({super.key, required this.storeId});

  @override
  State<AdminStoreEditScreen> createState() => _AdminStoreEditScreenState();
}

class _AdminStoreEditScreenState extends State<AdminStoreEditScreen> {
  bool _isLoading = true;
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

  Future<void> _loadStoreData() async {
    setState(() => _isLoading = true);
    final firestore = context.read<FirebaseFirestore>();
    final store = await StoreService.getStoreById(firestore, widget.storeId);
    if (store == null) {
      if (mounted) Navigator.pop(context);
      return;
    }
    _store = store;
    _storeItems = await StoreService.getStoreItems(firestore, widget.storeId);
    
    _pricingControllers.clear();
    for (var item in _storeItems) {
      _pricingControllers[item.id] = [
        TextEditingController(text: item.wholesalePrice.toString()),
        TextEditingController(text: item.retailPrice.toString()),
      ];
    }
    if (mounted) setState(() => _isLoading = false);
  }
  
  @override
  void dispose() {
    for (var controllers in _pricingControllers.values) {
      controllers[0].dispose();
      controllers[1].dispose();
    }
    super.dispose();
  }

  bool _isUploadingCover = false;

  Future<void> _pickCoverImage() async {
    final firestore = context.read<FirebaseFirestore>();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _isUploadingCover = true;
      });
      try {
        final cloudinary = CloudinaryPublic('brtamhix', 'commission_apparel', cache: false);
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(image.path, resourceType: CloudinaryResourceType.Image),
        );
        await StoreService.updateStore(firestore, _store.copyWith(coverImagePath: response.secureUrl));
        await _loadStoreData();
        if (mounted) {
          setState(() {
            _isUploadingCover = false;
          });
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cover image updated.')));
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isUploadingCover = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
        }
      }
    }
  }
  Future<void> _toggleArchive() async {
    final firestore = context.read<FirebaseFirestore>();
    await StoreService.updateStore(firestore, _store.copyWith(isArchived: !_store.isArchived));
    await _loadStoreData();
    if (mounted) {
      setState(() { _isUploadingCover = false; }); ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_store.isArchived ? 'Store archived.' : 'Store unarchived.')));
    }
  }

  Future<void> _updatePricing() async {
    final firestore = context.read<FirebaseFirestore>();
    for (var item in _storeItems) {
      if (_pricingControllers.containsKey(item.id)) {
        final wPrice = double.tryParse(_pricingControllers[item.id]![0].text) ?? item.wholesalePrice;
        final rPrice = double.tryParse(_pricingControllers[item.id]![1].text) ?? item.retailPrice;
        await StoreService.updateStoreItem(firestore, item.copyWith(wholesalePrice: wPrice, retailPrice: rPrice));
      }
    }
    await _loadStoreData();
    if (mounted) {
      setState(() { _isUploadingCover = false; }); ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Store item pricing updated.')));
    }
  }

  Future<void> _addDesignToStore(String designId) async {
    final design = dummyDesignCatalog.firstWhere((d) => d.id == designId);
    final firestore = context.read<FirebaseFirestore>();
    final newItem = StoreItem(
      id: 'item-${DateTime.now().millisecondsSinceEpoch}',
      teamStoreId: _store.id,
      designCatalogId: design.id,
      name: design.name,
      types: design.types,
      imagePaths: design.imagePaths,
      wholesalePrice: design.wholesalePrice,
      retailPrice: design.wholesalePrice + 5.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      sortOrder: 0,
      componentIds: const [],
    );
    await StoreService.createStoreItem(firestore, newItem);
    await _loadStoreData();
    if (mounted) {
      setState(() { _isUploadingCover = false; }); ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item added to store.')));
    }
  }

  Future<void> _removeStoreItem(String itemId) async {
    final firestore = context.read<FirebaseFirestore>();
    await StoreService.deleteStoreItem(firestore, itemId);
    await _loadStoreData();
    if (mounted) {
      setState(() { _isUploadingCover = false; }); ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item removed.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                    onPressed: _isUploadingCover ? null : _pickCoverImage,
                    child: Text(_isUploadingCover ? 'UPLOADING...' : 'UPDATE COVER IMAGE'),
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






