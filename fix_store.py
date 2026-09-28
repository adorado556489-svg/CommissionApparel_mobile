import re

with open('test/coach_store_test.dart', 'r') as f:
    content = f.read()

content = re.sub(r"setUp\(\(\) \{.*?\}\);", "setUp(() {\n    auth = AuthService(firestore: FakeFirebaseFirestore(), firebaseAuth: AutoSeedingMockFirebaseAuth());\n  });", content, flags=re.DOTALL)

with open('test/coach_store_test.dart', 'w') as f:
    f.write(content)
