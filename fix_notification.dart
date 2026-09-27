import 'dart:io';

void main() {
  final file = File('lib/models/notification_item.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst('  bool get isRead => readAt != null;\n\n', '');
  file.writeAsStringSync(content);
}
