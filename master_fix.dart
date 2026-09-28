import 'dart:io';

void main() {
  var dir = Directory('test');
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('_test.dart')) {
      var content = file.readAsStringSync();
      var newContent = content;

      // 1. Fix rawdummy references globally
      newContent = newContent.replaceAll(RegExp(r'\bdummyUsers\b'), 'rawdummyUsers')
                              .replaceAll(RegExp(r'\bdummyCoaches\b'), 'rawdummyCoaches')
                              .replaceAll(RegExp(r'\bdummyParents\b'), 'rawdummyParents')
                              .replaceAll(RegExp(r'\bdummyTeamStores\b'), 'rawdummyTeamStores')
                              .replaceAll(RegExp(r'\bdummyStoreItems\b'), 'rawdummyStoreItems')
                              .replaceAll(RegExp(r'\bdummyParentOrders\b'), 'rawdummyParentOrders')
                              .replaceAll(RegExp(r'\bdummyDesignCatalog\b'), 'rawdummyDesignCatalog')
                              .replaceAll(RegExp(r'\bdummyDesignCollections\b'), 'rawdummyDesignCollections')
                              .replaceAll(RegExp(r'\bdummyLandingCollections\b'), 'rawdummyLandingCollections')
                              .replaceAll(RegExp(r'\bdummyTestimonials\b'), 'rawdummyTestimonials')
                              .replaceAll(RegExp(r'\bdummySiteSettings\b'), 'rawdummySiteSettings')
                              .replaceAll(RegExp(r'\bdummyQuoteRequests\b'), 'rawdummyQuoteRequests')
                              .replaceAll(RegExp(r'\bdummyNotifications\b'), 'rawdummyNotifications')
                              .replaceAll('rawraw', 'raw');
                              
      // 2. Fix test_seeder imports
      if (newContent.contains('FakeFirebaseFirestore') && !newContent.contains('test_seeder.dart')) {
         var parts = file.path.split(Platform.pathSeparator);
         var depth = parts.length - 2;
         var relativePrefix = '';
         for (var i = 0; i < depth; i++) relativePrefix += '../';
         newContent = "import '${relativePrefix}helpers/test_seeder.dart';\n" + newContent;
      }
      
      // 3. Inject pumpAndSettle safely
      if (newContent.contains('await tester.pumpWidget(')) {
        var lines = newContent.split('\n');
        for (var i = 0; i < lines.length; i++) {
          var line = lines[i];
          if (line.contains('await tester.pumpWidget(')) {
            bool hasPumpAndSettle = false;
            for (var j = i + 1; j < i + 5 && j < lines.length; j++) {
              if (lines[j].contains('tester.pumpAndSettle')) { hasPumpAndSettle = true; break; }
            }
            if (!hasPumpAndSettle) {
              if (line.contains(');')) {
                lines.insert(i + 1, '      await tester.pumpAndSettle();');
                i++;
              } else {
                for (var j = i + 1; j < lines.length; j++) {
                  if (lines[j].contains(');')) {
                    lines.insert(j + 1, '      await tester.pumpAndSettle();');
                    i = j + 1;
                    break;
                  }
                }
              }
            }
          }
        }
        newContent = lines.join('\n');
      }
      
      // 4. Ensure FakeFirebaseFirestore is initialized properly
      if (newContent.contains('late FakeFirebaseFirestore firestore;') || newContent.contains('late FirebaseFirestore firestore;')) {
         // Some files have it uninitialized. Let's make sure `firestore = FakeFirebaseFirestore();` exists inside `setUp`
         if (!newContent.contains('firestore = FakeFirebaseFirestore()') && newContent.contains('setUp(')) {
           newContent = newContent.replaceFirst('setUp(() {', 'setUp(() async {\n    firestore = FakeFirebaseFirestore();');
           newContent = newContent.replaceFirst('setUp(() async {', 'setUp(() async {\n    firestore = FakeFirebaseFirestore();');
         }
      }
      
      // 5. Ensure TestSeeder.seedAll(firestore) is called inside setUp for non-auth tests that use firestore
      // We will only do this for files that we know need full data, or just all files that have firestore
      if (newContent.contains('FakeFirebaseFirestore') && newContent.contains('setUp(') && !newContent.contains('seedAll(')) {
           // We will put it after firestore initialization
           newContent = newContent.replaceAll('firestore = FakeFirebaseFirestore();', 'firestore = FakeFirebaseFirestore();\n    await TestSeeder.seedAll(firestore);');
      }

      if (content != newContent) {
        file.writeAsStringSync(newContent);
      }
    }
  }
}
