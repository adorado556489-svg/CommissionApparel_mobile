import 'dart:io';

void main() {
  final file = File('lib/screens/public/store_detail_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  final idx = content.indexOf('Widget _buildHeaderInfo(BuildContext context, dynamic store, dynamic coach) {');
  if (idx != -1) {
    final block = content.substring(idx);
    final target = 'border: Border.all(color: AppTheme.borderSubtle),\n                \n              ),\n              child: coach?.logoPath == null ? const Icon(Icons.shield, size: 40, color: AppTheme.borderSubtle) : null,';
    final replacement = 'border: Border.all(color: AppTheme.borderSubtle),\n                image: coach?.logoPath != null ? DecorationImage(image: FileImage(File(coach!.logoPath!)), fit: BoxFit.cover) : null,\n              ),\n              child: coach?.logoPath == null ? const Icon(Icons.shield, size: 40, color: AppTheme.borderSubtle) : null,';
    
    content = content.substring(0, idx) + block.replaceFirst(target, replacement);
  }
  file.writeAsStringSync(content);
}
