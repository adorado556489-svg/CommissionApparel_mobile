import 'dart:io';
void main() {
  var sFile = File('lib/screens/public/store_search_screen.dart');
  sFile.writeAsStringSync(sFile.readAsStringSync().replaceAll("role: 'coach'", "role: UserRole.coach"));

  var dFile = File('lib/screens/public/store_detail_screen.dart');
  dFile.writeAsStringSync(dFile.readAsStringSync().replaceAll("role: 'coach'", "role: UserRole.coach"));
}
