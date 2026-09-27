import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:commission_apparel_flutter/firebase_options.dart';

import 'package:commission_apparel_flutter/models/user.dart' as app_model;
import 'package:commission_apparel_flutter/models/design_catalog.dart';
import 'package:commission_apparel_flutter/models/landing_collection.dart';
import 'package:commission_apparel_flutter/models/testimonial.dart';
import 'package:commission_apparel_flutter/models/site_setting.dart';
import '../test/fixtures/dummy_users.dart';
import '../test/fixtures/dummy_catalog.dart';
import '../test/fixtures/dummy_content.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('================================================');
  print('          ANTIGRAVITY SEEDER UTILITY            ');
  print('================================================');
  
  print('Initializing Firebase for current environment...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final projectId = Firebase.app().options.projectId;
  print('Target Project ID: $projectId');
  print('WARNING: THIS WILL OVERWRITE EXISTING DATA IF PROCEEDING.');
  
  stdout.write('Are you sure you want to seed this environment? (y/N): ');
  final confirm = stdin.readLineSync();
  if (confirm?.toLowerCase() != 'y') {
    print('Aborting.');
    exit(0);
  }

  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;
  
  // Abort if siteSettings exists
  final ssDoc = await firestore.collection('siteSettings').doc('hero_subtitle').get();
  if (ssDoc.exists) {
    print('ERROR: Environment is already seeded (siteSettings exists). Aborting.');
    exit(1);
  }

  print('Please enter the Admin password to create:');
  final adminPassword = stdin.readLineSync();
  if (adminPassword == null || adminPassword.length < 8) {
    print('Invalid password. Aborting.');
    exit(1);
  }

  print('Creating Admin Auth Account...');
  UserCredential? cred;
  try {
    cred = await auth.createUserWithEmailAndPassword(
      email: 'admin@example.com',
      password: adminPassword,
    );
  } catch (e) {
    print('Failed to create admin user: $e');
    try {
      cred = await auth.signInWithEmailAndPassword(email: 'admin@example.com', password: adminPassword);
      print('Logged in as existing admin.');
    } catch (e2) {
      print('Also failed to login. Aborting.');
      exit(1);
    }
  }
  
  final uid = cred!.user!.uid;
  print('Admin UID: $uid');
  
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
  
  print('Seeding Admin User Document...');
  await firestore.collection('users').doc(uid).set(adminUser.toFirestore());

  print('Seeding Design Catalog...');
  for (var catalog in dummyDesignCatalog) {
    String? imageUrl;
    try {
      final file = File('assets/images/basketball.png');
      if (file.existsSync()) {
        final ref = storage.ref().child('catalog/${catalog.id}/primary.png');
        await ref.putFile(file);
        imageUrl = await ref.getDownloadURL();
      }
    } catch (e) {
      print('Warning: Failed to upload asset for ${catalog.id}: $e');
    }
    
    final catWithImg = catalog.copyWith(imagePaths: imageUrl != null ? [imageUrl] : []);
    await firestore.collection('designCatalog').doc(catalog.id).set(catWithImg.toFirestore());
  }
  
  print('Seeding Landing Collections...');
  for (var collection in dummyLandingCollections) {
    String? imageUrl;
    try {
      final file = File('assets/images/basketball.png');
      if (file.existsSync()) {
        final ref = storage.ref().child('landing_collections/${collection.id}/primary.png');
        await ref.putFile(file);
        imageUrl = await ref.getDownloadURL();
      }
    } catch (e) {
      print('Warning: Failed to upload asset for ${collection.id}: $e');
    }
    
    final colWithImg = collection.copyWith(imagePath: imageUrl);
    await firestore.collection('landingCollections').doc(collection.id).set(colWithImg.toFirestore());
  }
  
  print('Seeding Testimonials...');
  for (var testimonial in dummyTestimonials) {
    String? imageUrl;
    try {
      final file = File('assets/images/hero-models.png');
      if (file.existsSync()) {
        final ref = storage.ref().child('testimonials/${testimonial.id}/primary.png');
        await ref.putFile(file);
        imageUrl = await ref.getDownloadURL();
      }
    } catch (e) {
      print('Warning: Failed to upload asset for ${testimonial.id}: $e');
    }
    
    final tesWithImg = testimonial.copyWith(imagePath: imageUrl);
    await firestore.collection('testimonials').doc(testimonial.id).set(tesWithImg.toFirestore());
  }
  
  print('Seeding Site Settings...');
  for (var setting in dummySiteSettings) {
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
        print('Warning: Failed to upload asset for hero_media_path: $e');
      }
    }
    await firestore.collection('siteSettings').doc(setting.id).set(setting.toFirestore());
  }

  print('Seeding Complete! You may now run the app normally.');
  exit(0);
}
