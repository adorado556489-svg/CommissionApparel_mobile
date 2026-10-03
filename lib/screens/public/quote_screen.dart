import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_panel.dart';
import '../../utils/validators.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _positionController = TextEditingController();
  final _emailController = TextEditingController();
  final _confirmEmailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _orgController = TextEditingController();
  final _quantityController = TextEditingController();
  final _visionController = TextEditingController();
  
  // State
  String? _selectedSport;
  String _packageType = 'full_program_bundle';
  DateTime? _targetDate;

  final List<String> _sports = [
    'Basketball', 'Football', 'Track & Field', 'Soccer', 'Baseball', 'Other'
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    _confirmEmailController.dispose();
    _phoneController.dispose();
    _orgController.dispose();
    _quantityController.dispose();
    _visionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_emailController.text != _confirmEmailController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email addresses do not match.'), backgroundColor: AppTheme.error),
      );
      return;
    }

    if (_selectedSport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an apparel category.'), backgroundColor: AppTheme.error),
      );
      return;
    }

    // In a real app, we'd save this to the database.
    // For now, just navigate to the success screen.
    Navigator.of(context).pushReplacementNamed('/quote/success');
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Request a Quote',
      currentNavIndex: 3,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: GlassPanel(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionTitle(context, '1. Point of Contact'),
                      _buildContactFields(),
                      const SizedBox(height: 32),
                      
                      _buildSectionTitle(context, '2. Organization Details'),
                      _buildOrganizationFields(),
                      const SizedBox(height: 32),

                      _buildSectionTitle(context, '3. Design & Scope'),
                      _buildDesignFields(context),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('SUBMIT QUOTE REQUEST', style: TextStyle(letterSpacing: 1.2)),
                      ),
                    ],
                  ),
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              'CUSTOM DESIGN INTAKE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'BUILD YOUR ARMOR',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Ready for your 100% customized package? Tell us about your organization below, and our elite design team will deliver a comprehensive proposal.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const Divider(height: 24),
      ],
    );
  }

  Widget _buildContactFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: Validators.required,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: Validators.required,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _positionController,
          decoration: const InputDecoration(labelText: 'Position / Title (e.g. Head Coach)'),
          validator: Validators.required,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email Address'),
          validator: Validators.email,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Confirm Email'),
          validator: Validators.email,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Phone Number'),
          validator: Validators.required,
        ),
      ],
    );
  }

  Widget _buildOrganizationFields() {
    return Column(
      children: [
        TextFormField(
          controller: _orgController,
          decoration: const InputDecoration(labelText: 'Organization / Team Name'),
          validator: Validators.required,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Apparel Category'),
          initialValue: _selectedSport,
          items: _sports.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (val) => setState(() => _selectedSport = val),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Estimated Quantity Needed'),
          validator: Validators.required,
        ),
      ],
    );
  }

  Widget _buildDesignFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Package Type Wanted', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        _buildRadioTile('Base Uniforms', 'Jerseys & Shorts only', 'base_uniforms'),
        _buildRadioTile('Full Program Bundle', 'Uniforms + Warm-ups + Bags', 'full_program_bundle'),
        _buildRadioTile('Merch Only', 'Fan gear, hoodies, tees', 'merch_only'),
        const SizedBox(height: 16),
        
        Text('Target Delivery Date (If Known)', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: AppTheme.textSecondary),
                const SizedBox(width: 12),
                Text(
                  _targetDate != null 
                      ? '${_targetDate!.month}/${_targetDate!.day}/${_targetDate!.year}' 
                      : 'Select Date...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _visionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Design Vision / Inspiration',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildRadioTile(String title, String subtitle, String value) {
    return Material(
      color: Colors.transparent,
      child: RadioListTile<String>(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        // ignore: deprecated_member_use
        groupValue: _packageType,
        // ignore: deprecated_member_use
        onChanged: (val) {
          if (val != null) setState(() => _packageType = val);
        },
        contentPadding: EdgeInsets.zero,
        activeColor: AppTheme.primary,
      ),
    );
  }
}
