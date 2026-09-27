import 'dart:io';

void main() {
  var file = File('lib/screens/public/quote_screen.dart');
  var code = file.readAsStringSync();

  // Add ContentService and QuoteRequest imports if not present
  if (!code.contains("import '../../services/content_service.dart';")) {
     code = code.replaceFirst(
        "import '../../widgets/app_scaffold.dart';", 
        "import '../../widgets/app_scaffold.dart';\nimport '../../services/content_service.dart';\nimport '../../models/quote_request.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport 'package:provider/provider.dart';\nimport 'package:uuid/uuid.dart';");
  }

  // Modify _submit
  var oldSubmit = """  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_emailController.text != _confirmEmailController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email addresses do not match.'), backgroundColor: AppTheme.error),
      );
      return;
    }

    if (_selectedSport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a sport/category.'), backgroundColor: AppTheme.error),
      );
      return;
    }

    // In a real app, we'd save this to the database.
    // For now, just navigate to the success screen.
    Navigator.of(context).pushReplacementNamed('/quote/success');
  }""";

  var newSubmit = """  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_emailController.text != _confirmEmailController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email addresses do not match.'), backgroundColor: AppTheme.error),
      );
      return;
    }

    if (_selectedSport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a sport/category.'), backgroundColor: AppTheme.error),
      );
      return;
    }

    final newQuote = QuoteRequest(
      id: const Uuid().v4(),
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      positionTitle: _positionController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      organizationName: _orgController.text,
      apparelCategory: _selectedSport!,
      estimatedQuantity: _selectedQuantity,
      packageType: _packageType,
      targetDeliveryDate: _targetDate,
      designVision: _notesController.text,
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await ContentService.createQuoteRequest(context.read<FirebaseFirestore>(), newQuote);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/quote/success');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }""";

  if (code.contains(oldSubmit)) {
      code = code.replaceAll(oldSubmit, newSubmit);
      file.writeAsStringSync(code);
      print("quote_screen.dart updated.");
  } else {
      print("Could not find _submit in quote_screen.dart");
  }
}
