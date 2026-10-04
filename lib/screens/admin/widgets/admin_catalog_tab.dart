import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/catalog_service.dart';
import '../../../models/design_collection.dart';
import '../../../app/theme.dart';
import '../../../models/design_catalog.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/managed_image.dart';

class AdminCatalogTab extends StatefulWidget {
  const AdminCatalogTab({super.key});

  @override
  State<AdminCatalogTab> createState() => _AdminCatalogTabState();
}

class _AdminCatalogTabState extends State<AdminCatalogTab> {
  final _formKey = GlobalKey<FormState>();
  final _editFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sportController = TextEditingController();
  final _wholesaleController = TextEditingController();
  final _sortOrderController = TextEditingController();

  String? _selectedCollectionId;
  String _selectedCategory = 'individual';
  final List<String> _selectedTypes = [];
  bool _hasNameField = false;
  bool _hasNumberField = false;

  List<DesignCatalog> _catalogItems = [];
  List<DesignCollection> _collections = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final firestore = context.read<FirebaseFirestore>();
    final items = await CatalogService.getAllDesignCatalog(firestore);
    final cols = await CatalogService.getAllDesignCollections(firestore);
    if (mounted) {
      setState(() {
        _catalogItems = items;
        _collections = cols;
      });
    }
  }

  List<String> _imagePaths = [];

  final List<String> _availableTypes = [
    'Jersey',
    'Shorts',
    'Hoodie',
    'Pants',
    'T-Shirt',
    'Warmup Top',
    'Warmup Bottom',
    'Accessory',
    'Backpack',
  ];

  bool _isUploadingImage = false;

  Future<void> _pickImage() async {
    setState(() => _isUploadingImage = true);
    try {
      final url = await StorageService().pickAndUpload(
        folder: 'catalog/designs',
      );
      if (url != null && mounted) setState(() => _imagePaths = [url]);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _createDesign() async {
    final firestore = context.read<FirebaseFirestore>();
    if (_formKey.currentState!.validate() && _selectedTypes.isNotEmpty) {
      final newDesign = DesignCatalog(
        id: firestore.collection('designCatalog').doc().id,
        name: _nameController.text,
        designCollectionId: _selectedCollectionId,
        sport: _sportController.text.isEmpty ? null : _sportController.text,
        category: _selectedCategory,
        types: List.from(_selectedTypes),
        wholesalePrice: double.tryParse(_wholesaleController.text) ?? 0.0,
        hasNameField: _hasNameField,
        hasNumberField: _hasNumberField,
        sortOrder: int.tryParse(_sortOrderController.text) ?? 0,
        imagePaths: _imagePaths,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      try {
        await CatalogService.createDesignCatalogItem(firestore, newDesign);
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Could not save design: $e')));
        return;
      }
      await _loadData();

      _nameController.clear();
      _sportController.clear();
      _wholesaleController.clear();
      _sortOrderController.clear();
      setState(() {
        _selectedCollectionId = null;
        _selectedCategory = 'individual';
        _selectedTypes.clear();
        _hasNameField = false;
        _hasNumberField = false;
        _imagePaths = [];
      });
      _loadData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Design "${newDesign.name}" created.')),
      );
    } else if (_selectedTypes.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one garment type.'),
        ),
      );
    }
  }

  void _editDesign(DesignCatalog design) {
    _nameController.text = design.name;
    _sportController.text = design.sport ?? '';
    _wholesaleController.text = design.wholesalePrice.toString();
    _sortOrderController.text = design.sortOrder.toString();
    _selectedCollectionId = design.designCollectionId;
    _selectedCategory = design.category;
    _selectedTypes.clear();
    _selectedTypes.addAll(design.types);
    _hasNameField = design.hasNameField;
    _hasNumberField = design.hasNumberField;
    _imagePaths = List.from(design.imagePaths);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Design'),
          content: SingleChildScrollView(
            child: Form(
              key: _editFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Design Name'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  DropdownButtonFormField<String?>(
                    initialValue: _selectedCollectionId,
                    decoration: const InputDecoration(labelText: 'Collection'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('None (Orphaned)'),
                      ),
                      ..._collections.map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ),
                    ],
                    onChanged: (v) =>
                        setDialogState(() => _selectedCollectionId = v),
                  ),
                  TextFormField(
                    controller: _sportController,
                    decoration: const InputDecoration(
                      labelText: 'Sport (Optional)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _availableTypes
                        .map(
                          (type) => FilterChip(
                            label: Text(type),
                            selected: _selectedTypes.contains(type),
                            onSelected: (val) {
                              setDialogState(() {
                                if (val) {
                                  _selectedTypes.add(type);
                                } else {
                                  _selectedTypes.remove(type);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const [
                      DropdownMenuItem(
                        value: 'individual',
                        child: Text('Individual Item'),
                      ),
                      DropdownMenuItem(
                        value: 'package_a',
                        child: Text('Package A'),
                      ),
                      DropdownMenuItem(
                        value: 'package_b',
                        child: Text('Package B'),
                      ),
                      DropdownMenuItem(
                        value: 'package_c',
                        child: Text('Package C'),
                      ),
                    ],
                    onChanged: (v) =>
                        setDialogState(() => _selectedCategory = v!),
                  ),
                  TextFormField(
                    controller: _wholesaleController,
                    decoration: const InputDecoration(
                      labelText: 'Wholesale Price (\$)',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _sortOrderController,
                    decoration: const InputDecoration(labelText: 'Sort Order'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  if (_imagePaths.isNotEmpty)
                    AppImage(
                      _imagePaths.first,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  OutlinedButton.icon(
                    onPressed: _isUploadingImage
                        ? null
                        : () async {
                            setDialogState(() => _isUploadingImage = true);
                            try {
                              final url = await StorageService().pickAndUpload(
                                folder: 'catalog/designs',
                              );
                              if (url != null && ctx.mounted)
                                setDialogState(() => _imagePaths = [url]);
                            } catch (e) {
                              if (ctx.mounted)
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text('$e')));
                            } finally {
                              if (ctx.mounted)
                                setDialogState(() => _isUploadingImage = false);
                            }
                          },
                    icon: const Icon(Icons.image_outlined),
                    label: Text(
                      _imagePaths.isEmpty
                          ? 'Add design image'
                          : 'Change design image',
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Has Name Field?'),
                    value: _hasNameField,
                    onChanged: (v) => setDialogState(() => _hasNameField = v),
                  ),
                  SwitchListTile(
                    title: const Text('Has Number Field?'),
                    value: _hasNumberField,
                    onChanged: (v) => setDialogState(() => _hasNumberField = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                if (_editFormKey.currentState!.validate() &&
                    _selectedTypes.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Select at least one garment type.'),
                    ),
                  );
                  return;
                }
                if (_editFormKey.currentState!.validate()) {
                  final updated = design.copyWith(
                    name: _nameController.text,
                    sport: _sportController.text.isEmpty
                        ? null
                        : _sportController.text,
                    category: _selectedCategory,
                    types: List.from(_selectedTypes),
                    wholesalePrice:
                        double.tryParse(_wholesaleController.text) ?? 0.0,
                    hasNameField: _hasNameField,
                    hasNumberField: _hasNumberField,
                    designCollectionId: _selectedCollectionId,
                    clearCollectionId: _selectedCollectionId == null,
                    imagePaths: _imagePaths,
                    sortOrder: int.tryParse(_sortOrderController.text) ?? 0,
                    updatedAt: DateTime.now(),
                  );
                  final firestore = context.read<FirebaseFirestore>();
                  try {
                    await CatalogService.updateDesignCatalogItem(
                      firestore,
                      updated,
                    );
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    await _loadData();
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('Could not update design: $e')),
                      );
                    }
                    return;
                  }
                  _nameController.clear();
                  _sportController.clear();
                  _wholesaleController.clear();
                  _sortOrderController.clear();
                  if (!ctx.mounted) return;
                  ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Design updated.')),
                  );
                }
              },
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteDesign(DesignCatalog design) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Design?'),
        content: const Text(
          'This removes the design from the shared catalog. Existing products in team stores remain available with their saved images and pricing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              final firestore = context.read<FirebaseFirestore>();
              await CatalogService.deleteDesignCatalogItem(
                firestore,
                design.id,
              );
              await _loadData();

              if (ctx.mounted) Navigator.pop(ctx);
              _loadData();
              if (!mounted) return;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Design removed from the shared catalog. Existing store products were kept.',
                  ),
                ),
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
    return SingleChildScrollView(
      child: Column(
        children: [
          ExpansionTile(
            title: const Text(
              'CREATE NEW DESIGN',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Design Name',
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      DropdownButtonFormField<String?>(
                        initialValue: _selectedCollectionId,
                        decoration: const InputDecoration(
                          labelText: 'Collection',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('None (Orphaned)'),
                          ),
                          ..._collections.map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedCollectionId = v),
                      ),
                      TextFormField(
                        controller: _sportController,
                        decoration: const InputDecoration(
                          labelText: 'Sport (Optional)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Garment Types',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        children: _availableTypes
                            .map(
                              (type) => FilterChip(
                                label: Text(type),
                                selected: _selectedTypes.contains(type),
                                onSelected: (val) {
                                  setState(() {
                                    if (val) {
                                      _selectedTypes.add(type);
                                    } else {
                                      _selectedTypes.remove(type);
                                    }
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'individual',
                            child: Text('Individual Item'),
                          ),
                          DropdownMenuItem(
                            value: 'package_a',
                            child: Text('Package A'),
                          ),
                          DropdownMenuItem(
                            value: 'package_b',
                            child: Text('Package B'),
                          ),
                          DropdownMenuItem(
                            value: 'package_c',
                            child: Text('Package C'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedCategory = v!),
                      ),
                      TextFormField(
                        controller: _wholesaleController,
                        decoration: const InputDecoration(
                          labelText: 'Wholesale Price (\$)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      SwitchListTile(
                        title: const Text('Has Name Field?'),
                        value: _hasNameField,
                        onChanged: (v) => setState(() => _hasNameField = v),
                      ),
                      SwitchListTile(
                        title: const Text('Has Number Field?'),
                        value: _hasNumberField,
                        onChanged: (v) => setState(() => _hasNumberField = v),
                      ),
                      TextFormField(
                        controller: _sortOrderController,
                        decoration: const InputDecoration(
                          labelText: 'Sort Order',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isUploadingImage ? null : _pickImage,
                        icon: _isUploadingImage
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.image),
                        label: Text(
                          _isUploadingImage
                              ? 'UPLOADING...'
                              : _imagePaths.isEmpty
                              ? 'UPLOAD COVER IMAGE'
                              : 'IMAGE SELECTED',
                        ),
                      ),
                      if (_imagePaths.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        AppImage(
                          _imagePaths.first,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isUploadingImage ? null : _createDesign,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 45),
                        ),
                        child: const Text('SAVE DESIGN'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._catalogItems.map((design) {
            final col = _collections
                .where((c) => c.id == design.designCollectionId)
                .firstOrNull;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        design.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Collection: ${col?.name ?? "None"} | \$${design.wholesalePrice}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Edit Design',
                            onPressed: () => _editDesign(design),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _deleteDesign(design),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppImage(
                            design.displayImage,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Text(
                            'Types: ${design.types.join(", ")}\nCategory: ${design.category}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
