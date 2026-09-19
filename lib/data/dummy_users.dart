import '../models/user.dart';

/// Dummy user data matching the Laravel DatabaseSeeder + extras for testing.
final List<User> dummyUsers = [
  // ── Admin ───────────────────────────────────────────────────────────────
  User(
    id: 'user-admin-1',
    firstName: 'Commission',
    lastName: 'Apparel Admin',
    email: 'admin@commissionapparel.com',
    role: UserRole.admin,
    status: 'approved',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  ),

  // ── Coaches ─────────────────────────────────────────────────────────────
  User(
    id: 'user-coach-1',
    firstName: 'Marcus',
    lastName: 'Johnson',
    email: 'coach@example.com',
    role: UserRole.coach,
    status: 'active',
    organization: 'Riverside Academy',
    phone: '(555) 123-4567',
    sport: 'Basketball',
    assignedDesignIds: ['design-bball-pkg', 'design-bball-jersey', 'design-bball-shorts', 'design-bball-hoodie', 'design-bball-shooting'],
    createdAt: DateTime(2024, 2, 15),
    updatedAt: DateTime(2024, 6, 1),
  ),
  User(
    id: 'user-coach-2',
    firstName: 'Sarah',
    lastName: 'Williams',
    email: 'sarah.williams@school.edu',
    role: UserRole.coach,
    status: 'active',
    organization: 'Northview High School',
    phone: '(555) 987-6543',
    sport: 'Football',
    assignedDesignIds: ['design-fb-pkg', 'design-fb-jersey', 'design-fb-pants'],
    createdAt: DateTime(2024, 3, 10),
    updatedAt: DateTime(2024, 7, 20),
  ),
  User(
    id: 'user-coach-3',
    assignedDesignIds: ['design-bball-pkg', 'design-fb-pkg'],
    firstName: 'David',
    lastName: 'Chen',
    email: 'david.chen@trackclub.org',
    role: UserRole.coach,
    status: 'pending',
    organization: 'Metro Track Club',
    phone: '(555) 246-8135',
    sport: 'Track & Field',
    createdAt: DateTime(2024, 8, 1),
    updatedAt: DateTime(2024, 8, 1),
  ),

  // ── Parents ─────────────────────────────────────────────────────────────
  User(
    id: 'user-parent-1',
    firstName: 'Jennifer',
    lastName: 'Martinez',
    email: 'parent@test.com',
    role: UserRole.parent,
    status: 'active',
    phone: '(555) 111-2222',
    createdAt: DateTime(2024, 4, 5),
    updatedAt: DateTime(2024, 4, 5),
  ),
  User(
    id: 'user-parent-2',
    firstName: 'John',
    lastName: 'Smith',
    email: 'john.smith@email.com',
    role: UserRole.parent,
    status: 'active',
    phone: '(555) 333-4444',
    createdAt: DateTime(2024, 5, 12),
    updatedAt: DateTime(2024, 5, 12),
  ),
  User(
    id: 'user-parent-3',
    firstName: 'Maria',
    lastName: 'Garcia',
    email: 'maria.garcia@email.com',
    role: UserRole.parent,
    status: 'active',
    createdAt: DateTime(2024, 6, 20),
    updatedAt: DateTime(2024, 6, 20),
  ),
];

// ── Convenience Lookups ───────────────────────────────────────────────────
final User dummyAdmin = dummyUsers.firstWhere((u) => u.isAdmin);
final List<User> dummyCoaches = dummyUsers.where((u) => u.isCoach).toList();
final List<User> dummyParents = dummyUsers.where((u) => u.isParent).toList();
