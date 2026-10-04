import re

with open('lib/screens/coach/coach_dashboard_screen.dart', 'r') as f:
    content = f.read()

target = r"Text\('Store Items', style: Theme.of\(context\).textTheme.titleLarge\),.*?const SizedBox\(height: 16\),"
replacement = """Text('Store Items', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (_storeItems.isEmpty)
                const Text('No products in your store yet. Go to the Custom Designs tab to add some!')
              else
                ..._storeItems.map((item) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: item.displayImage != null 
                        ? Image.network(item.displayImage!, width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.checkroom, size: 50),
                    title: Text(item.name),
                    subtitle: Text('Retail: \\$${item.retailPrice.toStringAsFixed(2)} | Profit: \\$${(item.retailPrice - item.wholesalePrice).toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeStoreItem(item.id),
                    ),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 16),"""

new_content = re.sub(target, replacement, content, flags=re.DOTALL)

with open('lib/screens/coach/coach_dashboard_screen.dart', 'w') as f:
    f.write(new_content)
