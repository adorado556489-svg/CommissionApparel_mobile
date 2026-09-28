import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../app/theme.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/app_scaffold.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    if (user == null) return const AppScaffold(title: 'Loading', body: Center(child: CircularProgressIndicator()));

    return AppScaffold(
      title: 'Account',
      currentNavIndex: auth.isAdmin ? 3 : 4,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primary,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(user.fullName, style: Theme.of(context).textTheme.headlineMedium),
            Text(user.email, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text('Role: ${user.role.name.toUpperCase()}'),
            if (user.organization != null) ...[
              const SizedBox(height: 4),
              Text('Organization: ${user.organization}'),
            ],
            const SizedBox(height: 32),
            GlassPanel(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                auth.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
