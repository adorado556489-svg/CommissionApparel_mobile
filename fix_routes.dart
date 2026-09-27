import 'dart:io';

void main() {
  var file = File('lib/app/routes.dart');
  var content = file.readAsStringSync();
  
  // Make requireAuth default to true
  content = content.replaceAll("bool requireAuth = false,", "bool requireAuth = true,");
  content = content.replaceAll("this.requireAuth = false,", "this.requireAuth = true,");
  
  // Make AuthWrapper the home route
  content = content.replaceFirst("case home:\n        return _buildRoute(settings, const HomeScreen());", "case home:\n        return _buildRoute(settings, const AuthWrapper(), requireAuth: false);");
  
  if (!content.contains("import '../screens/auth/auth_wrapper.dart';")) {
    content = "import '../screens/auth/auth_wrapper.dart';\n" + content;
  }
  
  file.writeAsStringSync(content);
}
