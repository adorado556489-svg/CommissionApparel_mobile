import 'dart:io';

void main() {
  final file = File('lib/screens/public/home_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  final startStr = "Widget bgImage = ManagedImage.getWidget(";
  final endStr = "fit: BoxFit.cover,\n      );"; // Where the `else` block ends
  
  final startIdx = content.indexOf(startStr);
  final endIdx = content.indexOf(endStr, startIdx);
  
  if (startIdx != -1 && endIdx != -1) {
    final before = content.substring(0, startIdx);
    final after = content.substring(endIdx + endStr.length);
    final newBlock = '''Widget bgImage = ManagedImage.getWidget(
      mediaPath,
      defaultAsset: 'assets/images/hero-banner.jpeg',
      height: 400,
      width: double.infinity,
      fit: BoxFit.cover,
    );''';
    
    content = before + newBlock + after;
  }
  
  file.writeAsStringSync(content);
}
