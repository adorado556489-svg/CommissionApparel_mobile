import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../models/design_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../services/catalog_service.dart';
import '../../../services/auth_service.dart';

class CoachCollectionsTab extends StatefulWidget {
  const CoachCollectionsTab({super.key});

  @override
  State<CoachCollectionsTab> createState() => _CoachCollectionsTabState();
}

class _CoachCollectionsTabState extends State<CoachCollectionsTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sortOrderController = TextEditingController();
  List<DesignCollection> _collections = [];
  bool _isLoading = true;

  Future<void> _loadData() async {
    final firestore = context.read<FirebaseFirestore>();
    final cols = await CatalogService.getCoachDesignCollections(firestore, context.read<AuthService>().currentUser!.id);
    if (mounted) {
      setState(() {
        cols.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        _collections = cols;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _createCollection() async {
    if (_formKey.currentState!.validate()) {
      final newCol = DesignCollection(coachId: context.read<AuthService>().currentUser!.id, 
        id: 'col-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        sortOrder: int.tryParse(_sortOrderController.text) ?? 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await CatalogService.createDesignCollection(context.read<FirebaseFirestore>(), newCol);
      await _loadData();
      
      _nameController.clear();
      _sortOrderController.clear();
      _loadData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Collection "${newCol.name}" created.')),
      );
    }
  }

  void _editCollection(DesignCollection col) {
    _nameController.text = col.name;
    _sortOrderController.text = col.sortOrder.toString();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Collection'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Collection Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _sortOrderController,
                decoration: const InputDecoration(labelText: 'Sort Order'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final firestore = context.read<FirebaseFirestore>();
                final updated = col.copyWith(
                  name: _nameController.text,
                  sortOrder: int.tryParse(_sortOrderController.text) ?? 0,
                );
                await CatalogService.updateDesignCollection(firestore, updated);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  _nameController.clear();
                  _sortOrderController.clear();
                }
                await _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Collection updated.')));
                }
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _deleteCollection(DesignCollection col) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Collection?'),
        content: const Text('Designs in this collection will NOT be deleted, but will lose their collection grouping.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              final firestore = context.read<FirebaseFirestore>();
              // 1. Orphan designs
              final allCatalog = await CatalogService.getAllDesignCatalog(firestore);
              for (var design in allCatalog) {
                if (design.designCollectionId == col.id) {
                  final updated = design.copyWith(designCollectionId: null, clearCollectionId: true);
                  await CatalogService.updateDesignCatalogItem(firestore, updated);
                }
              }
              // 2. Delete collection
              await CatalogService.deleteDesignCollection(firestore, col.id);
              if (ctx.mounted) Navigator.pop(ctx);
              _loadData();
              if (!mounted) return;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Collection deleted.')),
              );
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(child: Column(
      children: [
        ExpansionTile(
          title: const Text('CREATE NEW COLLECTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Collection Name'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _sortOrderController,
                      decoration: const InputDecoration(labelText: 'Sort Order'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _createCollection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: const Text('SAVE COLLECTION'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._collections.map((col) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(col.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Sort Order: ${col.sortOrder}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editCollection(col)),
              IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteCollection(col),
            ),
            ]),
          ),
        )),
      ],
    ));
  }
}




