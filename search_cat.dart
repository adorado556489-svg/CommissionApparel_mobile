import 'dart:convert';
import 'dart:io';

void main() {
  var file = File(r'C:\Users\User\.gemini\antigravity\brain\068df35f-91ee-4740-9ef4-9cc7d9377e9d\.system_generated\logs\transcript_full.jsonl');
  var lines = file.readAsLinesSync();
  for (var line in lines) {
    if (!line.contains('coach_dashboard_screen.dart')) continue;
    var json = jsonDecode(line);
    if (json['type'] == 'GENERIC' && json['content'].contains('Created At:') && json['content'].contains('class _CoachDashboardScreenState')) {
        print(json['content'].substring(0, 500));
        print("=========");
    }
  }
}
