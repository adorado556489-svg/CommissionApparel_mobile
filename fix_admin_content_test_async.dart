import 'dart:io';

void main() {
  var file = File('test/admin_content_test.dart');
  var content = file.readAsStringSync();
  
  // updateHeroSettings
  content = content.replaceFirst("AdminService.updateHeroSettings(adminUser, subtitle: 'New Subtitle');", "await AdminService.updateHeroSettings(firestore, adminUser, subtitle: 'New Subtitle');");
  content = content.replaceFirst("final hero = dummySiteSettings.firstWhere((s) => s.key == 'hero_subtitle');\n      expect(hero.value, 'New Subtitle');", 
  "final doc = await firestore.collection('siteSettings').doc('hero_subtitle').get(); expect(doc.data()?['value'], 'New Subtitle');");

  // removeHeroMedia
  content = content.replaceFirst("AdminService.removeHeroMedia(adminUser);", "await AdminService.removeHeroMedia(firestore, adminUser);");
  
  // manage landing collections
  content = content.replaceFirst("test('Admin can manage landing collections', () {", "test('Admin can manage landing collections', () async {");
  content = content.replaceFirst("AdminService.createLandingCollection(adminUser, collection);", "await AdminService.createLandingCollection(firestore, adminUser, collection);");
  content = content.replaceFirst("expect(dummyLandingCollections.any((c) => c.id == 'coll-test'), isTrue);", "final doc = await firestore.collection('landingCollections').doc('coll-test').get(); expect(doc.exists, isTrue);");
  
  content = content.replaceFirst("AdminService.updateLandingCollection(adminUser, collection.copyWith(title: 'Updated Title'));", "await AdminService.updateLandingCollection(firestore, adminUser, collection.copyWith(title: 'Updated Title'));");
  content = content.replaceFirst("final updated = dummyLandingCollections.firstWhere((c) => c.id == 'coll-test');\n      expect(updated.title, 'Updated Title');", "final doc2 = await firestore.collection('landingCollections').doc('coll-test').get(); expect(doc2.data()?['title'], 'Updated Title');");
  
  content = content.replaceFirst("AdminService.deleteLandingCollection(adminUser, 'coll-test');", "await AdminService.deleteLandingCollection(firestore, adminUser, 'coll-test');");
  content = content.replaceFirst("expect(dummyLandingCollections.any((c) => c.id == 'coll-test'), isFalse);", "final doc3 = await firestore.collection('landingCollections').doc('coll-test').get(); expect(doc3.exists, isFalse);");

  // manage testimonials
  content = content.replaceFirst("test('Admin can manage testimonials', () {", "test('Admin can manage testimonials', () async {");
  content = content.replaceFirst("AdminService.createTestimonial(adminUser, testimonial);", "await AdminService.createTestimonial(firestore, adminUser, testimonial);");
  content = content.replaceFirst("expect(dummyTestimonials.any((t) => t.id == 'test-1'), isTrue);", "final doc = await firestore.collection('testimonials').doc('test-1').get(); expect(doc.exists, isTrue);");

  content = content.replaceFirst("AdminService.updateTestimonial(adminUser, testimonial.copyWith(authorName: 'Updated Author'));", "await AdminService.updateTestimonial(firestore, adminUser, testimonial.copyWith(authorName: 'Updated Author'));");
  content = content.replaceFirst("final updated = dummyTestimonials.firstWhere((t) => t.id == 'test-1');\n      expect(updated.authorName, 'Updated Author');", "final doc2 = await firestore.collection('testimonials').doc('test-1').get(); expect(doc2.data()?['authorName'], 'Updated Author');");

  content = content.replaceFirst("AdminService.deleteTestimonial(adminUser, 'test-1');", "await AdminService.deleteTestimonial(firestore, adminUser, 'test-1');");
  content = content.replaceFirst("expect(dummyTestimonials.any((t) => t.id == 'test-1'), isFalse);", "final doc3 = await firestore.collection('testimonials').doc('test-1').get(); expect(doc3.exists, isFalse);");

  // markQuoteAddressed
  content = content.replaceFirst("test('Admin can mark quote request as addressed', () {", "test('Admin can mark quote request as addressed', () async {");
  content = content.replaceFirst("final error = AdminService.markQuoteAddressed(adminUser, 'quote-1');", "await firestore.collection('quoteRequests').doc('quote-1').set({'isAddressed': false}); final error = await AdminService.markQuoteAddressed(firestore, adminUser, 'quote-1');");
  content = content.replaceFirst("final updated = dummyQuoteRequests.firstWhere((q) => q.id == 'quote-1');\n      expect(updated.isAddressed, isTrue);", "final doc = await firestore.collection('quoteRequests').doc('quote-1').get(); expect(doc.data()?['isAddressed'], isTrue);");
  content = content.replaceFirst("AdminService.markQuoteAddressed(adminUser, 'quote-1'); // Actually this is undo? wait, the test doesn't undo, it just runs.", "");

  file.writeAsStringSync(content);
}
