import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_panel.dart';
import '../../models/team_store.dart';
import '../../models/user.dart';
import '../../services/store_service.dart';
import '../../services/auth_service.dart';


class StoreSearchScreen extends StatefulWidget {
  const StoreSearchScreen({super.key});

  @override
  State<StoreSearchScreen> createState() => _StoreSearchScreenState();
}

class _StoreSearchScreenState extends State<StoreSearchScreen> {
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirebaseFirestore>();
    return AppScaffold(
      title: 'Find a Store',
      currentNavIndex: 2,
      body: FutureBuilder<List<TeamStore>>(
        future: StoreService.getActiveStores(firestore),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final stores = snapshot.data ?? [];
          
          final filteredStores = stores.where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search team name or coach...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredStores.length,
                  itemBuilder: (context, index) {
                    final store = filteredStores[index];
                    return FutureBuilder<User?>(
                      future: AuthService(firestore: firestore).getUserById(store.userId),
                      builder: (context, userSnap) {
                        final coach = userSnap.data;
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.store)),
                            title: Text(store.name),
                            subtitle: Text(coach != null ? 'Coach: ${coach.fullName}' : 'Coach: Unknown'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => Navigator.pushNamed(context, '/store', arguments: store.id),
                          ),
                        );
                      }
                    );
                  },
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}
