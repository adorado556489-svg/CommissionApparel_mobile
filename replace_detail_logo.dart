import 'dart:io';

String replaceLogoDetail(String content) {
  final target = '''          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: const Icon(Icons.shield, size: 40, color: AppTheme.borderSubtle),
          ),''';

  final replacement = '''          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.borderSubtle),
              image: coach?.logoPath != null 
                  ? DecorationImage(
                      image: FileImage(File(coach!.logoPath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: coach?.logoPath == null ? const Icon(Icons.shield, size: 40, color: AppTheme.borderSubtle) : null,
          ),''';

  return content.replaceAll(target, replacement);
}

void main() {
  final file = File('lib/screens/public/store_detail_screen.dart');
  file.writeAsStringSync(replaceLogoDetail(file.readAsStringSync()));
}
