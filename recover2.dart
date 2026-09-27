import 'dart:io';
import 'dart:convert';

void main() {
  var file = File(r'C:\Users\User\.gemini\antigravity\brain\f160585a-672d-44b9-b477-b923fb06ef2f\.system_generated\logs\transcript_full.jsonl');
  if (!file.existsSync()) {
    print('No subagent transcript found');
    return;
  }
  var lines = file.readAsLinesSync();
  
  for (var line in lines.reversed) {
    try {
      var data = jsonDecode(line);
      if (data['tool_calls'] != null) {
        for (var tc in data['tool_calls']) {
          if (tc['function'] != null && tc['function']['name'] == 'default_api:write_to_file') {
            var argsStr = tc['function']['arguments'];
            if (argsStr != null) {
              var args = jsonDecode(argsStr);
              if (args['CodeContent'] != null) {
                var content = args['CodeContent'] as String;
                if (content.contains('class AuthService') && content.contains('firebaseAuth')) {
                  print('Found AuthService!');
                  File('recovered_auth_service.dart').writeAsStringSync(content);
                  return;
                }
              }
            }
          }
        }
      }
    } catch (e) {
      // ignore
    }
  }
  print('Not found in subagent write_to_file');
}
