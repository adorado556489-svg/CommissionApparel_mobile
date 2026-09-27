import 'dart:io';

void main() {
  final file = File('lib/screens/public/store_search_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
    '''                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [''',
    '''                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.borderSubtle),
                        image: coach.logoPath != null 
                          ? DecorationImage(image: FileImage(File(coach.logoPath!)), fit: BoxFit.cover)
                          : null,
                      ),
                      child: coach.logoPath == null ? const Icon(Icons.shield, size: 20, color: AppTheme.borderSubtle) : null,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: ['''
  );
  file.writeAsStringSync(content);
}
