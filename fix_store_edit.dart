import 'dart:io';

void main() {
  final file = File('lib/screens/admin/admin_store_edit_screen.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll(
    '''                              setState(() {
                                final index = dummyStoreItems.indexWhere((i) => i.id == package.id);
                                dummyStoreItems[index] = package.copyWith(
                                  componentIds: List.from(package.componentIds)..remove(c.id)
                                );
                                _loadStoreData();
                              });''',
    '''                              StoreService.updateStoreItem(context.read<FirebaseFirestore>(), package.copyWith(
                                componentIds: List.from(package.componentIds)..remove(c.id)
                              )).then((_) => _loadStoreData());'''
  );

  content = content.replaceAll(
    '''                              setState(() {
                                final index = dummyStoreItems.indexWhere((i) => i.id == package.id);
                                dummyStoreItems[index] = package.copyWith(
                                  componentIds: List.from(package.componentIds)..add(val)
                                );
                                _loadStoreData();
                              });''',
    '''                              StoreService.updateStoreItem(context.read<FirebaseFirestore>(), package.copyWith(
                                componentIds: List.from(package.componentIds)..add(val)
                              )).then((_) => _loadStoreData());'''
  );
  
  file.writeAsStringSync(content);
}
