import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseFirestoreService {
  final FirebaseFirestore firestore;

  const BaseFirestoreService({required this.firestore});

  // Common helpers can go here
  String generateId(String collectionPath) {
    return firestore.collection(collectionPath).doc().id;
  }
}
