import 'dart:io';

void main() {
  final file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  if (!content.contains("import '../../services/storage_service.dart';")) {
    content = content.replaceFirst("import '../../services/store_service.dart';", "import '../../services/store_service.dart';\nimport '../../services/storage_service.dart';");
  }
  
  // Replace _pickCoverImage
  final coverOld = '''    Future<void> _pickCoverImage() async {
      if (_activeStore == null) return;
      try {
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          final firestore = context.read<FirebaseFirestore>();
          await StoreService.updateStore(firestore, _activeStore!.copyWith(coverImagePath: pickedFile.path));
          await _loadData();
        }
      } catch (_) {}
    }''';
    
  final coverNew = '''    Future<void> _pickCoverImage() async {
      if (_activeStore == null) return;
      try {
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          final firestore = context.read<FirebaseFirestore>();
          
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading cover image...')));
          
          final storagePath = '/stores/\${_activeStore!.id}/cover_\${DateTime.now().millisecondsSinceEpoch}.jpg';
          final url = await StorageService().replaceFile(storagePath, File(pickedFile.path), _activeStore!.coverImagePath);
          
          if (url != null) {
            await StoreService.updateStore(firestore, _activeStore!.copyWith(coverImagePath: url));
            await _loadData();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cover image updated successfully.')));
          } else {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload image. Please try again.')));
          }
        }
      } catch (e) {
        print('Upload error: \$e');
      }
    }''';
    
  content = content.replaceFirst(coverOld, coverNew);
  
  // Replace update profile logo
  final logoOld = '''                          onPressed: () async {
                            final picked = await _picker.pickImage(source: ImageSource.gallery);
                            if (picked != null) {
                              final error = context.read<AuthService>().updateProfileLogo(picked.path);
                              if (error == null) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Organization logo updated successfully.')));
                              }
                            }
                          },''';
                          
  final logoNew = '''                          onPressed: () async {
                            final picked = await _picker.pickImage(source: ImageSource.gallery);
                            if (picked != null) {
                              final user = context.read<AuthService>().currentUser;
                              if (user == null) return;
                              
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading logo...')));
                              
                              final storagePath = '/users/\${user.id}/logo_\${DateTime.now().millisecondsSinceEpoch}.png';
                              final url = await StorageService().replaceFile(storagePath, File(pickedFile.path), user.logoPath);
                              
                              if (url != null) {
                                final error = await context.read<AuthService>().updateProfileLogo(url);
                                if (error == null) {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Organization logo updated successfully.')));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                                }
                              } else {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload logo.')));
                              }
                            }
                          },''';
  
  // Wait, the variable in `logoOld` is `picked`, but my new code used `pickedFile.path`! Let me fix it.
  final logoNewFixed = logoNew.replaceAll('pickedFile.path', 'picked.path');
  content = content.replaceFirst(logoOld, logoNewFixed);
  
  file.writeAsStringSync(content);
}
