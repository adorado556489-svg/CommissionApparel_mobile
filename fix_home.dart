import 'dart:io';

void main() {
  var file = File('lib/screens/public/home_screen.dart');
  var content = file.readAsStringSync();

  content = content.replaceFirst("import '../../services/content_service.dart';", r"""import '../../services/content_service.dart';
import '../../services/store_service.dart';
import '../../models/team_store.dart';""");

  content = content.replaceFirst("List<LandingCollection> dummyLandingCollections = [];", r"""List<LandingCollection> dummyLandingCollections = [];
  List<TeamStore> activeTeamStores = [];""");

  content = content.replaceFirst("final collections = await ContentService.getAllLandingCollections(firestore);", r"""final collections = await ContentService.getAllLandingCollections(firestore);
    final stores = await StoreService.getActiveStores(firestore);""");

  content = content.replaceFirst("dummyLandingCollections = collections;", r"""dummyLandingCollections = collections;
        activeTeamStores = stores;""");

  var buildHeroTarget = RegExp(r"_buildProducts\(context\),", dotAll: true);
  content = content.replaceFirst(buildHeroTarget, r"_buildTeamStores(context),");

  var buildProductsRegex = RegExp(r"Widget _buildProducts\(BuildContext context\) \{.*?\}\n\n  Widget _buildTestimonials", dotAll: true);
  var buildTeamStores = r'''Widget _buildTeamStores(BuildContext context) {
    if (activeTeamStores.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Featured Team Stores', style: Theme.of(context).textTheme.headlineMedium),
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
            itemCount: activeTeamStores.length,
            itemBuilder: (context, index) {
              final store = activeTeamStores[index];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/store/${store.id}'),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: store.coverImageUrl != null
                            ? Image.network(store.coverImageUrl!, fit: BoxFit.cover)
                            : Container(color: Colors.grey[200], child: const Icon(Icons.store, size: 48, color: Colors.grey)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(store.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonials''';
  
  content = content.replaceFirst(buildProductsRegex, buildTeamStores);
  file.writeAsStringSync(content);
}
