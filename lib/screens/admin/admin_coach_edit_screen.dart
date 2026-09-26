import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';
import '../../data/dummy_users.dart';
import '../../widgets/app_scaffold.dart';

class AdminCoachEditScreen extends StatefulWidget {
  final String coachId;
  const AdminCoachEditScreen({super.key, required this.coachId});

  @override
  State<AdminCoachEditScreen> createState() => _AdminCoachEditScreenState();
}

class _AdminCoachEditScreenState extends State<AdminCoachEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late User _coach;
  bool _isLoading = true;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _organizationCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _sportCtrl = TextEditingController();
  String _status = 'active';

  final _passwordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCoach();
    });
  }

  Future<void> _loadCoach() async {
    try {
      final doc = await context.read<FirebaseFirestore>().collection('users').doc(widget.coachId).get();
      if (doc.exists) {
        _coach = User.fromFirestore(doc);
      } else {
        _coach = dummyUsers.firstWhere((u) => u.id == widget.coachId && u.role == UserRole.coach);
      }
      _firstNameCtrl.text = _coach.firstName;
      _lastNameCtrl.text = _coach.lastName;
      _emailCtrl.text = _coach.email;
      _organizationCtrl.text = _coach.organization ?? '';
      _phoneCtrl.text = _coach.phone ?? '';
      _sportCtrl.text = _coach.sport ?? '';
      _status = _coach.status;

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Coach not found')));
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _organizationCtrl.dispose();
    _phoneCtrl.dispose();
    _sportCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final admin = context.read<AuthService>().currentUser!;
    final firestore = context.read<FirebaseFirestore>();
    final error = await AdminService.updateCoach(
      firestore,
      admin,
      _coach,
      firstName: _firstNameCtrl.text,
      lastName: _lastNameCtrl.text,
      email: _emailCtrl.text,
      organization: _organizationCtrl.text,
      phone: _phoneCtrl.text,
      sport: _sportCtrl.text,
      status: _status,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coach updated successfully')));
      Navigator.of(context).pop();
    }
  }

  void _resetPassword() {
    if (_passwordCtrl.text.isEmpty || _passwordCtrl.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 8 characters')));
      return;
    }
    final admin = context.read<AuthService>().currentUser!;
    final error = AdminService.resetCoachPassword(admin, _coach, _passwordCtrl.text);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password reset successfully for Coach ${_coach.firstName}')));
      _passwordCtrl.clear();
    }
  }

  Future<void> _deleteCoach() async {
    final admin = context.read<AuthService>().currentUser!;
    final name = '${_coach.firstName} ${_coach.lastName}';
    final error = await AdminService.deleteCoach(context.read<FirebaseFirestore>(), admin, _coach.id);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Coach $name has been removed from the system.')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const AppScaffold(title: 'Edit Coach', body: Center(child: CircularProgressIndicator()));

    return AppScaffold(
      title: 'Edit Coach',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: _formKey,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Profile Details', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: TextFormField(controller: _firstNameCtrl, decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null)),
                            const SizedBox(width: 16),
                            Expanded(child: TextFormField(controller: _lastNameCtrl, decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                        const SizedBox(height: 16),
                        TextFormField(controller: _organizationCtrl, decoration: const InputDecoration(labelText: 'Organization', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null)),
                            const SizedBox(width: 16),
                            Expanded(child: TextFormField(controller: _sportCtrl, decoration: const InputDecoration(labelText: 'Sport', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _status,
                          decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                          items: ['active', 'declined'].map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
                          onChanged: (val) => setState(() => _status = val!),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submit,
                            child: const Text('UPDATE COACH'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reset Password', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _passwordCtrl,
                              decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder()),
                              obscureText: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _resetPassword,
                            child: const Text('RESET PASSWORD'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton.icon(
                  onPressed: _deleteCoach,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Delete Coach', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

