const fs = require('fs');
const path = 'lib/screens/admin/admin_coach_edit_screen.dart';
let code = fs.readFileSync(path, 'utf8');

const saveCoachOld = `  void _saveCoach() {
    if (_formKey.currentState!.validate()) {
      final admin = context.read<AuthService>().currentUser!;
      final error = AdminService.updateCoach(
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

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coach profile updated successfully.')));
        Navigator.pop(context);
      }
    }
  }`;

const saveCoachNew = `  Future<void> _saveCoach() async {
    if (_formKey.currentState!.validate()) {
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coach profile updated successfully.')));
        Navigator.pop(context);
      }
    }
  }`;

if (code.includes(saveCoachOld)) {
    code = code.replace(saveCoachOld, saveCoachNew);
} else {
    console.error("Could not find _saveCoach bounds");
}

fs.writeFileSync(path, code, 'utf8');
console.log("Updated admin_coach_edit_screen.dart");
