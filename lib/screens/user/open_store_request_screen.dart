import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/store_service.dart';
import '../../models/team_store.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/app_scaffold.dart';
import '../../utils/validators.dart';

class OpenStoreRequestScreen extends StatefulWidget {
  const OpenStoreRequestScreen({super.key});

  @override
  State<OpenStoreRequestScreen> createState() => _OpenStoreRequestScreenState();
}

class _OpenStoreRequestScreenState extends State<OpenStoreRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedPackageType = 'package_a';
  String _selectedSport = 'Basketball';
  DateTime? _orderDeadline;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _storeNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _orderDeadline = picked);
    }
  }

  Future<void> _submitRequest() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    if (user == null) {
      setState(() => _errorMessage = 'You must be logged in to submit a request.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final firestore = context.read<FirebaseFirestore>();
      final storeId = 'store_${DateTime.now().millisecondsSinceEpoch}';
      final storeName = _storeNameController.text.trim();
      final slug = TeamStore.generateSlug(storeName);

      final newStore = TeamStore(
        id: storeId,
        userId: user.id,
        name: storeName,
        slug: slug,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        packageType: _selectedPackageType,
        orderDeadline: _orderDeadline,
        status: 'pending',
        pricingApproved: false,
        isArchived: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await StoreService.createStore(firestore, newStore);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Store request submitted successfully! Pending admin approval.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to submit store request: $e';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Request to Open Store',
      currentNavIndex: 0,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Open Your Team Store',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Fill out the store details below. Once approved by an admin, your user role will automatically upgrade to Coach, allowing you to manage products, designs, and orders.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            GlassPanel(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _storeNameController,
                      decoration: const InputDecoration(
                        labelText: 'Store / Team Name *',
                        prefixIcon: Icon(Icons.storefront),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: Validators.required,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Store Description / Tagline (Optional)',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedSport,
                      decoration: const InputDecoration(
                        labelText: 'Primary Sport',
                        prefixIcon: Icon(Icons.sports),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Basketball', child: Text('Basketball')),
                        DropdownMenuItem(value: 'Football', child: Text('Football')),
                        DropdownMenuItem(value: 'Track & Field', child: Text('Track & Field')),
                        DropdownMenuItem(value: 'Soccer', child: Text('Soccer')),
                        DropdownMenuItem(value: 'Baseball', child: Text('Baseball')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedSport = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedPackageType,
                      decoration: const InputDecoration(
                        labelText: 'Apparel Package Type',
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'package_a', child: Text('Package A - Essential Team Kit', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'package_b', child: Text('Package B - Pro Performance Kit', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'package_c', child: Text('Package C - Championship Bundle', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'individual', child: Text('Individual Custom Orders', overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPackageType = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        _orderDeadline == null
                            ? 'Select Target Order Deadline (Optional)'
                            : 'Order Deadline: ${_orderDeadline!.toLocal().toString().split(' ')[0]}',
                      ),
                      trailing: TextButton(
                        onPressed: _pickDeadline,
                        child: Text(_orderDeadline == null ? 'Choose' : 'Change'),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitRequest,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Submit Store Request'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
