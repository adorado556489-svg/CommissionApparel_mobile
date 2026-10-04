import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/site_setting.dart';
import '../../models/testimonial.dart';
import '../../models/landing_collection.dart';
import '../../models/team_store.dart';
import '../../services/content_service.dart';
import '../../services/store_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_panel.dart';
import '../../app/theme.dart';
import '../../widgets/managed_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SiteSetting> dummySiteSettings = [];
  List<Testimonial> dummyTestimonials = [];
  List<LandingCollection> dummyLandingCollections = [];
  List<TeamStore> activeTeamStores = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final firestore = context.read<FirebaseFirestore>();
    final settings = await ContentService.getAllSiteSettings(firestore);
    final testimonials = await ContentService.getAllTestimonials(firestore);
    final collections = await ContentService.getAllLandingCollections(
      firestore,
    );
    final stores = await StoreService.getActiveStores(firestore);
    if (mounted) {
      setState(() {
        dummySiteSettings = settings;
        dummyTestimonials = testimonials;
        dummyLandingCollections = collections;
        activeTeamStores = stores;
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
            _buildTeamStores(context),
            const SizedBox(height: 24),
            _buildTestimonials(context),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final title =
        SiteSetting.getValue(dummySiteSettings, 'hero_title') ??
        'CUSTOM TEAM APPAREL';
    final subtitle =
        SiteSetting.getValue(dummySiteSettings, 'hero_subtitle') ??
        'Premium quality custom jerseys and team gear.';
    final ctaText =
        SiteSetting.getValue(dummySiteSettings, 'hero_cta_text') ??
        'Request A Quote';
    final mediaPath = SiteSetting.getValue(
      dummySiteSettings,
      'hero_media_path',
    );
    final mediaType = SiteSetting.getValue(
      dummySiteSettings,
      'hero_media_type',
    );

    Widget bgImage;
    if (mediaPath != null && mediaType == 'image') {
      bgImage = AppImage(mediaPath, fit: BoxFit.cover);
    } else {
      bgImage = Container(
        color: AppTheme.primary,
        child: Center(
          child: Icon(
            Icons.sports_basketball,
            size: 100,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
      );
    }

    return SizedBox(
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
                Text(
                  title,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondary,
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/quote'),
                  child: Text(ctaText),
                ),
              ],
            ),
          ),
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
          Text(
            'Featured Collections',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: col.imagePath != null
                          ? AppImage(col.imagePath!, fit: BoxFit.cover)
                          : Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        col.tabName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
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

  Widget _buildTeamStores(BuildContext context) {
    if (activeTeamStores.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Team Stores',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/stores'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: activeTeamStores.length,
              itemBuilder: (context, index) {
                final store = activeTeamStores[index];
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/store/detail',
                    arguments: store.id,
                  ),
                  child: Container(
                    width: 250,
                    margin: const EdgeInsets.only(right: 16),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (store.coverImagePath != null)
                            AppImage(store.coverImagePath, fit: BoxFit.cover)
                          else
                            Container(
                              color: AppTheme.primary,
                              child: const Icon(
                                Icons.store,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          Container(color: Colors.black.withValues(alpha: 0.5)),
                          if (store.logoPath != null)
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: AppImage(
                                  store.logoPath,
                                  fit: BoxFit.contain,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  store.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  store.orderDeadline != null
                                      ? 'Ends ${store.orderDeadline!.toIso8601String().substring(0, 10)}'
                                      : 'Open',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildTestimonials(BuildContext context) {
    if (dummyTestimonials.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What Coaches Say',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: PageView.builder(
              itemCount: dummyTestimonials.length,
              itemBuilder: (context, index) {
                final testimonial = dummyTestimonials[index];
                return GlassPanel(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.format_quote,
                          color: AppTheme.primary.withValues(alpha: 0.5),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '"${testimonial.content}"',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '- ${testimonial.clientName}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          testimonial.organization ?? '',
                          style: const TextStyle(color: Colors.grey),
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
