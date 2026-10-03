import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:commission_apparel_flutter/firebase_options.dart';

import 'package:commission_apparel_flutter/models/user.dart' as app_model;
import '../test/fixtures/dummy_catalog.dart';
import '../test/fixtures/dummy_content.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('================================================');
  debugPrint('          ANTIGRAVITY SEEDER UTILITY            ');
  debugPrint('================================================');
  
  debugPrint('Initializing Firebase for current environment...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final projectId = Firebase.app().options.projectId;
  debugPrint('Target Project ID: $projectId');
  debugPrint('WARNING: THIS WILL OVERWRITE EXISTING DATA IF PROCEEDING.');
  
  stdout.write('Are you sure you want to seed this environment? (y/N): ');
  final confirm = stdin.readLineSync();
  if (confirm?.toLowerCase() != 'y') {
    debugPrint('Aborting.');
    exit(0);
  }

  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;
  
  // Abort if siteSettings exists
  final ssDoc = await firestore.collection('siteSettings').doc('hero_subtitle').get();
  if (ssDoc.exists) {
    debugPrint('ERROR: Environment is already seeded (siteSettings exists). Aborting.');
    exit(1);
  }

  debugPrint('Please enter the Admin password to create:');
  final adminPassword = stdin.readLineSync();
  if (adminPassword == null || adminPassword.length < 8) {
    debugPrint('Invalid password. Aborting.');
    exit(1);
  }

  debugPrint('Creating Admin Auth Account...');
  UserCredential? cred;
  try {
    cred = await auth.createUserWithEmailAndPassword(
      email: 'admin@example.com',
      password: adminPassword,
    );
  } catch (e) {
    debugPrint('Failed to create admin user: $e');
    try {
      cred = await auth.signInWithEmailAndPassword(email: 'admin@example.com', password: adminPassword);
      debugPrint('Logged in as existing admin.');
    } catch (e2) {
      debugPrint('Also failed to login. Aborting.');
      exit(1);
    }
  }
  
  final uid = cred.user!.uid;
  debugPrint('Admin UID: $uid');
  
  final adminUser = app_model.User(
    id: uid,
    email: 'admin@example.com',
    firstName: 'Admin',
    lastName: 'System',
    role: app_model.UserRole.admin,
    password: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  
  debugPrint('Seeding Admin User Document...');
  await firestore.collection('users').doc(uid).set(adminUser.toFirestore());

  debugPrint('Seeding Design Catalog...');
  for (var catalog in rawdummyDesignCatalog) {
    String? imageUrl;
    try {
      final file = File('assets/images/basketball.png');
      if (file.existsSync()) {
        final ref = storage.ref().child('catalog/${catalog.id}/primary.png');
        await ref.putFile(file);
        imageUrl = await ref.getDownloadURL();
      }
    } catch (e) {
      debugPrint('Warning: Failed to upload asset for ${catalog.id}: $e');
    }
    
    final catWithImg = catalog.copyWith(imagePaths: imageUrl != null ? [imageUrl] : []);
    await firestore.collection('designCatalog').doc(catalog.id).set(catWithImg.toFirestore());
  }
  
  debugPrint('Seeding Landing Collections...');
  for (var collection in rawdummyLandingCollections) {
    String? imageUrl;
    try {
      final file = File('assets/images/basketball.png');
      if (file.existsSync()) {
        final ref = storage.ref().child('landing_collections/${collection.id}/primary.png');
        await ref.putFile(file);
        imageUrl = await ref.getDownloadURL();
      }
    } catch (e) {
      debugPrint('Warning: Failed to upload asset for ${collection.id}: $e');
    }
    
    final colWithImg = collection.copyWith(imagePath: imageUrl);
    await firestore.collection('landingCollections').doc(collection.id).set(colWithImg.toFirestore());
  }
  
  debugPrint('Seeding Testimonials...');
  for (var testimonial in rawdummyTestimonials) {
    String? imageUrl;
    try {
      final file = File('assets/images/hero-models.png');
      if (file.existsSync()) {
        final ref = storage.ref().child('testimonials/${testimonial.id}/primary.png');
        await ref.putFile(file);
        imageUrl = await ref.getDownloadURL();
      }
    } catch (e) {
      debugPrint('Warning: Failed to upload asset for ${testimonial.id}: $e');
    }
    
    final tesWithImg = testimonial.copyWith(imagePath: imageUrl);
    await firestore.collection('testimonials').doc(testimonial.id).set(tesWithImg.toFirestore());
  }
  
  debugPrint('Seeding Site Settings...');
  for (var setting in rawdummySiteSettings) {
    if (setting.key == 'hero_media_path') {
      try {
        final file = File('assets/images/hero-banner.jpeg');
        if (file.existsSync()) {
          final ref = storage.ref().child('site_settings/hero-banner.jpeg');
          await ref.putFile(file);
          final imageUrl = await ref.getDownloadURL();
          final sWithImg = setting.copyWith(value: imageUrl);
          await firestore.collection('siteSettings').doc(setting.id).set(sWithImg.toFirestore());
          continue;
        }
      } catch (e) {
        debugPrint('Warning: Failed to upload asset for hero_media_path: $e');
      }
    }
    await firestore.collection('siteSettings').doc(setting.id).set(setting.toFirestore());
  }

  debugPrint('Seeding Complete! You may now run the app normally.');
  exit(0);
}
