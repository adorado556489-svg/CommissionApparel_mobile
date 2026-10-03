import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_panel.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Help & Support',
      showNavBar: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Frequently Asked Questions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            GlassPanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ExpansionTile(
                    title: const Text('How do I track my commission?'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'If you are a coach, you can track your total sales and commission earned from your dashboard under the Commission Dashboard section.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 1),
                  ExpansionTile(
                    title: const Text('How are orders fulfilled?'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Once a store campaign is closed, all batched orders will be processed and shipped together. Direct shipping orders are processed separately.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 1),
                  ExpansionTile(
                    title: const Text('I forgot my password, what do I do?'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'You can reset your password using the "Forgot Password" link on the login screen. You will receive an email with instructions.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Contact Us', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            GlassPanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email Support'),
                    subtitle: const Text('support@commissionapparel.com'),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening email client...')));
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: const Text('Call Us'),
                    subtitle: const Text('1-800-555-0199'),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening phone dialer...')));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Commission Apparel v1.0.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
