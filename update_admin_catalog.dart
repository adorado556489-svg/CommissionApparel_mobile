import 'dart:io';

void main() {
  final file = File('lib/screens/admin/widgets/admin_catalog_tab.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  if (!content.contains("import '../../../services/storage_service.dart';")) {
    content = content.replaceFirst("import '../../../services/catalog_service.dart';", "import '../../../services/catalog_service.dart';\nimport '../../../services/storage_service.dart';\nimport 'dart:io';");
  }
  
  final createMethodOld = '''    Future<void> _createDesign() async {
      if (_formKey.currentState!.validate() && _selectedTypes.isNotEmpty) {
        final newDesign = DesignCatalog(
          id: 'design-\${DateTime.now().millisecondsSinceEpoch}',
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
        await CatalogService.createDesignCatalogItem(context.read<FirebaseFirestore>(), newDesign);
        await _loadCatalog();
        _nameController.clear();
        _sportController.clear();
        _wholesaleController.clear();
        _sortOrderController.clear();
        setState(() {
          _selectedTypes.clear();
          _imagePaths.clear();
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Design added to Catalog.')));
      }
    }''';
    
  final createMethodNew = '''    Future<void> _createDesign() async {
      if (_formKey.currentState!.validate() && _selectedTypes.isNotEmpty) {
        final designId = 'design-\${DateTime.now().millisecondsSinceEpoch}';
        List<String> finalImagePaths = [];
        
        if (_imagePaths.isNotEmpty) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading image...')));
           final localFile = File(_imagePaths.first);
           final storagePath = '/catalog/\$designId/primary_\${DateTime.now().millisecondsSinceEpoch}.png';
           final url = await StorageService().uploadFile(storagePath, localFile);
           if (url != null) {
             finalImagePaths = [url];
           } else {
             ScaffoldMessenger.of(context).hideCurrentSnackBar();
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image upload failed. Using placeholder.')));
             finalImagePaths = ['assets/images/placeholder.png'];
           }
        } else {
           finalImagePaths = ['assets/images/placeholder.png'];
        }
        
        final newDesign = DesignCatalog(
          id: designId,
          name: _nameController.text,
          designCollectionId: _selectedCollectionId,
          sport: _sportController.text.isEmpty ? null : _sportController.text,
          category: _selectedCategory,
          types: List.from(_selectedTypes),
          wholesalePrice: double.tryParse(_wholesaleController.text) ?? 0.0,
          hasNameField: _hasNameField,
          hasNumberField: _hasNumberField,
          sortOrder: int.tryParse(_sortOrderController.text) ?? 0,
          imagePaths: finalImagePaths,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await CatalogService.createDesignCatalogItem(context.read<FirebaseFirestore>(), newDesign);
        await _loadCatalog();
        _nameController.clear();
        _sportController.clear();
        _wholesaleController.clear();
        _sortOrderController.clear();
        setState(() {
          _selectedTypes.clear();
          _imagePaths.clear();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Design added to Catalog.')));
        }
      }
    }''';

  content = content.replaceFirst(createMethodOld, createMethodNew);
  file.writeAsStringSync(content);
}
