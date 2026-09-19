$content = Get-Content lib\screens\admin\admin_store_edit_screen.dart -Raw

$packagesHtml = @"
            const SizedBox(height: 24),
            Text('Package Management', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            GlassPanel(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _storeItems.where((i) => i.name.toLowerCase().contains('package')).map((package) {
                  final components = _storeItems.where((c) => package.componentIds.contains(c.id)).toList();
                  final available = _storeItems.where((c) => c.id != package.id && !package.componentIds.contains(c.id)).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(package.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ...components.map((c) => Row(
                        children: [
                          Text('- ${c.name}'),
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red, size: 16),
                            onPressed: () {
                              setState(() {
                                final index = dummyStoreItems.indexWhere((i) => i.id == package.id);
                                dummyStoreItems[index] = package.copyWith(
                                  componentIds: List.from(package.componentIds)..remove(c.id)
                                );
                                _loadStoreData();
                              });
                            }
                          )
                        ]
                      )),
                      if (available.isNotEmpty)
                        DropdownButton<String>(
                          hint: const Text('Attach Component'),
                          items: available.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                final index = dummyStoreItems.indexWhere((i) => i.id == package.id);
                                dummyStoreItems[index] = package.copyWith(
                                  componentIds: List.from(package.componentIds)..add(val)
                                );
                                _loadStoreData();
                              });
                            }
                          },
                        ),
                      const Divider(),
                    ]
                  );
                }).toList(),
              ),
            ),
"@

$content = $content -replace "              const SizedBox\(height: 24\),`r`n              Text\('Add Design to Store', style: Theme\.of\(context\)\.textTheme\.titleLarge\),", "$packagesHtml`r`n              const SizedBox(height: 24),`r`n              Text('Add Design to Store', style: Theme.of(context).textTheme.titleLarge),"

Set-Content lib\screens\admin\admin_store_edit_screen.dart -Value $content
