import 'dart:io';

void main() {
  final file = File('lib/screens/admin/admin_store_edit_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  if (!content.contains("import '../../services/storage_service.dart';")) {
    content = content.replaceFirst("import '../../services/store_service.dart';", "import '../../services/store_service.dart';\nimport '../../services/storage_service.dart';");
  }
  
  final oldMethod = '''    Future<void> _pickCoverImage() async {
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
    }''';
    
  final newMethod = '''    Future<void> _pickCoverImage() async {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading cover image...')));
        }
        final storagePath = '/stores/\${_store.id}/cover_\${DateTime.now().millisecondsSinceEpoch}.jpg';
        final url = await StorageService().replaceFile(storagePath, File(image.path), _store.coverImagePath);
        
        if (url != null) {
          final firestore = context.read<FirebaseFirestore>();
          await StoreService.updateStore(firestore, _store.copyWith(coverImagePath: url));
          await _loadStoreData();
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cover image updated.')));
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload cover image.')));
          }
        }
      }
    }''';
    
  content = content.replaceFirst(oldMethod, newMethod);
  file.writeAsStringSync(content);
}
