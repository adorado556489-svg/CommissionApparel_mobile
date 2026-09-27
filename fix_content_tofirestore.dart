import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("collection.toMap()", "collection.toFirestore()");
  content = content.replaceAll("updatedCollection.toMap()", "updatedCollection.toFirestore()");
  content = content.replaceAll("testimonial.toMap()", "testimonial.toFirestore()");
  content = content.replaceAll("updatedTestimonial.toMap()", "updatedTestimonial.toFirestore()");
  file.writeAsStringSync(content);
}
