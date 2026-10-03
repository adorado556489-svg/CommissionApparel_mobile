import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import '../../models/site_setting.dart';
import '../../models/landing_collection.dart';
import '../../models/testimonial.dart';
import '../../data/dummy_content.dart';
import '../../data/dummy_quotes.dart';
import '../../widgets/app_scaffold.dart';
import '../../services/storage_service.dart';

class AdminHeroEditScreen extends StatefulWidget {
  const AdminHeroEditScreen({super.key});

  @override
  State<AdminHeroEditScreen> createState() => _AdminHeroEditScreenState();
}

class _AdminHeroEditScreenState extends State<AdminHeroEditScreen> {
  final _subtitleCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final s = dummySiteSettings.firstWhere((s) => s.key == 'hero_subtitle', orElse: () => throw Exception());
    _subtitleCtrl.text = s.value ?? '';
  }

  @override
  void dispose() {
    _subtitleCtrl.dispose();
    super.dispose();
  }

  void _save(String? mediaPath) {
    final admin = context.read<AuthService>().currentUser!;
    AdminService.updateHeroSettings(admin, subtitle: _subtitleCtrl.text, mediaPath: mediaPath);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hero settings updated successfully.')));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AuthService>().currentUser!;
    final mediaPath = dummySiteSettings.firstWhere((s) => s.key == 'hero_media_path', orElse: () => SiteSetting(id: '', key: 'hero_media_path', value: '', createdAt: DateTime.now(), updatedAt: DateTime.now())).value ?? '';
    
    return AppScaffold(
      title: 'Hero Settings',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hero Subtitle', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _subtitleCtrl,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _save(null),
                    child: const Text('UPDATE SUBTITLE ONLY'),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 32),
                  Text('Hero Background Media', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('Video uploads (MP4, MOV, AVI) are DEFERRED to the Firebase phase. Only static image simulation is supported currently.', style: TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  if (mediaPath.isNotEmpty && !mediaPath.startsWith('assets/')) 
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(image: FileImage(File(mediaPath)), fit: BoxFit.cover),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.image),
                        label: const Text('SELECT IMAGE'),
                        onPressed: () async {
                          final picked = await _picker.pickImage(source: ImageSource.gallery);
                          if (picked != null) {
                            String? url = await StorageService().uploadFile('hero', File(picked.path)); if (url != null) { _save(url); }
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () {
                          AdminService.removeHeroMedia(admin);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Media removed.')));
                        },
                        child: const Text('REMOVE MEDIA', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// LANDING COLLECTIONS
// -----------------------------------------------------------------------------
class AdminLandingCollectionsScreen extends StatefulWidget {
  const AdminLandingCollectionsScreen({super.key});
  @override
  State<AdminLandingCollectionsScreen> createState() => _AdminLandingCollectionsScreenState();
}

class _AdminLandingCollectionsScreenState extends State<AdminLandingCollectionsScreen> {
  final ImagePicker _picker = ImagePicker();

  void _showForm([LandingCollection? collection]) {
    final tabNameCtrl = TextEditingController(text: collection?.tabName ?? '');
    final titleCtrl = TextEditingController(text: collection?.title ?? '');
    final descCtrl = TextEditingController(text: collection?.description ?? '');
    final sortCtrl = TextEditingController(text: collection?.sortOrder.toString() ?? '0');
    bool isActive = collection?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(collection == null ? 'Create Collection' : 'Edit Collection'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: tabNameCtrl, decoration: const InputDecoration(labelText: 'Tab Name')),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                TextField(controller: sortCtrl, decoration: const InputDecoration(labelText: 'Sort Order'), keyboardType: TextInputType.number),
                CheckboxListTile(
                  title: const Text('Is Active'),
                  value: isActive,
                  onChanged: (v) => setDialogState(() => isActive = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                final admin = context.read<AuthService>().currentUser!;
                final newCollection = LandingCollection(
                  id: collection?.id ?? 'coll-${DateTime.now().millisecondsSinceEpoch}',
                  tabName: tabNameCtrl.text,
                  title: titleCtrl.text,
                  description: descCtrl.text,
                  imagePath: collection?.imagePath,
                  sortOrder: int.tryParse(sortCtrl.text) ?? 0,
                  isActive: isActive,
                  createdAt: collection?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                if (collection == null) {
                  AdminService.createLandingCollection(admin, newCollection);
                } else {
                  AdminService.updateLandingCollection(admin, newCollection);
                }
                
                setState(() {});
                Navigator.pop(ctx);
              },
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Landing Collections',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('ADD COLLECTION'),
              onPressed: () => _showForm(),
            ),
          ),
          const SizedBox(height: 24),
          ...dummyLandingCollections.map((c) => Card(
            child: ListTile(
              title: Text('${c.tabName} - ${c.title}'),
              subtitle: Text('Sort: ${c.sortOrder} | Active: ${c.isActive}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: () async {
                      final authService = context.read<AuthService>();
                      final picked = await _picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        final admin = authService.currentUser!;
                        AdminService.updateLandingCollection(admin, c.copyWith(imagePath: picked.path));
                        if (!mounted) return;
                        setState(() {});
                      }
                    },
                  ),
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _showForm(c)),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      final admin = context.read<AuthService>().currentUser!;
                      AdminService.deleteLandingCollection(admin, c.id);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TESTIMONIALS
// -----------------------------------------------------------------------------
class AdminTestimonialsScreen extends StatefulWidget {
  const AdminTestimonialsScreen({super.key});
  @override
  State<AdminTestimonialsScreen> createState() => _AdminTestimonialsScreenState();
}

class _AdminTestimonialsScreenState extends State<AdminTestimonialsScreen> {
  final ImagePicker _picker = ImagePicker();

  void _showForm([Testimonial? t]) {
    final nameCtrl = TextEditingController(text: t?.clientName ?? '');
    final orgCtrl = TextEditingController(text: t?.organization ?? '');
    final contentCtrl = TextEditingController(text: t?.content ?? '');
    final sortCtrl = TextEditingController(text: t?.sortOrder.toString() ?? '0');
    bool isActive = t?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(t == null ? 'Create Testimonial' : 'Edit Testimonial'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Client Name')),
                TextField(controller: orgCtrl, decoration: const InputDecoration(labelText: 'Organization')),
                TextField(controller: contentCtrl, decoration: const InputDecoration(labelText: 'Content'), maxLines: 3),
                TextField(controller: sortCtrl, decoration: const InputDecoration(labelText: 'Sort Order'), keyboardType: TextInputType.number),
                CheckboxListTile(
                  title: const Text('Is Active'),
                  value: isActive,
                  onChanged: (v) => setDialogState(() => isActive = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                final admin = context.read<AuthService>().currentUser!;
                final newT = Testimonial(
                  id: t?.id ?? 'test-${DateTime.now().millisecondsSinceEpoch}',
                  clientName: nameCtrl.text,
                  organization: orgCtrl.text.isEmpty ? null : orgCtrl.text,
                  content: contentCtrl.text,
                  imagePath: t?.imagePath,
                  sortOrder: int.tryParse(sortCtrl.text) ?? 0,
                  isActive: isActive,
                  createdAt: t?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                if (t == null) {
                  AdminService.createTestimonial(admin, newT);
                } else {
                  AdminService.updateTestimonial(admin, newT);
                }
                
                setState(() {});
                Navigator.pop(ctx);
              },
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Testimonials',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('ADD TESTIMONIAL'),
              onPressed: () => _showForm(),
            ),
          ),
          const SizedBox(height: 24),
          ...dummyTestimonials.map((t) => Card(
            child: ListTile(
              title: Text(t.clientName),
              subtitle: Text('${t.organization ?? 'No Org'} | Sort: ${t.sortOrder} | Active: ${t.isActive}\n${t.content}', maxLines: 2),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: () async {
                      final authService = context.read<AuthService>();
                      final picked = await _picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        final admin = authService.currentUser!;
                        AdminService.updateTestimonial(admin, t.copyWith(imagePath: picked.path));
                        if (!mounted) return;
                        setState(() {});
                      }
                    },
                  ),
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _showForm(t)),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      final admin = context.read<AuthService>().currentUser!;
                      AdminService.deleteTestimonial(admin, t.id);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// QUOTES
// -----------------------------------------------------------------------------
class AdminQuotesScreen extends StatefulWidget {
  const AdminQuotesScreen({super.key});
  @override
  State<AdminQuotesScreen> createState() => _AdminQuotesScreenState();
}

class _AdminQuotesScreenState extends State<AdminQuotesScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Quote Requests',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ...dummyQuoteRequests.map((q) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${q.firstName} ${q.lastName} (${q.organizationName})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(q.status.toUpperCase(), style: TextStyle(color: q.status == 'new' ? Colors.orange : Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Email: ${q.email} | Phone: ${q.phone ?? 'N/A'}'),
                  Text('Category: ${q.apparelCategory} | Qty: ${q.estimatedQuantity}'),
                  Text('Package: ${q.packageType} | Needed by: ${q.targetDeliveryDate?.toString().split(' ')[0] ?? 'N/A'}'),
                  const SizedBox(height: 8),
                  Text('Vision: ${q.designVision ?? ''}'),
                  const SizedBox(height: 16),
                  if (q.status == 'new')
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('MARK ADDRESSED'),
                        onPressed: () {
                          final admin = context.read<AuthService>().currentUser!;
                          AdminService.markQuoteAddressed(admin, q.id);
                          setState(() {});
                        },
                      ),
                    ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}
