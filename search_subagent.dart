import 'dart:io';
import 'dart:convert';

void main() {
  final fullTranscriptPath = r"C:\Users\User\.gemini\antigravity\brain\f160585a-672d-44b9-b477-b923fb06ef2f\.system_generated\logs\transcript_full.jsonl";
  
  if (!File(fullTranscriptPath).existsSync()) {
      print("Subagent transcript doesn't exist!");
      return;
  }
  
  final lines = File(fullTranscriptPath).readAsLinesSync();

  String latestContent = "";
  for (var line in lines) {
    try {
      final data = jsonDecode(line);
      if (data['tool_calls'] != null) {
        for (var call in data['tool_calls']) {
          if (call['arguments'] != null && call['arguments']['CodeContent'] != null) {
            if (call['arguments']['CodeContent'].contains('class CoachDashboardScreen')) {
              latestContent = call['arguments']['CodeContent'];
            }
          }
        }
      }
    } catch (e) {}
  }

  if (latestContent.isNotEmpty) {
    File('found_coach.txt').writeAsStringSync(latestContent);
    print("Found it! Length: \${latestContent.length}");
  } else {
    print("Not found in subagent.");
  }
}
