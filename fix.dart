import 'dart:io';

void main() {
  final file = File('lib/screens/admin/admin_store_edit_screen.dart');
  var code = file.readAsStringSync();
  
  // 1. Add FirebaseFirestore import & Provider
  code = code.replaceFirst("import '../../data/dummy_catalog.dart';", "import '../../data/dummy_catalog.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport 'package:provider/provider.dart';\nimport '../../services/store_service.dart';");

  // 2. Add _isLoading flag
  code = code.replaceFirst("class _AdminStoreEditScreenState extends State<AdminStoreEditScreen> {", "class _AdminStoreEditScreenState extends State<AdminStoreEditScreen> {\n  bool _isLoading = true;");

  // 3. _loadStoreData
  final loadRegex = RegExp(r"void _loadStoreData\(\) \{[\s\S]*?TextEditingController\(text: item\.retailPrice\.toString\(\)\),\s*\];\s*\}\s*\}");
  final loadNew = """Future<void> _loadStoreData() async {
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
  }""";
  code = code.replaceFirst(loadRegex, loadNew);

  // 4. _pickCoverImage
  final pickRegex = RegExp(r"Future<void> _pickCoverImage\(\) async \{[\s\S]*?\}\s*\}\s*\}");
  final pickNew = """Future<void> _pickCoverImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final firestore = context.read<FirebaseFirestore>();
      await StoreService.updateStore(firestore, _store.copyWith(coverImagePath: image.path));
      await _loadStoreData();
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cover image updated.')));
      }
    }
  }""";
  code = code.replaceFirst(pickRegex, pickNew);

  // 5. _toggleArchive
  final toggleRegex = RegExp(r"void _toggleArchive\(\) \{[\s\S]*?'Store archived\.' : 'Store unarchived\.'\)\),\s*\);\s*\}");
  final toggleNew = """Future<void> _toggleArchive() async {
    final firestore = context.read<FirebaseFirestore>();
    await StoreService.updateStore(firestore, _store.copyWith(isArchived: !_store.isArchived));
    await _loadStoreData();
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_store.isArchived ? 'Store archived.' : 'Store unarchived.')));
    }
  }""";
  code = code.replaceFirst(toggleRegex, toggleNew);

  // 6. _updatePricing
  final pricingRegex = RegExp(r"void _updatePricing\(\) \{[\s\S]*?'Store item pricing updated\.'\)\),\s*\);\s*\}");
  final pricingNew = """Future<void> _updatePricing() async {
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
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Store item pricing updated.')));
    }
  }""";
  code = code.replaceFirst(pricingRegex, pricingNew);

  // 7. _addDesignToStore
  final addRegex = RegExp(r"void _addDesignToStore\(String designId\) \{[\s\S]*?'Item added to store\.'\)\),\s*\);\s*\}");
  final addNew = """Future<void> _addDesignToStore(String designId) async {
    final design = dummyDesignCatalog.firstWhere((d) => d.id == designId);
    final firestore = context.read<FirebaseFirestore>();
    final newItem = StoreItem(
      id: 'item-\${DateTime.now().millisecondsSinceEpoch}',
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
    await StoreService.createStoreItem(firestore, newItem);
    await _loadStoreData();
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item added to store.')));
    }
  }""";
  code = code.replaceFirst(addRegex, addNew);

  // 8. _removeStoreItem
  final removeRegex = RegExp(r"void _removeStoreItem\(String itemId\) \{[\s\S]*?'Item removed\.'\)\),\s*\);\s*\}");
  final removeNew = """Future<void> _removeStoreItem(String itemId) async {
    final firestore = context.read<FirebaseFirestore>();
    await StoreService.deleteStoreItem(firestore, itemId);
    await _loadStoreData();
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item removed.')));
    }
  }""";
  code = code.replaceFirst(removeRegex, removeNew);

  // Fix build
  code = code.replaceFirst("Widget build(BuildContext context) {", "Widget build(BuildContext context) {\n    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));");
  
  file.writeAsStringSync(code);
  print("Updated AdminStoreEditScreen");
}
