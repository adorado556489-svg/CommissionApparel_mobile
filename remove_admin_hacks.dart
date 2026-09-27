import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  
  // Remove the `orders` collection fallback in AdminService batch methods
  content = content.replaceAll(
    "if (qs.docs.isEmpty) { qs = await firestore.collection('orders').where('batchId', isEqualTo: batchId).get(); }", 
    ""
  );
  content = content.replaceAll(
    "if (qs.docs.isEmpty) { qs = await firestore.collection('orders').where('batchId', isEqualTo: batchId).where('isArchived', isEqualTo: true).get(); }", 
    ""
  );
  
  file.writeAsStringSync(content);
}
