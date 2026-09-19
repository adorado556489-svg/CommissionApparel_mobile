import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_panel.dart';

class QuoteSuccessScreen extends StatelessWidget {
  const QuoteSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Quote Request Sent',
      currentNavIndex: 3,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: GlassPanel(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, size: 64, color: AppTheme.success),
                const SizedBox(height: 24),
                Text(
                  'REQUEST RECEIVED',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Thank you for requesting a quote! Our design team has received your information and will be in touch within 48 hours to begin building your custom armor.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                  child: const Text('RETURN TO HOME'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
