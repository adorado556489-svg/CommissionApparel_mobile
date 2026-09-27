import 'dart:io';

void main() {
  final file = File('lib/screens/public/store_detail_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  final idx = content.indexOf('Widget _buildHeaderInfo(BuildContext context, dynamic store, dynamic coach) {');
  if (idx != -1) {
    final block = content.substring(idx);
    final newBlock = block.replaceFirst('border: Border.all(color: AppTheme.borderSubtle),', 'border: Border.all(color: AppTheme.borderSubtle),\n                image: coach?.logoPath != null ? DecorationImage(image: FileImage(File(coach!.logoPath!)), fit: BoxFit.cover) : null,');
    
    content = content.substring(0, idx) + newBlock;
  }
  file.writeAsStringSync(content);
}
