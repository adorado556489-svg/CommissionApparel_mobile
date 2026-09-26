import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_panel.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/catalog_service.dart';
import '../../models/design_collection.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _selectedCategory = 'All Categories';
  List<DesignCollection> _collections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    final firestore = context.read<FirebaseFirestore>();
    final collections = await CatalogService.getAllDesignCollections(firestore);
    if (mounted) {
      setState(() {
        _collections = collections;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppScaffold(title: 'Catalog', body: Center(child: CircularProgressIndicator()));
    }
    // Determine unique sports/categories (in dummy data, collections map to sports)
    final allCategories = ['All Categories', ..._collections.map((c) => c.name).toList()];

    // Filter collections based on selection
    final filteredCollections = _selectedCategory == 'All Categories' 
        ? _collections 
        : _collections.where((c) => c.name == _selectedCategory).toList();

    return AppScaffold(
      title: 'Design Collections',
      currentNavIndex: 1,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilters(allCategories),
                  const SizedBox(height: 24),
                  if (filteredCollections.isEmpty)
                    _buildEmptyState()
                  else
                    _buildGrid(context, filteredCollections),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.surfaceLight,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DESIGN COLLECTIONS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.secondary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'VIEW FULL CATALOG',
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

  Widget _buildFilters(List<String> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FILTER BY CATEGORIES', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          width: 250,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
              items: categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat, style: Theme.of(context).textTheme.bodyMedium));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(BuildContext context, List<DesignCollection> collections) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final collection = collections[index];
        return InkWell(
          onTap: () {
            Navigator.of(context).pushNamed('/catalog/collection', arguments: collection.id);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // In a real app we'd load the collection image.
                // Using placeholder colors for dummy data
                Container(
                  color: AppTheme.primary.withOpacity(0.1),
                  child: const Center(
                    child: Icon(Icons.image, size: 48, color: AppTheme.borderSubtle),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Text(
                      collection.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
        'NO DESIGN COLLECTIONS AVAILABLE YET.',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.textMuted, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}

