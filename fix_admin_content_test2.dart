import 'dart:io';

void main() {
  var file = File('test/admin_content_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("test('Admin can update hero settings', () {", "test('Admin can update hero settings', () async {");
  content = content.replaceFirst("test('Admin can manage testimonials', () {", "test('Admin can manage testimonials', () async {");
  content = content.replaceFirst("test('Admin can manage landing collections', () {", "test('Admin can manage landing collections', () async {");
  file.writeAsStringSync(content);
}
