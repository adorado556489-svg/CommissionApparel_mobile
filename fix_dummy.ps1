$content = Get-Content lib\data\dummy_stores.dart -Raw

# Remove all incorrectly injected TeamStore blocks that look like this
$badPattern = "(?m)  TeamStore\(\s*id: 'store-[45]',[\s\S]*?updatedAt: DateTime\.now\(\),\s*\),\s*"
$content = $content -replace $badPattern, ""

# Now safely add store-4 and store-5 to dummyTeamStores
$store4_5 = @"
  TeamStore(
    id: 'store-4',
    userId: 'user-coach-2',
    name: 'Pending School Store',
    slug: 'pending-school-store',
    description: 'Awaiting admin approval.',
    orderDeadline: DateTime.now().add(const Duration(days: 14)),
    status: 'pending',
    packageType: 'individual',
    pricingApproved: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  TeamStore(
    id: 'store-5',
    userId: 'user-admin-1',
    name: 'TCA Fall Campaign',
    slug: 'tca-fall-campaign',
    description: 'Official Commission Apparel Campaign.',
    orderDeadline: DateTime.now().add(const Duration(days: 60)),
    status: 'approved',
    packageType: 'individual',
    pricingApproved: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
];
"@

$content = $content -replace "(?m)^\];$", $store4_5

Set-Content lib\data\dummy_stores.dart -Value $content
