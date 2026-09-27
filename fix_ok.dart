import 'dart:io';

void main() {
  final file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  content = content.replaceAll(
    "ElevatedButton(onPressed: () {}, child: const Text('OK')),",
    ""
  );

  file.writeAsStringSync(content);
}
