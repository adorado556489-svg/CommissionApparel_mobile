import 'dart:io';

void main() {
  final file = File('lib/screens/public/store_search_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  if (!content.contains("import 'dart:io';")) {
    content = "import 'dart:io';\n" + content;
  }
  
  final idx = content.indexOf('Expanded(\n                      child: Column(\n                        crossAxisAlignment: CrossAxisAlignment.start,\n                        children: [\n                          Text(\n                            (coach.sport');
  
  if (idx != -1) {
    final before = content.substring(0, idx);
    final after = content.substring(idx);
    content = before + '''Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.borderSubtle),
                        image: coach.logoPath != null 
                          ? DecorationImage(image: FileImage(File(coach.logoPath!)), fit: BoxFit.cover)
                          : null,
                      ),
                      child: coach.logoPath == null ? const Icon(Icons.shield, size: 20, color: AppTheme.borderSubtle) : null,
                    ),
                    ''' + after;
  }
  file.writeAsStringSync(content);
}
