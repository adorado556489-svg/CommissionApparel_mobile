import re
with open('lib/services/admin_service.dart', 'r') as f:
    content = f.read()

# Fix updateCoach duplication
pattern = r"      if \(index != -1\) \{\s*dummyUsers\[index\] = dummyUsers\[index\]\.copyWith\([\s\S]*?\);\s*\}\s*firstName: firstName,\s*lastName: lastName,\s*email: email,\s*organization: organization,\s*phone: phone,\s*sport: sport,\s*status: status,\s*updatedAt: DateTime\.now\(\),\s*\);\s*return null;"
replacement = r"""      if (index != -1) {
        dummyUsers[index] = dummyUsers[index].copyWith(
          firstName: firstName,
          lastName: lastName,
          email: email,
          organization: organization,
          phone: phone,
          sport: sport,
          status: status,
          updatedAt: DateTime.now(),
        );
      }
      return null;"""
content = re.sub(pattern, replacement, content)

with open('lib/services/admin_service.dart', 'w') as f:
    f.write(content)
