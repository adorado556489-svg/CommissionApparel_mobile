import 'dart:io';

void main() {
  final file = File('lib/screens/admin/admin_content_screens.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  if (!content.contains("import '../../services/storage_service.dart';")) {
    content = content.replaceFirst("import '../../services/admin_service.dart';", "import '../../services/admin_service.dart';\nimport '../../services/storage_service.dart';\nimport 'dart:io';");
  }
  
  final landOld = '''                        IconButton(
                          icon: const Icon(Icons.image),
                          onPressed: () async {
                            final picked = await _picker.pickImage(source: ImageSource.gallery);
                            if (picked != null) {
                              final admin = context.read<AuthService>().currentUser!;
                              AdminService.updateLandingCollection(admin, c.copyWith(imagePath: picked.path));
                              setState(() {});
                            }
                          },
                        ),''';
  final landNew = '''                        IconButton(
                          icon: const Icon(Icons.image),
                          onPressed: () async {
                            final picked = await _picker.pickImage(source: ImageSource.gallery);
                            if (picked != null) {
                              final admin = context.read<AuthService>().currentUser!;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading image...')));
                              final storagePath = '/landing/\${c.id}/\${DateTime.now().millisecondsSinceEpoch}.png';
                              final url = await StorageService().replaceFile(storagePath, File(picked.path), c.imagePath);
                              if (url != null) {
                                await AdminService.updateLandingCollection(admin, c.copyWith(imagePath: url));
                                setState(() {});
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image updated.')));
                              } else {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed.')));
                              }
                            }
                          },
                        ),''';
                        
  final testOld = '''                        IconButton(
                          icon: const Icon(Icons.image),
                          onPressed: () async {
                            final picked = await _picker.pickImage(source: ImageSource.gallery);
                            if (picked != null) {
                              final admin = context.read<AuthService>().currentUser!;
                              AdminService.updateTestimonial(admin, t.copyWith(imagePath: picked.path));
                              setState(() {});
                            }
                          },
                        ),''';
  final testNew = '''                        IconButton(
                          icon: const Icon(Icons.image),
                          onPressed: () async {
                            final picked = await _picker.pickImage(source: ImageSource.gallery);
                            if (picked != null) {
                              final admin = context.read<AuthService>().currentUser!;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading avatar...')));
                              final storagePath = '/testimonials/\${t.id}/avatar_\${DateTime.now().millisecondsSinceEpoch}.png';
                              final url = await StorageService().replaceFile(storagePath, File(picked.path), t.imagePath);
                              if (url != null) {
                                await AdminService.updateTestimonial(admin, t.copyWith(imagePath: url));
                                setState(() {});
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avatar updated.')));
                              } else {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed.')));
                              }
                            }
                          },
                        ),''';

  content = content.replaceFirst(landOld, landNew);
  content = content.replaceFirst(testOld, testNew);
  file.writeAsStringSync(content);
}
