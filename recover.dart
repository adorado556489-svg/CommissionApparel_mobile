import 'dart:io';
import 'dart:convert';

void main() {
  var file = File(r'C:\Users\User\.gemini\antigravity\brain\068df35f-91ee-4740-9ef4-9cc7d9377e9d\.system_generated\logs\transcript_full.jsonl');
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
                if (content.contains('class AuthService') && content.contains('_injectedAuth')) {
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
  print('Not found in write_to_file');
}
