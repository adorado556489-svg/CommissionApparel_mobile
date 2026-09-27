import 'dart:io';

void main() {
  var linesToRemove = [
    "if (dummyUsers.any((u) => u.email == email && u.id != coach.id)) {",
    "final coachStoreIds = dummyTeamStores.where((s) => s.userId == coachId).map((s) => s.id).toSet();",
    "dummyUsers.removeAt(index);",
    "for (var i = 0; i < dummyParentOrders.length; i++) {",
    "final o = dummyParentOrders[i];",
    "dummyParentOrders[i] = o.copyWith(status: 'Processing', isArchived: true);",
    "dummyParentOrders[i] = o.copyWith(",
    "final initialLength = dummyParentOrders.length;",
    "if (dummyParentOrders.length == initialLength) {",
    "dummyLandingCollections.add(collection);",
    "dummyLandingCollections[index] = updatedCollection;",
    "dummyLandingCollections.removeWhere((c) => c.id == collectionId);",
    "dummyLandingCollections.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));",
    "dummyTestimonials.add(testimonial);",
    "dummyTestimonials[index] = updatedTestimonial;",
    "dummyTestimonials.removeWhere((t) => t.id == testimonialId);",
    "dummyTestimonials.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));",
    "final subIdx = dummySiteSettings.indexWhere((s) => s.key == 'hero_subtitle');",
    "final pathIdx = dummySiteSettings.indexWhere((s) => s.key == 'hero_media_path');",
    "final typeIdx = dummySiteSettings.indexWhere((s) => s.key == 'hero_media_type');",
    "dummySiteSettings.removeWhere((s) => s.key == 'hero_media_path' || s.key == 'hero_media_type');",
    "dummyQuoteRequests[index] = dummyQuoteRequests[index].copyWith(status: 'addressed');",
    "final existsInDummy = dummyUsers.any((u) => u.email.toLowerCase() == normalizedEmail);",
    "final userIndex = dummyUsers.indexWhere(",
    "dummyDesignCatalog.add(item);",
    "if (idx != -1) dummyDesignCatalog[idx] = item;",
    "dummyDesignCatalog.removeWhere((d) => d.id == id);",
    "dummyDesignCollections.add(collection);",
    "if (idx != -1) dummyDesignCollections[idx] = collection;",
    "dummyDesignCollections.removeWhere((c) => c.id == id);",
    "return dummyLandingCollections;",
    "if (idx != -1) dummyLandingCollections[idx] = collection;",
    "dummyLandingCollections.removeWhere((c) => c.id == id);",
    "return dummyTeamStores[storeIndex].userId == currentUser.id;",
    "dummyParentOrders[i] = o.copyWith(status: 'Submitted to Admin', batchId: batchId, updatedAt: DateTime.now());",
    "final adminUsers = dummyUsers.where((u) => u.isAdmin).map((u) => u.id).toSet();",
    "return dummyTeamStores.firstWhere(",
  ];

  var dir = Directory('lib/services');
  for (var file in dir.listSync()) {
    if (file is File && file.path.endsWith('.dart')) {
      var lines = file.readAsLinesSync();
      var newLines = <String>[];
      for (var line in lines) {
         bool shouldRemove = false;
         for (var rm in linesToRemove) {
           if (line.contains(rm)) {
             shouldRemove = true;
             break;
           }
         }
         if (!shouldRemove) {
           newLines.add(line);
         }
      }
      file.writeAsStringSync(newLines.join('\n'));
    }
  }
}
