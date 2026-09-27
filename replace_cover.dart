import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    """  Future<void> _pickCoverImage() async {
    if (_activeStore == null) return;
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          final updated = _activeStore!.copyWith(coverImagePath: pickedFile.path);
          final idx = dummyTeamStores.indexWhere((s) => s.id == _activeStore!.id);
          if (idx != -1) dummyTeamStores[idx] = updated;
          _activeStore = updated;
        });
      }
    } catch (_) {}
  }""",
    """  Future<void> _pickCoverImage() async {
    if (_activeStore == null) return;
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        await StoreService.updateStore(context.read<FirebaseFirestore>(), _activeStore!.copyWith(coverImagePath: pickedFile.path));
        await _loadData();
      }
    } catch (_) {}
  }"""
  );
  file.writeAsStringSync(content);
}
