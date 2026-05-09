/// lib/models/user.dart
class User {
  final String id;
  final String email;
  final String fullName;
  final String universityId;
  final String role; // student | faculty | visitor | librarian
  final String? program;
  final String? department;
  final String? yearLevel;
  final String? avatarInitials;
  final bool notificationDueDate;
  final bool notificationReservation;
  final bool notificationAnnouncements;
  final int streakCount;
  final bool isOnboarded;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.universityId,
    required this.role,
    this.program,
    this.department,
    this.yearLevel,
    this.avatarInitials,
    this.notificationDueDate = true,
    this.notificationReservation = true,
    this.notificationAnnouncements = false,
    this.streakCount = 0,
    this.isOnboarded = false,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
    id: j['id'] as String,
    email: j['email'] as String,
    fullName: j['fullName'] as String,
    universityId: j['universityId'] as String,
    role: j['role'] as String,
    program: j['program'] as String?,
    department: j['department'] as String?,
    yearLevel: j['yearLevel'] as String?,
    avatarInitials: j['avatarInitials'] as String?,
    notificationDueDate: (j['notificationDueDate'] as bool?) ?? true,
    notificationReservation: (j['notificationReservation'] as bool?) ?? true,
    notificationAnnouncements: (j['notificationAnnouncements'] as bool?) ?? false,
    streakCount: (j['streakCount'] as int?) ?? 0,
    isOnboarded: (j['isOnboarded'] as bool?) ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'universityId': universityId,
    'role': role,
    'program': program,
    'department': department,
    'yearLevel': yearLevel,
    'avatarInitials': avatarInitials,
    'notificationDueDate': notificationDueDate,
    'notificationReservation': notificationReservation,
    'notificationAnnouncements': notificationAnnouncements,
    'streakCount': streakCount,
    'isOnboarded': isOnboarded,
  };

  User copyWith({String? role, String? program, String? department,
      String? yearLevel, bool? isOnboarded}) => User(
    id: id, email: email, fullName: fullName, universityId: universityId,
    role: role ?? this.role,
    program: program ?? this.program,
    department: department ?? this.department,
    yearLevel: yearLevel ?? this.yearLevel,
    avatarInitials: avatarInitials,
    notificationDueDate: notificationDueDate,
    notificationReservation: notificationReservation,
    notificationAnnouncements: notificationAnnouncements,
    streakCount: streakCount,
    isOnboarded: isOnboarded ?? this.isOnboarded,
  );
}
