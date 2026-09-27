import 'dart:convert';
import 'dart:io';

void main() {
  var file = File(r'C:\Users\User\.gemini\antigravity\brain\f160585a-672d-44b9-b477-b923fb06ef2f\.system_generated\logs\transcript_full.jsonl');
  if (!file.existsSync()) {
    print("No subagent file");
    return;
  }
  var lines = file.readAsLinesSync();
  String content = '';
  for (var line in lines) {
    if (!line.contains('coach_dashboard_screen.dart')) continue;
    var json = jsonDecode(line);
    if (json['tool_calls'] != null) {
      for (var toolCall in json['tool_calls']) {
        if (toolCall['name'] == 'write_to_file') {
          var args = toolCall['args'];
          if (args['TargetFile'] != null && args['TargetFile'].contains('coach_dashboard_screen.dart')) {
             content = args['CodeContent'] ?? '';
          }
        }
        else if (toolCall['name'] == 'replace_file_content') {
          var args = toolCall['args'];
          if (args['TargetFile'] != null && args['TargetFile'].contains('coach_dashboard_screen.dart')) {
             var target = args['TargetContent'];
             var replacement = args['ReplacementContent'];
             if (target != null && replacement != null) {
                content = content.replaceAll(target, replacement);
             }
          }
        }
      }
    }
  }
  print("Final simulated size: \${content.length}");
  File('coach_dash_subagent.dart').writeAsStringSync(content);
}
