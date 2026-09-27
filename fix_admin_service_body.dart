import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();

  content = content.replaceFirst("dummyLandingCollections.add(collection);\n    _sortLandingCollections();", "await firestore.collection('landingCollections').doc(collection.id).set(collection.toFirestore());");

  content = content.replaceFirst("final index = dummyLandingCollections.indexWhere((c) => c.id == updatedCollection.id);\n    if (index == -1) return 'Collection not found';\n    dummyLandingCollections[index] = updatedCollection.copyWith(updatedAt: DateTime.now());\n    _sortLandingCollections();", 
  "await firestore.collection('landingCollections').doc(updatedCollection.id).update(updatedCollection.copyWith(updatedAt: DateTime.now()).toFirestore());");
  
  content = content.replaceFirst("dummyLandingCollections.removeWhere((c) => c.id == collectionId);", "await firestore.collection('landingCollections').doc(collectionId).delete();");

  content = content.replaceFirst("dummyTestimonials.add(testimonial);\n    _sortTestimonials();", "await firestore.collection('testimonials').doc(testimonial.id).set(testimonial.toFirestore());");
  
  content = content.replaceFirst("final index = dummyTestimonials.indexWhere((t) => t.id == updatedTestimonial.id);\n    if (index == -1) return 'Testimonial not found';\n    dummyTestimonials[index] = updatedTestimonial.copyWith(updatedAt: DateTime.now());\n    _sortTestimonials();",
  "await firestore.collection('testimonials').doc(updatedTestimonial.id).update(updatedTestimonial.copyWith(updatedAt: DateTime.now()).toFirestore());");
  
  content = content.replaceFirst("dummyTestimonials.removeWhere((t) => t.id == testimonialId);", "await firestore.collection('testimonials').doc(testimonialId).delete();");
  
  // markQuoteAddressed
  content = content.replaceFirst("final index = dummyQuoteRequests.indexWhere((q) => q.id == quoteId);\n    if (index == -1) return 'Quote not found';\n\n    dummyQuoteRequests[index] = dummyQuoteRequests[index].copyWith(\n      isAddressed: true,\n      updatedAt: DateTime.now(),\n    );",
  "await firestore.collection('quoteRequests').doc(quoteId).update({'isAddressed': true, 'updatedAt': FieldValue.serverTimestamp()});");
  
  // resetCoachPassword
  content = content.replaceFirst("final index = dummyUsers.indexWhere((u) => u.id == coach.id);\n    if (index == -1) return 'Coach not found';\n\n    dummyUsers[index] = dummyUsers[index].copyWith(\n      password: newPassword,\n      updatedAt: DateTime.now(),\n    );",
  "await firestore.collection('users').doc(coach.id).update({'password': newPassword, 'updatedAt': FieldValue.serverTimestamp()});");

  file.writeAsStringSync(content);
}
