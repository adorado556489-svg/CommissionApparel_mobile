import 'dart:io';

void replaceFunction(String path, String funcName, String newBody) {
  var file = File(path);
  var content = file.readAsStringSync();
  var startIdx = content.indexOf(funcName);
  if (startIdx == -1) return;
  // find the first '{'
  var braceStart = content.indexOf('{', startIdx);
  // find the matching '}'
  int braceCount = 1;
  int endIdx = braceStart + 1;
  while (endIdx < content.length && braceCount > 0) {
    if (content[endIdx] == '{') braceCount++;
    if (content[endIdx] == '}') braceCount--;
    endIdx++;
  }
  
  var newContent = content.substring(0, braceStart) + newBody + content.substring(endIdx);
  file.writeAsStringSync(newContent);
}

void main() {}
