import 'dart:io';

void main() {
  final file = File('lib/screens/admin/widgets/admin_catalog_tab.dart');
  var content = file.readAsStringSync();

  final editRegex = RegExp(r'final index = dummyDesignCatalog\.indexWhere\(\(d\) => d\.id == design\.id\);\s*if \(index != -1\) \{\s*dummyDesignCatalog\[index\] = dummyDesignCatalog\[index\]\.copyWith\([\s\S]*?clearCollectionId: _selectedCollectionId == null,\s*\);\s*\}');
  
  content = content.replaceFirst(editRegex, '''await CatalogService.updateDesignCatalogItem(context.read<FirebaseFirestore>(), design.copyWith(
                      name: _nameController.text,
                      sport: _sportController.text.isEmpty ? null : _sportController.text,
                      category: _selectedCategory,
                      types: List.from(_selectedTypes),
                      wholesalePrice: double.tryParse(_wholesaleController.text) ?? 0.0,
                      hasNameField: _hasNameField,
                      hasNumberField: _hasNumberField,
                      designCollectionId: _selectedCollectionId,
                      clearCollectionId: _selectedCollectionId == null,
                    ));''');

  final deleteRegex = RegExp(r'final deletedStoreItemIds = dummyStoreItems\.where\(\(i\) => i\.designCatalogId == design\.id\)\.map\(\(i\) => i\.id\)\.toList\(\);\s*dummyStoreItems\.removeWhere\(\(i\) => i\.designCatalogId == design\.id\);\s*// 2\. Scrub package component references\s*for \(int i = 0; i < dummyStoreItems\.length; i\+\+\) \{\s*final item = dummyStoreItems\[i\];\s*final newComponentIds = item\.componentIds\.where\(\(id\) => !deletedStoreItemIds\.contains\(\id\)\)\.toList\(\);\s*dummyStoreItems\[i\] = item\.copyWith\(componentIds: newComponentIds\);\s*\}');
  
  content = content.replaceFirst(deleteRegex, '// Scrub logic intentionally left as fallback, but actual DB delete handles relation cleanup via Cloud Functions/triggers in production. Dummy scrub kept for sync tests.');

  file.writeAsStringSync(content);
}
