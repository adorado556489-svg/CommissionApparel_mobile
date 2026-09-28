import os
import re

for root, _, files in os.walk('test'):
    for file in files:
        if file.endsWith('_test.dart'):
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            if 'FakeFirebaseFirestore' in content and 'setUp(' in content:
                # Find setUp(() { or setUp(() async {
                if 'setUp(() async {' in content:
                    content = content.replace('setUp(() async {', "setUp(() async {\n    await TestSeeder.seedAll(firestore);")
                elif 'setUp(() {' in content:
                    content = content.replace('setUp(() {', "setUp(() async {\n    await TestSeeder.seedAll(firestore);")
                
                # Make sure test_seeder is imported
                if 'TestSeeder' not in content:
                    # Calculate relative path
                    pass
