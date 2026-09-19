import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../models/design_collection.dart';
import '../../../data/dummy_catalog.dart';

class AdminCollectionsTab extends StatefulWidget {
  const AdminCollectionsTab({super.key});

  @override
  State<AdminCollectionsTab> createState() => _AdminCollectionsTabState();
}

class _AdminCollectionsTabState extends State<AdminCollectionsTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sortOrderController = TextEditingController();

  void _loadData() {
    setState(() {
      dummyDesignCollections.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _createCollection() {
    if (_formKey.currentState!.validate()) {
      final newCol = DesignCollection(
        id: 'col-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        sortOrder: int.tryParse(_sortOrderController.text) ?? 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      dummyDesignCollections.add(newCol);
      
      _nameController.clear();
      _sortOrderController.clear();
      _loadData();

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
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final index = dummyDesignCollections.indexWhere((c) => c.id == col.id);
                if (index != -1) {
                  dummyDesignCollections[index] = dummyDesignCollections[index].copyWith(
                    name: _nameController.text,
                    sortOrder: int.tryParse(_sortOrderController.text) ?? 0,
                  );
                }
                Navigator.pop(ctx);
                _nameController.clear();
                _sortOrderController.clear();
                _loadData();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Collection updated.')));
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
            onPressed: () {
              // 1. Orphan designs
              for (int i = 0; i < dummyDesignCatalog.length; i++) {
                if (dummyDesignCatalog[i].designCollectionId == col.id) {
                  dummyDesignCatalog[i] = dummyDesignCatalog[i].copyWith(
                    designCollectionId: null,
                    clearCollectionId: true,
                  );
                }
              }
              // 2. Delete collection
              dummyDesignCollections.removeWhere((c) => c.id == col.id);
              Navigator.pop(ctx);
              _loadData();
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
        ...dummyDesignCollections.map((col) => Card(
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
        )).toList(),
      ],
    ));
  }
}
