import 'dart:io';
import 'dart:convert';

void main() {
  var path = 'C:/Users/User/.gemini/antigravity/brain/068df35f-91ee-4740-9ef4-9cc7d9377e9d/.system_generated/logs/transcript_full.jsonl';
  var lines = File(path).readAsLinesSync();
  
  // Find all Get-Content of order_service.dart
  for (var i = lines.length - 1; i >= 0; i--) {
    if (lines[i].contains('Get-Content') && lines[i].contains('order_service.dart')) {
      // Look at the response to this step. 
      // This is a quick and dirty check.
      print('Found Get-Content order_service at line $i');
    }
  }
}
