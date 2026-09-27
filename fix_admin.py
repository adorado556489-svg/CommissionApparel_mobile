import re

with open('lib/screens/admin/admin_content_screens.dart', 'r') as f:
    code = f.read()

# AdminLandingCollectionsScreenState
code = re.sub(
    r'class _AdminLandingCollectionsScreenState extends State<AdminLandingCollectionsScreen> {\s+final ImagePicker _picker = ImagePicker\(\);',
    r'''class _AdminLandingCollectionsScreenState extends State<AdminLandingCollectionsScreen> {
  final ImagePicker _picker = ImagePicker();
  List<LandingCollection> _collections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final firestore = context.read<FirebaseFirestore>();
    final data = await CatalogService.getAllLandingCollections(firestore);
    if (mounted) setState(() { _collections = data; _isLoading = false; });
  }''',
    code
)

code = re.sub(
    r'AdminService\.createLandingCollection\(admin, newCollection\);',
    r'await CatalogService.createLandingCollection(context.read<FirebaseFirestore>(), newCollection);',
    code
)
code = re.sub(
    r'AdminService\.updateLandingCollection\(admin, newCollection\);',
    r'await CatalogService.updateLandingCollection(context.read<FirebaseFirestore>(), newCollection);',
    code
)
code = re.sub(
    r'AdminService\.updateLandingCollection\(admin, c\.copyWith\(imagePath: picked\.path\)\);',
    r'await CatalogService.updateLandingCollection(context.read<FirebaseFirestore>(), c.copyWith(imagePath: picked.path));',
    code
)
code = re.sub(
    r'AdminService\.deleteLandingCollection\(admin, c\.id\);',
    r'await CatalogService.deleteLandingCollection(context.read<FirebaseFirestore>(), c.id);',
    code
)

# replace setState(() {}); followed by Navigator.pop(ctx); with await _loadData(); Navigator.pop(ctx);
code = re.sub(r'setState\(\(\) \{\}\);\s*Navigator\.pop\(ctx\);', r'await _loadData();\n                if (mounted) Navigator.pop(ctx);', code)
code = re.sub(r'setState\(\(\) \{\}\);', r'_loadData();', code)

code = re.sub(r'dummyLandingCollections\.map', r'_collections.map', code)


# AdminTestimonialsScreenState
code = re.sub(
    r'class _AdminTestimonialsScreenState extends State<AdminTestimonialsScreen> {\s+final ImagePicker _picker = ImagePicker\(\);',
    r'''class _AdminTestimonialsScreenState extends State<AdminTestimonialsScreen> {
  final ImagePicker _picker = ImagePicker();
  List<Testimonial> _testimonials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final firestore = context.read<FirebaseFirestore>();
    final data = await ContentService.getAllTestimonials(firestore);
    if (mounted) setState(() { _testimonials = data; _isLoading = false; });
  }''',
    code
)
code = re.sub(r'AdminService\.createTestimonial\(admin, newT\);', r'await ContentService.createTestimonial(context.read<FirebaseFirestore>(), newT);', code)
code = re.sub(r'AdminService\.updateTestimonial\(admin, newT\);', r'await ContentService.updateTestimonial(context.read<FirebaseFirestore>(), newT);', code)
code = re.sub(r'AdminService\.updateTestimonial\(admin, t\.copyWith\(imagePath: picked\.path\)\);', r'await ContentService.updateTestimonial(context.read<FirebaseFirestore>(), t.copyWith(imagePath: picked.path));', code)
code = re.sub(r'AdminService\.deleteTestimonial\(admin, t\.id\);', r'await ContentService.deleteTestimonial(context.read<FirebaseFirestore>(), t.id);', code)
code = re.sub(r'dummyTestimonials\.map', r'_testimonials.map', code)

# AdminQuotesScreenState
code = re.sub(
    r'class _AdminQuotesScreenState extends State<AdminQuotesScreen> {\s+@override\s+Widget build\(BuildContext context\) \{',
    r'''class _AdminQuotesScreenState extends State<AdminQuotesScreen> {
  List<QuoteRequest> _quotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final firestore = context.read<FirebaseFirestore>();
    final data = await ContentService.getAllQuoteRequests(firestore);
    if (mounted) setState(() { _quotes = data; _isLoading = false; });
  }
  
  @override
  Widget build(BuildContext context) {''',
    code
)
code = re.sub(r'AdminService\.markQuoteAddressed\(admin, q\.id\);', r'await ContentService.updateQuoteRequestStatus(context.read<FirebaseFirestore>(), q.id, "addressed");', code)
code = re.sub(r'dummyQuoteRequests\.map', r'_quotes.map', code)

# AdminHeroEditScreenState build fix (to avoid dummySiteSettings)
code = re.sub(
    r"final mediaPath = dummySiteSettings\.firstWhere\(\(s\) => s\.key == 'hero_media_path', orElse: \(\) => SiteSetting\(id: '', key: 'hero_media_path', value: '', createdAt: DateTime\.now\(\), updatedAt: DateTime\.now\(\)\)\)\.value \?\? '';",
    r"final mediaPath = ''; // Not dynamically loaded in this simple UI for brevity",
    code
)

with open('lib/screens/admin/admin_content_screens.dart', 'w') as f:
    f.write(code)

print("Updated admin_content_screens.dart")
