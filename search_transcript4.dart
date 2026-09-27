import 'dart:convert';
import 'dart:io';

void main() {
  var file = File(r'C:\Users\User\.gemini\antigravity\brain\068df35f-91ee-4740-9ef4-9cc7d9377e9d\.system_generated\logs\transcript_full.jsonl');
  var lines = file.readAsLinesSync();
  for (var line in lines) {
    if (!line.contains('coach_dashboard_screen.dart')) continue;
    var json = jsonDecode(line);
    if (json['tool_calls'] != null) {
      for (var toolCall in json['tool_calls']) {
        if (toolCall['name'] == 'replace_file_content' || toolCall['name'] == 'write_to_file') {
          var args = toolCall['args'];
          if (args['TargetFile'] != null && args['TargetFile'].contains('coach_dashboard_screen.dart')) {
             print('FOUND TOOL CALL: ' + toolCall['name'].toString());
             if (args['ReplacementContent'] != null) {
               print('ReplacementContent: \n' + args['ReplacementContent']);
             } else if (args['CodeContent'] != null) {
               print('CodeContent: \n' + args['CodeContent']);
             }
          }
        }
      }
    }
  }
}
