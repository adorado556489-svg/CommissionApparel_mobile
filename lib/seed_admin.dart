// ignore_for_file: avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    // 1. Create Admin User
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: 'admin@commissionapparel.com',
      password: 'AdminPassword2026!',
    );
    
    final uid = cred.user!.uid;
    print('Created admin with UID: \$uid');
    
    // 2. Seed Admin Firestore Doc
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'id': uid,
      'email': 'admin@commissionapparel.com',
      'firstName': 'Master',
      'lastName': 'Admin',
      'role': 'admin',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    print('Admin seeded successfully!');
  } catch (e) {
    if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
      print('Admin already exists! Skipping creation.');
    } else {
      print('Error seeding admin: \$e');
    }
  }
}
