import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../models/landing_collection.dart';
import '../../models/site_setting.dart';
import '../../models/testimonial.dart';
import '../../services/content_service.dart';
import '../../widgets/app_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SiteSetting> dummySiteSettings = [];
  List<Testimonial> dummyTestimonials = [];
  List<LandingCollection> dummyLandingCollections = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final firestore = context.read<FirebaseFirestore>();
    final settings = await ContentService.getAllSiteSettings(firestore);
    final testimonials = await ContentService.getAllTestimonials(firestore);
    final collections = await ContentService.getAllLandingCollections(firestore);
    if (mounted) {
      setState(() {
        dummySiteSettings = settings;
        dummyTestimonials = testimonials;
        dummyLandingCollections = collections;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Home',
      currentNavIndex: 0,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHero(context),
            const SizedBox(height: 24),
            _buildProducts(context),
            const SizedBox(height: 24),
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
    final mediaPath = SiteSetting.getValue(dummySiteSettings, 'hero_media_path');
    final mediaType = SiteSetting.getValue(dummySiteSettings, 'hero_media_type');

    Widget bgImage;
    if (mediaPath != null && mediaType == 'image') {
      bgImage = Image.network(mediaPath, fit: BoxFit.cover);
    } else {
      bgImage = Container(
        color: AppTheme.primary,
        child: Center(
          child: Icon(Icons.sports_basketball, size: 100, color: Colors.white.withValues(alpha: 0.2)),
        ),
      );
    }

    return Container(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          bgImage,
          Container(color: Colors.black.withValues(alpha: 0.4)),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(subtitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70)),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary),
                  onPressed: () => Navigator.pushNamed(context, '/quote'),
                  child: Text(ctaText),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProducts(BuildContext context) {
    if (dummyLandingCollections.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Featured Collections', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: dummyLandingCollections.length,
            itemBuilder: (context, index) {
              final col = dummyLandingCollections[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: col.imagePath != null
                          ? Image.network(col.imagePath!, fit: BoxFit.cover)
                          : Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 48, color: Colors.grey)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(col.tabName, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonials(BuildContext context) {
    if (dummyTestimonials.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What Coaches Say', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Container(
            height: 220,
            child: PageView.builder(
              itemCount: dummyTestimonials.length,
              itemBuilder: (context, index) {
                final testimonial = dummyTestimonials[index];
                return Card(
                  margin: const EdgeInsets.only(right: 8, bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.format_quote, color: AppTheme.accent, size: 32),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            '"${testimonial.content}"',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('- ${testimonial.clientName}, ${testimonial.organization}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
