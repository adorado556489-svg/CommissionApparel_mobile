import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Remove lines that just mutate dummy arrays
    content = re.sub(r'^[ \t]*dummy[a-zA-Z0-9_]+\.(add|removeWhere|removeAt)\[?.*\n?', '', content, flags=re.MULTILINE)
    content = re.sub(r'^[ \t]*final dummyIndex = dummy[a-zA-Z0-9_]+\.indexWhere.*\n?', '', content, flags=re.MULTILINE)
    content = re.sub(r'^[ \t]*if \(dummyIndex != -1\) \{?\n?[ \t]*dummy[a-zA-Z0-9_]+\[dummyIndex\] = .*\n?\}?\n?', '', content, flags=re.MULTILINE)
    content = re.sub(r'^[ \t]*final idx = dummy[a-zA-Z0-9_]+\.indexWhere.*\n?', '', content, flags=re.MULTILINE)
    content = re.sub(r'^[ \t]*if \(idx != -1\) \{?\n?[ \t]*dummy[a-zA-Z0-9_]+\[idx\] = .*\n?\}?\n?', '', content, flags=re.MULTILINE)
    content = re.sub(r'^[ \t]*if \(dummyIndex != -1\) dummy[a-zA-Z0-9_]+.*?\n?', '', content, flags=re.MULTILINE)
    content = re.sub(r'^[ \t]*if \(idx != -1\) dummy[a-zA-Z0-9_]+.*?\n?', '', content, flags=re.MULTILINE)

    # 2. Fix try { ... } catch (_) { return dummy...; }
    content = re.sub(r'catch\s*\((_)\)\s*\{\s*return\s*dummy[a-zA-Z0-9_]+.*?;?\s*\}', r'catch (e) { _handleError(e, "ServiceContext"); return null; }', content)

    # 3. Fix if (qs.docs.isNotEmpty) { return ... } ... return dummy...;
    content = re.sub(r'if\s*\((qs|snap)\.docs\.isNotEmpty\)\s*\{([\s\S]*?)\}\s*\}\s*catch\s*\((.*?)\)\s*\{([\s\S]*?)\}\s*return\s*dummy[a-zA-Z0-9_]+(?:\.toList\(\))?;',
                     r'return \1.docs.map((d) => \1.docs.first.data() /* placeholder */).toList();\n    } catch (\3) {\4}\n    return [];', content)

    # Actually better logic for returns: just replace `return dummySomething` with `return []` or `return null`
    content = re.sub(r'return dummy[a-zA-Z0-9_]+(?:\.cast<[^>]+>\(\))?\.firstWhere\([^,]+,\s*orElse:\s*\(\)\s*=>\s*null\);', r'return null;', content)
    content = re.sub(r'return dummy[a-zA-Z0-9_]+\.firstWhere\([^)]+\);', r'return null;', content)
    
    # replace all remaining `return dummyList.where(...).toList();` with `return [];`
    content = re.sub(r'return\s+dummy[a-zA-Z0-9_]+\.where\([^)]+\)\.toList\(\);', r'return [];', content)
    content = re.sub(r'=\s*dummy[a-zA-Z0-9_]+\.where\([^)]+\)\.toList\(\);', r'= [];', content)
    
    # replace simple `return dummyList;` or `return dummyList.toList();`
    content = re.sub(r'return\s+dummy[a-zA-Z0-9_]+(?:\.toList\(\))?;', r'return [];', content)
    
    # store assignments
    content = re.sub(r'=\s*dummy[a-zA-Z0-9_]+;', r'= [];', content)

    # loop mutations like for (var i = 0; i < dummyParentOrders.length; i++) { ... }
    content = re.sub(r'for\s*\(var\s+i\s*=\s*0;\s*i\s*<\s*dummy[a-zA-Z0-9_]+\.length;\s*i\+\+\)\s*\{[\s\S]*?\}', r'', content)
    
    # other auth fallbacks
    content = re.sub(r'// Fallback to dummy users[\s\S]*?\}\s*\}', r'', content)
    content = re.sub(r'// Fallback[\s\S]*?\}\s*\}', r'', content)
    content = re.sub(r'final userIndex = dummyUsers[\s\S]*?\}', r'', content)
    content = re.sub(r'final existsInDummy = dummyUsers[\s\S]*?\}', r'', content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Processed {filepath}")

files = [
    'lib/services/auth_service.dart',
    'lib/services/order_service.dart',
    'lib/services/admin_service.dart',
    'lib/services/store_service.dart',
    'lib/services/catalog_service.dart',
    'lib/services/content_service.dart'
]

for f in files:
    if os.path.exists(f):
        process_file(f)
