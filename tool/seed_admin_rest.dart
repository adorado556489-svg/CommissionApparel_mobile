// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  const apiKey = 'AIzaSyAyOsX361xbJq0F5kPv1ppowJGlV0HRY0s';
  const projectId = 'commissionappareldb';
  
  final authUrl = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey');
  final authRes = await http.post(
    authUrl,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': 'admin@commissionapparel.com',
      'password': 'AdminPassword2026!',
      'returnSecureToken': true
    })
  );
  
  var uid = '';
  var idToken = '';
  
  if (authRes.statusCode == 200) {
    final data = jsonDecode(authRes.body);
    uid = data['localId'];
    idToken = data['idToken'];
    print('Created admin with UID: $uid');
  } else {
    final err = jsonDecode(authRes.body);
    if (err['error'] != null && err['error']['message'] == 'EMAIL_EXISTS') {
      print('Admin already exists! Attempting to login to get token...');
      final loginUrl = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey');
      final loginRes = await http.post(
        loginUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'admin@commissionapparel.com',
          'password': 'AdminPassword2026!',
          'returnSecureToken': true
        })
      );
      if (loginRes.statusCode == 200) {
        final data = jsonDecode(loginRes.body);
        uid = data['localId'];
        idToken = data['idToken'];
        print('Logged in admin with UID: $uid');
      } else {
        print('Failed to login: ${loginRes.body}');
        return;
      }
    } else {
      print('Failed to create admin: ${authRes.body}');
      return;
    }
  }

  final firestoreUrl = Uri.parse('https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/users/$uid');
  final fsRes = await http.patch(
    firestoreUrl,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken'
    },
    body: jsonEncode({
      'fields': {
        'id': {'stringValue': uid},
        'email': {'stringValue': 'admin@commissionapparel.com'},
        'firstName': {'stringValue': 'Master'},
        'lastName': {'stringValue': 'Admin'},
        'role': {'stringValue': 'admin'},
        'status': {'stringValue': 'active'},
        'createdAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        'updatedAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
      }
    })
  );

  if (fsRes.statusCode == 200) {
    print('Admin document seeded successfully!');
  } else {
    print('Failed to seed admin document: ${fsRes.body}');
  }
}
