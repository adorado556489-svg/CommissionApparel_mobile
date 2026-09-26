import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../widgets/app_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/design_collection.dart';
import '../../services/catalog_service.dart';
import '../../models/design_catalog.dart';

class CatalogCollectionScreen extends StatefulWidget {
  final String collectionId;

  const CatalogCollectionScreen({super.key, required this.collectionId});

  @override
  State<CatalogCollectionScreen> createState() => _CatalogCollectionScreenState();
}

class _CatalogCollectionScreenState extends State<CatalogCollectionScreen> {
  String _selectedSport = 'All Sports';
  DesignCollection? _collection;
  List<DesignCatalog> _catalogItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final firestore = context.read<FirebaseFirestore>();
    final collections = await CatalogService.getAllDesignCollections(firestore);
    final catalog = await CatalogService.getAllDesignCatalog(firestore);
    if (mounted) {
      setState(() {
        _collection = collections.firstWhere((c) => c.id == widget.collectionId, orElse: () => collections.first);
        _catalogItems = catalog;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const AppScaffold(title: 'Collection', body: Center(child: CircularProgressIndicator()));
    final collection = _collection!;


    // Filter designs
    var designs = _catalogItems.where((d) => d.designCollectionId == collection.id).toList();
    
    final availableSports = designs.map((d) => d.sport).whereType<String>().toSet().toList();
    availableSports.insert(0, 'All Sports');

    if (_selectedSport != 'All Sports') {
      designs = designs.where((d) => d.sport == _selectedSport).toList();
    }

    return AppScaffold(
      title: '${collection.name} | Design Catalog',
      currentNavIndex: 1,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, collection.name),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilters(availableSports, designs.length),
                  const SizedBox(height: 24),
                  if (designs.isEmpty)
                    _buildEmptyState()
                  else
                    _buildGrid(context, designs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String collectionName) {
    return Container(
      width: double.infinity,
      color: AppTheme.surfaceLight,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Text(
                  'DESIGN COLLECTIONS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.secondary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              const Text('/', style: TextStyle(color: AppTheme.textMuted)),
              const SizedBox(width: 8),
              Text(
                collectionName.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.textMuted, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _selectedSport != 'All Sports' ? '$collectionName: $_selectedSport'.toUpperCase() : collectionName.toUpperCase(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            'Explore our latest team apparel concepts across all packages and individual items.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(List<String> sports, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FILTER BY CATEGORIES', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: 200,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSport,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
                  items: sports.map((sport) {
                    return DropdownMenuItem(value: sport, child: Text(sport, style: Theme.of(context).textTheme.bodyMedium));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSport = val);
                  },
                ),
              ),
            ),
          ],
        ),
        Text(
          'SHOWING $count DESIGN${count == 1 ? '' : 'S'}',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildGrid(BuildContext context, List<DesignCatalog> designs) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
      ),
      itemCount: designs.length,
      itemBuilder: (context, index) {
        final design = designs[index];
        return _buildDesignCard(context, design);
      },
    );
  }

  Widget _buildDesignCard(BuildContext context, DesignCatalog design) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: AppTheme.primary.withOpacity(0.05),
              width: double.infinity,
              child: const Center(
                child: Icon(Icons.image, size: 64, color: AppTheme.borderSubtle),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (design.category != null && design.category!.startsWith('package'))
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.secondary.withOpacity(0.2)),
                    ),
                    child: Text(
                      'PACKAGE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.secondary, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                Text(
                  design.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  design.description ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: design.types.map((type) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: Text(
                        type.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle, style: BorderStyle.solid),
      ),
      child: Text(
        'NO DESIGNS FOUND.',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.textMuted, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}


