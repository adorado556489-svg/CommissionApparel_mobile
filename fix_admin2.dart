import 'dart:io';

void main() {
  var lines = File('lib/services/admin_service.dart').readAsLinesSync();
  
  var newCode = """
  static String? updateHeroSettings(User admin, {required String subtitle, String? mediaPath, String? mediaType}) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }

  static String? removeHeroMedia(User admin) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }

  // --- QUOTES ---

  static String? markQuoteAddressed(User admin, String quoteId) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    return null;
  }
}
""";
  
  lines.removeRange(240, lines.length);
  lines.add(newCode);
  
  File('lib/services/admin_service.dart').writeAsStringSync(lines.join('\n'));
}
