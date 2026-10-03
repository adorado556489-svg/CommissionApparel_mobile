import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/catalog_service.dart';
import '../../../services/auth_service.dart';
import '../../../models/design_collection.dart';
import '../../../app/theme.dart';
import '../../../models/design_catalog.dart';
import '../../../data/dummy_catalog.dart';
import '../../../data/dummy_users.dart';
import '../../../data/dummy_stores.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class CoachCatalogTab extends StatefulWidget {
  const CoachCatalogTab({super.key});

  @override
  State<CoachCatalogTab> createState() => _CoachCatalogTabState();
}

class _CoachCatalogTabState extends State<CoachCatalogTab> {
  final _formKey = GlobalKey<FormState>();
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
    final items = await CatalogService.getCoachDesignCatalog(firestore, context.read<AuthService>().currentUser!.id);
    final cols = await CatalogService.getCoachDesignCollections(firestore, context.read<AuthService>().currentUser!.id);
    if (mounted) {
      setState(() {
        _catalogItems = items;
        _collections = cols;
      });
    }
  }
  List<String> _imagePaths = [];
  
  final List<String> _availableTypes = [
    'Jersey', 'Shorts', 'Hoodie', 'Pants', 'T-Shirt', 'Warmup Top', 'Warmup Bottom', 'Accessory', 'Backpack'
  ];



  bool _isUploadingImage = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _isUploadingImage = true;
      });
      try {
        final cloudinary = CloudinaryPublic('brtamhix', 'commission_apparel', cache: false);
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(pickedFile.path, resourceType: CloudinaryResourceType.Image),
        );
        setState(() {
          _imagePaths = [response.secureUrl];
          _isUploadingImage = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image uploaded to Cloudinary successfully.')));
        }
      } catch (e) {
        setState(() {
          _isUploadingImage = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cloudinary upload failed: $e')));
        }
      }
    }
  }

  Future<void> _createDesign() async {
    final firestore = context.read<FirebaseFirestore>();
    if (_formKey.currentState!.validate() && _selectedTypes.isNotEmpty) {
      final newDesign = DesignCatalog(coachId: context.read<AuthService>().currentUser!.id, 
        id: 'design-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        designCollectionId: _selectedCollectionId,
        sport: _sportController.text.isEmpty ? null : _sportController.text,
        category: _selectedCategory,
        types: List.from(_selectedTypes),
        wholesalePrice: double.tryParse(_wholesaleController.text) ?? 0.0,
        hasNameField: _hasNameField,
        hasNumberField: _hasNumberField,
        sortOrder: int.tryParse(_sortOrderController.text) ?? 0,
        imagePaths: _imagePaths.isEmpty ? ['assets/images/placeholder.png'] : _imagePaths,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await CatalogService.createDesignCatalogItem(firestore, newDesign);
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
        const SnackBar(content: Text('Please select at least one garment type.')),
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
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Design Name'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  DropdownButtonFormField<String?>(
                    initialValue: _selectedCollectionId,
                    decoration: const InputDecoration(labelText: 'Collection'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None (Orphaned)')),
                      ..._collections.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                    ],
                    onChanged: (v) => setDialogState(() => _selectedCollectionId = v),
                  ),
                  TextFormField(
                    controller: _sportController,
                    decoration: const InputDecoration(labelText: 'Sport (Optional)'),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _availableTypes.map((type) => FilterChip(
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
                    )).toList(),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const [
                      DropdownMenuItem(value: 'individual', child: Text('Individual Item')),
                      DropdownMenuItem(value: 'package_a', child: Text('Package A')),
                      DropdownMenuItem(value: 'package_b', child: Text('Package B')),
                      DropdownMenuItem(value: 'package_c', child: Text('Package C')),
                    ],
                    onChanged: (v) => setDialogState(() => _selectedCategory = v!),
                  ),
                  TextFormField(
                    controller: _wholesaleController,
                    decoration: const InputDecoration(labelText: 'Wholesale Price (\$)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate() && _selectedTypes.isNotEmpty) {
                  final index = dummyDesignCatalog.indexWhere((d) => d.id == design.id);
                  if (index != -1) {
                    dummyDesignCatalog[index] = dummyDesignCatalog[index].copyWith(
                      name: _nameController.text,
                      sport: _sportController.text.isEmpty ? null : _sportController.text,
                      category: _selectedCategory,
                      types: List.from(_selectedTypes),
                      wholesalePrice: double.tryParse(_wholesaleController.text) ?? 0.0,
                      hasNameField: _hasNameField,
                      hasNumberField: _hasNumberField,
                      designCollectionId: _selectedCollectionId,
                      clearCollectionId: _selectedCollectionId == null,
                    );
                  }
                  Navigator.pop(ctx);
                  _nameController.clear();
                  _sportController.clear();
                  _wholesaleController.clear();
                  _sortOrderController.clear();
                  _loadData();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Design updated.')));
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
        content: const Text('WARNING: This will delete all Store Items across all active and archived Team Stores that reference this design. Package component references will also be scrubbed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              final firestore = context.read<FirebaseFirestore>();
              // 1. Delete associated StoreItems globally
              final deletedStoreItemIds = dummyStoreItems.where((i) => i.designCatalogId == design.id).map((i) => i.id).toList();
              dummyStoreItems.removeWhere((i) => i.designCatalogId == design.id);
              
              // 2. Scrub package component references
              for (int i = 0; i < dummyStoreItems.length; i++) {
                final item = dummyStoreItems[i];
                final newComponentIds = item.componentIds.where((id) => !deletedStoreItemIds.contains(id)).toList();
                dummyStoreItems[i] = item.copyWith(componentIds: newComponentIds);
              }
              
              // 3. Delete design
              await CatalogService.deleteDesignCatalogItem(firestore, design.id);
              await _loadData();
              
              if (ctx.mounted) Navigator.pop(ctx);
              _loadData();
              if (!mounted) return;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Design deleted and cascaded.')),
              );
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _assignToCoach(DesignCatalog design) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign/Remove Design'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: dummyCoaches.map((coach) {
              final isAssigned = coach.assignedDesignIds.contains(design.id);
              return CheckboxListTile(
                title: Text(coach.fullName),
                subtitle: Text(coach.organization ?? ''),
                value: isAssigned,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      if (!coach.assignedDesignIds.contains(design.id)) {
                        coach.assignedDesignIds.add(design.id);
                      }
                    } else {
                      coach.assignedDesignIds.remove(design.id);
                    }
                  });
                  Navigator.pop(ctx);
                  _assignToCoach(design); // refresh dialog
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coach assignments updated.')),
              );
            },
            child: const Text('DONE'),
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
          title: const Text('CREATE NEW DESIGN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                      decoration: const InputDecoration(labelText: 'Design Name'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    DropdownButtonFormField<String?>(
                      initialValue: _selectedCollectionId,
                      decoration: const InputDecoration(labelText: 'Collection'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('None (Orphaned)')),
                        ..._collections.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                      ],
                      onChanged: (v) => setState(() => _selectedCollectionId = v),
                    ),
                    TextFormField(
                      controller: _sportController,
                      decoration: const InputDecoration(labelText: 'Sport (Optional)'),
                    ),
                    const SizedBox(height: 12),
                    const Text('Garment Types', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: _availableTypes.map((type) => FilterChip(
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
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const [
                        DropdownMenuItem(value: 'individual', child: Text('Individual Item')),
                        DropdownMenuItem(value: 'package_a', child: Text('Package A')),
                        DropdownMenuItem(value: 'package_b', child: Text('Package B')),
                        DropdownMenuItem(value: 'package_c', child: Text('Package C')),
                      ],
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                    TextFormField(
                      controller: _wholesaleController,
                      decoration: const InputDecoration(labelText: 'Wholesale Price (\$)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
                      decoration: const InputDecoration(labelText: 'Sort Order'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isUploadingImage ? null : _pickImage,
                      icon: _isUploadingImage ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.image),
                      label: Text(_isUploadingImage ? 'UPLOADING...' : _imagePaths.isEmpty ? 'UPLOAD COVER IMAGE' : 'IMAGE SELECTED'),
                    ),
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
          final col = _collections.where((c) => c.id == design.designCollectionId).firstOrNull;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(design.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Collection: ${col?.name ?? "None"} | \$${design.wholesalePrice}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.group_add, color: AppTheme.primary),
                          tooltip: 'Assign to Coach',
                          onPressed: () => _assignToCoach(design),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Edit Design',
                          onPressed: () => _editDesign(design),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteDesign(design),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Types: ${design.types.join(", ")}\nCategory: ${design.category}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        }),
      ],
    ));
  }
}








