import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();

  content = content.replaceFirst('''    final subIndex = dummySiteSettings.indexWhere((s) => s.key == 'hero_subtitle');
    if (subIndex != -1) {
      dummySiteSettings[subIndex] = dummySiteSettings[subIndex].copyWith(value: subtitle, updatedAt: DateTime.now());
    } else {
      dummySiteSettings.add(SiteSetting(id: 'hero_subtitle', key: 'hero_subtitle', value: subtitle, createdAt: DateTime.now(), updatedAt: DateTime.now()));
    }

    if (mediaPath != null && mediaType != null) {
      final pathIndex = dummySiteSettings.indexWhere((s) => s.key == 'hero_media_path');
      if (pathIndex != -1) {
        dummySiteSettings[pathIndex] = dummySiteSettings[pathIndex].copyWith(value: mediaPath, updatedAt: DateTime.now());
      } else {
        dummySiteSettings.add(SiteSetting(id: 'hero_media_path', key: 'hero_media_path', value: mediaPath, createdAt: DateTime.now(), updatedAt: DateTime.now()));
      }
      
      final typeIndex = dummySiteSettings.indexWhere((s) => s.key == 'hero_media_type');
      if (typeIndex != -1) {
        dummySiteSettings[typeIndex] = dummySiteSettings[typeIndex].copyWith(value: mediaType, updatedAt: DateTime.now());
      } else {
        dummySiteSettings.add(SiteSetting(id: 'hero_media_type', key: 'hero_media_type', value: mediaType, createdAt: DateTime.now(), updatedAt: DateTime.now()));
      }
    }''', 
  '''final batch = firestore.batch();
    batch.set(firestore.collection('siteSettings').doc('hero_subtitle'), {'key': 'hero_subtitle', 'value': subtitle, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    if (mediaPath != null) {
      batch.set(firestore.collection('siteSettings').doc('hero_media_path'), {'key': 'hero_media_path', 'value': mediaPath, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      if (mediaType != null) batch.set(firestore.collection('siteSettings').doc('hero_media_type'), {'key': 'hero_media_type', 'value': mediaType, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    }
    await batch.commit();''');

  content = content.replaceFirst("dummySiteSettings.removeWhere((s) => s.key == 'hero_media_path' || s.key == 'hero_media_type');", 
  "await firestore.collection('siteSettings').doc('hero_media_path').delete(); await firestore.collection('siteSettings').doc('hero_media_type').delete();");

  file.writeAsStringSync(content);
}
