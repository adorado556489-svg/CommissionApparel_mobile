import 'dart:io';
void main() {
  var file = File('lib/screens/coach/direct_order_form_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    'currentUser: user,',
    'user,'
  );
  file.writeAsStringSync(content);
}
