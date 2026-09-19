/// Coach upload model matching the Laravel `CoachUpload` Eloquent model.
///
/// Tracks image uploads by coaches for identity verification or custom
/// design references. Admin reviews uploads.
class CoachUpload {
  final String id;
  final String userId; // FK → User (coach)
  final String imagePath;
  final String? description;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final DateTime updatedAt;

  const CoachUpload({
    required this.id,
    required this.userId,
    required this.imagePath,
    this.description,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
}
