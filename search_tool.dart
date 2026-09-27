import 'dart:io';
import 'dart:convert';

void main() {
  final fullTranscriptPath = r"C:\Users\User\.gemini\antigravity\brain\068df35f-91ee-4740-9ef4-9cc7d9377e9d\.system_generated\logs\transcript_full.jsonl";
  final lines = File(fullTranscriptPath).readAsLinesSync();

  for (var line in lines) {
    try {
      final data = jsonDecode(line);
      if (data['type'] == 'TOOL_RESPONSE' && data['content'] != null) {
        final c = data['content'].toString();
        if (c.contains('class CoachDashboardScreen extends StatefulWidget') && c.contains('class _CoachDashboardScreenState')) {
           print("FOUND TOOL RESPONSE! Length: \${c.length}");
           File('found_tool_coach.txt').writeAsStringSync(c);
        }
      }
    } catch (e) {}
  }
}
