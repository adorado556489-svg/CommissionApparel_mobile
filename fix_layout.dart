import 'dart:io';

void main() {
  final file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  // Fix RenderFlex overflow by wrapping Text in Expanded
  content = content.replaceAll(
    'Text(item.name),',
    'Expanded(child: Text(item.name, overflow: TextOverflow.ellipsis)),'
  );
  content = content.replaceAll(
    'Text(design.name),',
    'Expanded(child: Text(design.name, overflow: TextOverflow.ellipsis)),'
  );

  // Fix ListTile warning
  content = content.replaceAll(
    'ListTile(',
    'Material(type: MaterialType.transparency, child: ListTile('
  );
  content = content.replaceAll(
    '),\n          ListTile(',
    ')),\n          Material(type: MaterialType.transparency, child: ListTile('
  );
  
  content = content.replaceAll(
    "onTap: () => setState(() => _activeTab = 'profile'),\n          ),",
    "onTap: () => setState(() => _activeTab = 'profile'),\n          )),"
  );
  
  content = content.replaceAll(
    "onTap: () => setState(() => _activeTab = 'overview'),\n          ),",
    "onTap: () => setState(() => _activeTab = 'overview'),\n          )),"
  );
  
  content = content.replaceAll(
    "onTap: () => setState(() => _activeTab = 'direct_orders'),\n          ),",
    "onTap: () => setState(() => _activeTab = 'direct_orders'),\n          )),"
  );

  file.writeAsStringSync(content);
}
