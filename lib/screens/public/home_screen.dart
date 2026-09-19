import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../data/dummy_content.dart';
import '../../models/site_setting.dart';
import '../../models/landing_collection.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_panel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Commission Apparel',
      currentNavIndex: 0,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHero(context),
            const SizedBox(height: 32),
            _buildCollections(context),
            const SizedBox(height: 32),
            _buildFeatures(context),
            const SizedBox(height: 32),
            _buildTestimonials(context),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final title = SiteSetting.getValue(dummySiteSettings, 'hero_title') ?? 'CUSTOM TEAM APPAREL';
    final subtitle = SiteSetting.getValue(dummySiteSettings, 'hero_subtitle') ?? 'Premium quality custom jerseys and team gear.';
    final ctaText = SiteSetting.getValue(dummySiteSettings, 'hero_cta_text') ?? 'Request A Quote';

    return Stack(
      children: [
        // Background Image
        Image.asset(
          'assets/images/hero-banner.jpeg',
          height: 400,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 400,
            width: double.infinity,
            color: Colors.grey,
          ),
        ),
        // Overlay
        Container(
          height: 400,
          color: Colors.black.withOpacity(0.5),
        ),
        // Content
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed('/quote'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text(ctaText),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollections(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VIEW OUR CUSTOM COLLECTIONS',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Stand out with fully custom designs crafted to capture the essence of your program.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          // We will use a horizontal list view for collections
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: dummyLandingCollections.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final collection = dummyLandingCollections[index];
                return _buildCollectionCard(context, collection);
              },
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pushNamed('/catalog'),
              child: const Text('View Design Catalog'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(BuildContext context, LandingCollection collection) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            collection.tabName,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.accent, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            collection.title,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              collection.description ?? '',
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassPanel(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WHY CHOOSE US?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFeatureRow(context, Icons.design_services, 'Fully Custom Designs', 'Work with our team to bring your exact vision to life.'),
            const SizedBox(height: 12),
            _buildFeatureRow(context, Icons.storefront, 'Free Team Stores', 'We set up your ordering portal at no cost to your program.'),
            const SizedBox(height: 12),
            _buildFeatureRow(context, Icons.local_shipping, 'Fast Turnaround', 'Get your gear quickly when you need it for the season.'),
            const SizedBox(height: 12),
            _buildFeatureRow(context, Icons.attach_money, 'Fundraising Built-in', 'Set your own retail markup and keep the profit.'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primary, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(desc, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonials(BuildContext context) {
    if (dummyTestimonials.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHAT COACHES SAY',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: PageView.builder(
              itemCount: dummyTestimonials.length,
              itemBuilder: (context, index) {
                final testimonial = dummyTestimonials[index];
                return Card(
                  margin: const EdgeInsets.only(right: 8, bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.format_quote, color: AppTheme.borderSubtle, size: 40),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            '"${testimonial.content}"',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          testimonial.clientName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.primary),
                        ),
                        if (testimonial.organization != null)
                          Text(
                            testimonial.organization!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
