import 'dart:io';

String replaceLogoSearch(String content) {
  final target = '''                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (coach.sport ?? 'Team Athletics').toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 10),
                          ),''';

  final replacement = '''                  children: [
                    Container(
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
                        children: [
                          Text(
                            (coach.sport ?? 'Team Athletics').toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 10),
                          ),''';

  return content.replaceAll(target, replacement).replaceAll("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'dart:io';");
}

void main() {
  final file = File('lib/screens/public/store_search_screen.dart');
  file.writeAsStringSync(replaceLogoSearch(file.readAsStringSync()));
}
