import 'dart:io';

void main() {
  final file = File('lib/screens/public/store_detail_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
    '''              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderSubtle),
                
              ),
              child: coach?.logoPath == null ? const Icon(Icons.shield, size: 40, color: AppTheme.borderSubtle) : null,''',
    '''              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderSubtle),
                image: coach?.logoPath != null ? DecorationImage(image: FileImage(File(coach!.logoPath!)), fit: BoxFit.cover) : null,
              ),
              child: coach?.logoPath == null ? const Icon(Icons.shield, size: 40, color: AppTheme.borderSubtle) : null,'''
  );
  file.writeAsStringSync(content);
}
