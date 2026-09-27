import 'dart:io';

void main() {
  var file = File('lib/services/order_service.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceFirst("ParentOrder.fromMap(doc.data(), doc.id)", "ParentOrder.fromFirestore(doc)");
  content = content.replaceFirst("ParentOrder.fromMap(doc.data() as Map<String, dynamic>, doc.id)", "ParentOrder.fromFirestore(doc)");
  
  file.writeAsStringSync(content);
}
