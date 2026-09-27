import 'dart:io';

void main() {
  final file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  if (!content.contains("import '../../services/storage_service.dart';")) {
    content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../../services/storage_service.dart';\nimport '../../widgets/managed_image.dart';");
  }

  // Cover image
  final pickCoverOld = '''  Future<void> _pickCoverImage() async {
    if (_activeStore == null) return;
    
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Mock saving image path
      setState(() {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cover image updated.')));
    }
  }''';
  final pickCoverNew = '''  Future<void> _pickCoverImage() async {
    if (_activeStore == null) return;
    
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        final newUrl = await StorageService().replaceFile(
          'stores/\${_activeStore!.id}/cover_\${DateTime.now().millisecondsSinceEpoch}.jpg',
          File(image.path),
          _activeStore!.coverImagePath,
        );
        if (newUrl != null) {
          final firestore = context.read<FirebaseFirestore>();
          await firestore.collection('teamStores').doc(_activeStore!.id).update({'coverImagePath': newUrl});
          await _loadData();
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cover image updated.')));
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed.')));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e')));
      }
    }
  }''';
  content = content.replaceFirst(pickCoverOld, pickCoverNew);

  // Logo
  final pickLogoOld = '''  Future<void> _updateLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await context.read<AuthService>().updateProfileLogo(image.path);
      setState(() {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile logo updated.')));
    }
  }''';
  final pickLogoNew = '''  Future<void> _updateLogo() async {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        final newUrl = await StorageService().replaceFile(
          'users/\${user.id}/logo_\${DateTime.now().millisecondsSinceEpoch}.png',
          File(image.path),
          user.logoPath,
        );
        if (newUrl != null) {
          await context.read<AuthService>().updateProfileLogo(newUrl);
          setState(() {});
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile logo updated.')));
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed.')));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e')));
      }
    }
  }''';
  content = content.replaceFirst(pickLogoOld, pickLogoNew);

  // Replace FileImage
  content = content.replaceAll("FileImage(File(user.logoPath!))", "ManagedImage.getProvider(user.logoPath!)");

  file.writeAsStringSync(content);
}
