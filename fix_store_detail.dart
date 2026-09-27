import 'dart:io';

void main() {
  var file = File('lib/screens/public/store_detail_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport '../../services/store_service.dart';\nimport '../../services/auth_service.dart';\nimport '../../models/user.dart';\nimport '../../models/team_store.dart';");
  
  content = content.replaceFirst(
'''  @override
  Widget build(BuildContext context) {
    final store = dummyTeamStores.firstWhere(
      (s) => s.id == storeId,
      orElse: () => dummyTeamStores.first,
    );
    final coach = dummyUsers.firstWhere((u) => u.id == store.userId, orElse: () => dummyAdmin);
    final items = dummyStoreItems.where((i) => i.teamStoreId == store.id).toList();

    return AppScaffold(
      title: store.name,
      currentNavIndex: 2,
      body: SingleChildScrollView(
        child: Column(''', 
'''  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        StoreService.getStoreById(FirebaseFirestore.instance, storeId),
        StoreService.getStoreItems(FirebaseFirestore.instance, storeId)
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (snapshot.hasError || snapshot.data == null || snapshot.data![0] == null) return const Scaffold(body: Center(child: Text('Store not found')));
        final store = snapshot.data![0] as TeamStore;
        final items = snapshot.data![1] as List<StoreItem>;
        
        return FutureBuilder(
          future: AuthService(firestore: FirebaseFirestore.instance, firebaseAuth: null).getUserById(store.userId),
          builder: (context, AsyncSnapshot<User?> coachSnapshot) {
            final coach = coachSnapshot.data ?? dummyAdmin;
            
            return AppScaffold(
              title: store.name,
              currentNavIndex: 2,
              body: SingleChildScrollView(
                child: Column(''');
                
  content = content.replaceFirst(
'''        ),
      ),
    );
  }''',
'''        ),
      ),
    );
          }
        );
      }
    );
  }''');

  file.writeAsStringSync(content);
}
