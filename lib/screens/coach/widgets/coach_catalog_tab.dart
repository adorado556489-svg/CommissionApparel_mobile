import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/store_service.dart';
import '../../../models/team_store.dart';
import '../../../models/store_item.dart';
import '../../../services/storage_service.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/managed_image.dart';

/// Coach "PRODUCTS" tab: the designs already on sale in the store, plus the
/// admin's blank catalog to start a new product from.
///
/// Everything is rendered in one lazy [CustomScrollView] so large catalogs
/// never build (or decode images for) off-screen cards.
class CoachCatalogTab extends StatefulWidget {
  final TeamStore store;

  const CoachCatalogTab({super.key, required this.store});

  @override
  State<CoachCatalogTab> createState() => _CoachCatalogTabState();
}

class _CoachCatalogTabState extends State<CoachCatalogTab>
    with AutomaticKeepAliveClientMixin {
  List<StoreItem> _items = const [];
  bool _itemsLoading = true;
  String? _error;
  StreamSubscription<List<StoreItem>>? _itemsSub;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _itemsSub = StoreService.watchStoreItems(
      context.read<FirebaseFirestore>(),
      widget.store.id,
    ).listen(
      (items) {
        if (!mounted) return;
        setState(() {
          _items = items;
          _itemsLoading = false;
        });
      },
      onError: (Object e) {
        debugPrint('CoachCatalogTab items stream failed: $e');
        if (!mounted) return;
        setState(() {
          _itemsLoading = false;
          _error = 'Could not load your products.';
        });
      },
    );
  }

  @override
  void dispose() {
    _itemsSub?.cancel();
    super.dispose();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openCreateProductDialog() {
    if (!widget.store.isApproved) {
      _toast('Re-open your store to add products.');
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => _CreateProductDialog(
        storeId: widget.store.id,
      ),
    );
  }

  Future<void> _editPrice(StoreItem item) async {
    final price = await showDialog<double>(
      context: context,
      builder: (ctx) => _EditPriceDialog(item: item),
    );
    if (price == null || !mounted) return;
    try {
      await StoreService.updateStoreItem(
        context.read<FirebaseFirestore>(),
        item.copyWith(retailPrice: price),
      );
      _toast('Price updated to ${Fmt.money(price)}.');
    } catch (e) {
      debugPrint('CoachCatalogTab update price failed: $e');
      _toast('Could not update the price. Please try again.');
    }
  }

  Future<void> _remove(StoreItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove product?'),
        content: Text(
          '"${item.name}" will no longer be shown in your store. Existing orders keep their original price.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('REMOVE'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await StoreService.deleteStoreItem(context.read<FirebaseFirestore>(), item.id);
      _toast('Product removed.');
    } catch (e) {
      debugPrint('CoachCatalogTab delete failed: $e');
      _toast('Could not remove the product. Please try again.');
    }
  }

  Widget _heading(String text, {String? subtitle}) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Theme.of(context).hintColor)),
            ],
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _heading(
            'Your products (${_items.length})',
            subtitle: 'Designs customers can order from your store.',
          ),
        ),
        if (_error != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          ),
        if (_itemsLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (_items.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('No products yet. Pick a blank below and upload your design.'),
            ),
          )
        else
          SliverList.builder(
            itemCount: _items.length,
            itemBuilder: (context, i) => _ItemTile(
              item: _items[i],
              onEditPrice: () => _editPrice(_items[i]),
              onRemove: () => _remove(_items[i]),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ElevatedButton.icon(
              onPressed: _openCreateProductDialog,
              icon: const Icon(Icons.add),
              label: const Text('ADD CUSTOM PRODUCT'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One product already on sale in the coach's store.
class _ItemTile extends StatelessWidget {
  final StoreItem item;
  final VoidCallback onEditPrice;
  final VoidCallback onRemove;

  const _ItemTile({required this.item, required this.onEditPrice, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final image = item.displayImage;
    final profit = item.marginPerUnit;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 64,
                height: 64,
                child: (image == null || image.isEmpty)
                    ? Container(color: Colors.black12, child: const Icon(Icons.checkroom))
                    : AppImage(image, fit: BoxFit.cover, width: 64, height: 64),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Price ${Fmt.money(item.retailPrice)}  |  Base ${Fmt.money(item.wholesalePrice)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    'You earn ${Fmt.money(profit)} each',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: profit > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit price',
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEditPrice,
            ),
            IconButton(
              tooltip: 'Remove product',
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

/// Edits an item's retail price; owns (and disposes) its controller.
class _EditPriceDialog extends StatefulWidget {
  final StoreItem item;
  const _EditPriceDialog({required this.item});

  @override
  State<_EditPriceDialog> createState() => _EditPriceDialogState();
}

class _EditPriceDialogState extends State<_EditPriceDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.retailPrice.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(context, double.parse(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.item.wholesalePrice;
    return AlertDialog(
      title: const Text('Edit price'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Base cost: ${Fmt.money(base)}'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Retail price (\$)'),
              onFieldSubmitted: (_) => _submit(),
              validator: (v) {
                final p = double.tryParse((v ?? '').trim());
                if (p == null || p <= 0) return 'Enter a valid price.';
                if (p < base) return 'Price must cover the base cost.';
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Existing orders keep the price they were placed at.',
              style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
        ElevatedButton(onPressed: _submit, child: const Text('SAVE')),
      ],
    );
  }
}

class _CreateProductDialog extends StatefulWidget {
  final String storeId;

  const _CreateProductDialog({
    required this.storeId,
  });

  @override
  State<_CreateProductDialog> createState() => _CreateProductDialogState();
}

class _CreateProductDialogState extends State<_CreateProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _retailPriceController;
  String? _uploadedImageUrl;
  bool _isUploading = false;
  bool _hasNameField = false;
  bool _hasNumberField = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _retailPriceController = TextEditingController();
  }

  Future<void> _pickImage() async {
    setState(() => _isUploading = true);
    try {
      final storage = StorageService();
      final url = await storage.pickAndUpload(
        folder: 'stores/${widget.storeId}/designs',
      );
      if (url != null) {
        setState(() {
          _uploadedImageUrl = url;
          _isUploading = false;
        });
      } else {
        setState(() => _isUploading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isUploading = false);
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a design image.')),
      );
      return;
    }

    final retailPrice = double.tryParse(_retailPriceController.text) ?? 0.0;
    final firestore = context.read<FirebaseFirestore>();

    final item = StoreItem(
      id: firestore.collection('storeItems').doc().id,
      teamStoreId: widget.storeId,
      name: _nameController.text.trim(),
      types: const ['Apparel'],
      imagePaths: [_uploadedImageUrl!],
      wholesalePrice: 0.0,
      retailPrice: retailPrice,
      hasNameField: _hasNameField,
      hasNumberField: _hasNumberField,
      availableSizes: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await StoreService.createStoreItem(firestore, item);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added to your store!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not add product: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Custom Product'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name (e.g. Riverside Hoodie)',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Enter a product name.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _retailPriceController,
                decoration: const InputDecoration(
                  labelText: 'Your Retail Price (\$)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  final price = double.tryParse(v ?? '');
                  if (price == null || price <= 0) {
                    return 'Enter a valid price greater than zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Require player name personalization'),
                value: _hasNameField,
                onChanged: (v) => setState(() => _hasNameField = v ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Require player number personalization'),
                value: _hasNumberField,
                onChanged: (v) => setState(() => _hasNumberField = v ?? false),
              ),
              const SizedBox(height: 24),
              const Text(
                'Upload Your Design/Logo:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_uploadedImageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AppImage(
                    _uploadedImageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickImage,
                icon: _isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload),
                label: Text(
                  _isUploading
                      ? 'Uploading...'
                      : (_uploadedImageUrl == null
                            ? 'Select Image'
                            : 'Change Image'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _save,
          child: const Text('ADD TO STORE'),
        ),
      ],
    );
  }
}
