import 'dart:io';

void main() {
  var file = File('C:/Users/User/.gemini/antigravity/brain/068df35f-91ee-4740-9ef4-9cc7d9377e9d/implementation_plan.md');
  var content = file.readAsStringSync();
  content = content.replaceFirst("- [ ] **Phase 8/10 — Checkpoint M**", "- [x] **Phase 8/10 — Checkpoint M**");
  file.writeAsStringSync(content);
}
