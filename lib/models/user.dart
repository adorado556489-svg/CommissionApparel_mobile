import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, coach, parent }

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final UserRole role;
  
  // Phase 3 & 5A Fields
  final String status; // 'pending', 'approved', 'declined', 'active'
  final String? organization;
  final String? phone;
  final String? sport;
  final String? logoPath; // Coach's custom logo
  final List<String> assignedDesignIds;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.role,
    this.status = 'active',
    this.organization,
    this.phone,
    this.sport,
    this.logoPath,
    this.assignedDesignIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return User(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '', // Will be removed in Firestore
      role: UserRole.values.firstWhere(
        (e) => e.name == (data['role'] ?? 'parent'),
        orElse: () => UserRole.parent,
      ),
      status: data['status'] ?? 'active',
      organization: data['organization'],
      phone: data['phone'],
      sport: data['sport'],
      logoPath: data['logoPath'],
      assignedDesignIds: List<String>.from(data['assignedDesignIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      // 'password': password, // Don't sync plain-text password
      'role': role.name,
      'status': status,
      'organization': organization,
      'phone': phone,
      'sport': sport,
      'logoPath': logoPath,
      'assignedDesignIds': assignedDesignIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  String get fullName => '$firstName $lastName';
  bool get isAdmin => role == UserRole.admin;
  bool get isCoach => role == UserRole.coach;
  bool get isParent => role == UserRole.parent;
  bool get isApproved => status == 'approved' || status == 'active';
  bool get isDeclined => status == 'declined';

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    UserRole? role,
    String? status,
    String? organization,
    String? phone,
    String? sport,
    String? logoPath,
    List<String>? assignedDesignIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      status: status ?? this.status,
      organization: organization ?? this.organization,
      phone: phone ?? this.phone,
      sport: sport ?? this.sport,
      logoPath: logoPath ?? this.logoPath,
      assignedDesignIds: assignedDesignIds ?? this.assignedDesignIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'User($id, $fullName, ${role.name})';
}
