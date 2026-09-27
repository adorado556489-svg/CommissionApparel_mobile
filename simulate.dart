import 'dart:convert';
import 'dart:io';

void main() {
  var file = File(r'C:\Users\User\.gemini\antigravity\brain\068df35f-91ee-4740-9ef4-9cc7d9377e9d\.system_generated\logs\transcript_full.jsonl');
  var lines = file.readAsLinesSync();
  
  String content = "";
  for (var line in lines) {
    var json = jsonDecode(line);
    int step = json['step_index'];
    if (step > 6632) break; // Stop at step 6632
    
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
  
  File('lib/screens/coach/coach_dashboard_screen.dart').writeAsStringSync(content);
}
